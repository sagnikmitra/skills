#!/usr/bin/env bash
# sgnk-collect.sh — deterministic, bounded, secret-safe working-state collector.
# Emits <OUT_DIR>/manifest.json (schema_version 3) as JSON built entirely with jq,
# so the recall loader can read it with jq (jq parses JSON only, never YAML).
#
# Usage: sgnk-collect.sh <REPO_ROOT> <OUT_DIR> <MODE>
#   MODE: quick|auto -> skip slow remote (gh) phase;  full -> include remote.
#
# Design notes (deliberate):
#  * `set -uo pipefail` (NOT -e): this collector must DEGRADE GRACEFULLY. A failing
#    optional git/gh/lsof call should leave a field empty, never abort the snapshot.
#    The only hard failures are: not a git repo, or jq missing — both explicit below.
#  * macOS-portable: no flock, no sha256sum, no GNU date. Uses mkdir-mutex elsewhere,
#    shasum/openssl for hashing, BSD-safe date, /dev/urandom via od for randomness.
#  * Bounds: no full diffs (only --stat totals + name lists), every list capped,
#    every network call time-boxed.
set -uo pipefail

REPO_ROOT="${1:-}"
OUT_DIR="${2:-}"
MODE="${3:-full}"
GH_TIMEOUT="${SGNK_GH_TIMEOUT:-5}"

die() { echo "sgnk: $*" >&2; exit 1; }

[ -n "$REPO_ROOT" ] && [ -n "$OUT_DIR" ] || die "usage: sgnk-collect.sh <REPO_ROOT> <OUT_DIR> <MODE>"
command -v jq >/dev/null 2>&1 || die "jq required (brew install jq)"
command -v git >/dev/null 2>&1 || die "git required"
git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repo: $REPO_ROOT"

mkdir -p "$OUT_DIR" || die "cannot create OUT_DIR: $OUT_DIR"

# ---- helpers ---------------------------------------------------------------
g() { git -C "$REPO_ROOT" --no-pager "$@" 2>/dev/null; }          # quiet git
gp() { git -C "$REPO_ROOT" rev-parse --git-path "$1" 2>/dev/null; } # resolve .git path

# portable timeout: macOS ships no `timeout`. Use it (or gtimeout) when present;
# otherwise run unbounded (gh is only used in present-user `full` mode).
if command -v timeout >/dev/null 2>&1; then _TO=timeout
elif command -v gtimeout >/dev/null 2>&1; then _TO=gtimeout
else _TO=""; fi
run_to() { local d="$1"; shift; if [ -n "$_TO" ]; then "$_TO" "$d" "$@"; else "$@"; fi; }

# newline-delimited stdin -> JSON array of (non-empty) strings, capped at $1
arr_lines() { local cap="${1:-1000}"; jq -R -s --argjson cap "$cap" \
  'split("\n") | map(select(length>0)) | .[0:$cap]'; }

sha256_file() {
  [ -f "$1" ] || { echo ""; return; }
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" 2>/dev/null | awk '{print $1}';
  elif command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" 2>/dev/null | awk '{print $1}';
  elif command -v openssl >/dev/null 2>&1; then openssl dgst -sha256 "$1" 2>/dev/null | awk '{print $NF}';
  else echo ""; fi
}

now_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
id_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
rand_hex="$(od -An -N4 -tx1 /dev/urandom 2>/dev/null | tr -d ' \n')"; rand_hex="${rand_hex:-0000}"
# Caller (skill body / hook) may pin the id so manifest.id == snapshot dir name.
id_val="${SGNK_ID:-${id_stamp}_auto_${rand_hex}}"

# ---- provenance ------------------------------------------------------------
prov_tool="${SGNK_TOOL:-claude}"
prov_account="${SGNK_ACCOUNT:-}"
[ -z "$prov_account" ] && [ -f "$HOME/.sgnk/identity" ] && prov_account="$(head -n1 "$HOME/.sgnk/identity" 2>/dev/null)"
prov_account="${prov_account:-unknown}"
prov_host="$(hostname 2>/dev/null || echo unknown)"
prov_user="$(whoami 2>/dev/null || echo unknown)"
prov_os="$(uname -srm 2>/dev/null || echo unknown)"

# ---- vcs core --------------------------------------------------------------
branch="$(g rev-parse --abbrev-ref HEAD)"; branch="${branch:-unknown}"
head_sha="$(g rev-parse HEAD)"; head_sha="${head_sha:-}"
upstream="$(g rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')"; upstream="${upstream:-}"
common_dir="$(g rev-parse --git-common-dir)"; git_dir="$(g rev-parse --git-dir)"
is_worktree=false; [ -n "$common_dir" ] && [ "$common_dir" != "$git_dir" ] && is_worktree=true
worktree_path="$(g rev-parse --show-toplevel)"; worktree_path="${worktree_path:-$REPO_ROOT}"

ahead=0; behind=0
if [ -n "$upstream" ]; then
  lr="$(g rev-list --left-right --count "${upstream}...HEAD")"
  behind="$(echo "$lr" | awk '{print $1+0}')"; ahead="$(echo "$lr" | awk '{print $2+0}')"
fi

# base branch + merge-base (best-effort against common defaults / upstream)
base_branch=""
for cand in "$(g symbolic-ref --quiet refs/remotes/origin/HEAD | sed 's@.*/@@')" main master develop; do
  [ -n "$cand" ] || continue
  if g show-ref --verify --quiet "refs/heads/$cand" || g show-ref --verify --quiet "refs/remotes/origin/$cand"; then base_branch="$cand"; break; fi
done
merge_base_sha=""
[ -n "$base_branch" ] && merge_base_sha="$(g merge-base HEAD "$base_branch" 2>/dev/null || g merge-base HEAD "origin/$base_branch" 2>/dev/null)"

# in-progress operation (resolve via git-path so it works in linked worktrees)
in_progress_op="none"
if   [ -d "$(gp rebase-merge)" ] || [ -d "$(gp rebase-apply)" ]; then in_progress_op="rebase"
elif [ -f "$(gp MERGE_HEAD)" ]; then in_progress_op="merge"
elif [ -f "$(gp CHERRY_PICK_HEAD)" ]; then in_progress_op="cherry-pick"
elif [ -f "$(gp REVERT_HEAD)" ]; then in_progress_op="revert"
elif [ -f "$(gp BISECT_LOG)" ]; then in_progress_op="bisect"
fi

# counts
staged_count="$(g diff --cached --name-only | grep -c . )"; staged_count="${staged_count:-0}"
unstaged_count="$(g diff --name-only | grep -c . )"; unstaged_count="${unstaged_count:-0}"
untracked_count="$(g ls-files --others --exclude-standard | grep -c . )"; untracked_count="${untracked_count:-0}"
dirty_count="$(g status --porcelain | grep -c . )"; dirty_count="${dirty_count:-0}"

# diffstat totals only (never the diff body)
read -r ds_files ds_ins ds_del < <(g diff --shortstat HEAD 2>/dev/null | awk '
  { f=0;i=0;d=0; for(n=1;n<=NF;n++){ if($n ~ /^[0-9]+$/){ v=$n; if($(n+1) ~ /file/) f=v; else if($(n+1) ~ /insert/) i=v; else if($(n+1) ~ /delet/) d=v } } }
  END{ print f+0, i+0, d+0 }')
ds_files="${ds_files:-0}"; ds_ins="${ds_ins:-0}"; ds_del="${ds_del:-0}"

# arrays
dirty_paths_json="$( { g diff --name-only HEAD; g ls-files --others --exclude-standard; } | sort -u | arr_lines 50)"
last_commits_json="$(g log -15 --pretty=oneline --abbrev-commit --no-color | arr_lines 15)"
recent_branches_json="$(g for-each-ref --sort=-committerdate --count=30 --format='%(refname:short)' refs/heads/ | arr_lines 30)"
# Detailed inventory: per local branch -> last commit, ahead/behind base.
branches_detail_json="$(g for-each-ref --sort=-committerdate --count=30 \
  --format='%(refname:short)%09%(committerdate:iso-strict)%09%(authorname)%09%(subject)' refs/heads/ 2>/dev/null \
  | head -30 \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) | map({name:.[0], last_commit_utc:.[1], last_author:.[2], last_subject:.[3]})')"
[ -z "$branches_detail_json" ] && branches_detail_json="[]"
remote_branches_json="$(g for-each-ref --sort=-committerdate --count=30 --format='%(refname:short)' refs/remotes/origin/ 2>/dev/null | grep -v 'HEAD$' | arr_lines 30)"
[ -z "$remote_branches_json" ] && remote_branches_json="[]"
stash_count="$(g stash list | grep -c . )"; stash_count="${stash_count:-0}"
stash_msgs_json="$(g stash list --format='%gs' | arr_lines 10)"
submodules_json="$(g submodule status 2>/dev/null | awk '{print $2}' | arr_lines 30)"

# ---- peers (collaborators) ------------------------------------------------
# Unique authors across the last 200 commits + anyone tagged via Co-Authored-By.
# Bounded, no network. PR reviewers added later if `gh` is available.
peers_authors_json="$(g log -200 --format='%an <%ae>' 2>/dev/null | sort | uniq -c | sort -rn | head -20 \
  | awk '{count=$1; $1=""; sub(/^ /,""); printf "%s\t%d\n", $0, count}' \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) | map({who:.[0], commits:(.[1]|tonumber? // 0)})')"
[ -z "$peers_authors_json" ] && peers_authors_json="[]"
peers_coauth_json="$(g log -200 --format='%(trailers:key=Co-authored-by,valueonly=true,separator=%x0A)' 2>/dev/null \
  | grep -aE '<[^>]+>' | sort -u | head -20 | arr_lines 20)"
[ -z "$peers_coauth_json" ] && peers_coauth_json="[]"
worktrees_json="$(g worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}' | arr_lines 20)"

# ---- monorepo --------------------------------------------------------------
mono_tool="none"
[ -f "$REPO_ROOT/nx.json" ] && mono_tool="nx"
[ -f "$REPO_ROOT/turbo.json" ] && mono_tool="turbo"
[ -f "$REPO_ROOT/pnpm-workspace.yaml" ] && mono_tool="pnpm"
[ -f "$REPO_ROOT/lerna.json" ] && mono_tool="lerna"
{ [ -f "$REPO_ROOT/WORKSPACE" ] || [ -f "$REPO_ROOT/WORKSPACE.bazel" ]; } && mono_tool="bazel"
[ -f "$REPO_ROOT/pants.toml" ] && mono_tool="pants"

# ---- toolchain -------------------------------------------------------------
pkg_mgr="none"; lockfile=""
if   [ -f "$REPO_ROOT/pnpm-lock.yaml" ]; then pkg_mgr="pnpm"; lockfile="pnpm-lock.yaml"
elif [ -f "$REPO_ROOT/yarn.lock" ]; then pkg_mgr="yarn"; lockfile="yarn.lock"
elif [ -f "$REPO_ROOT/package-lock.json" ]; then pkg_mgr="npm"; lockfile="package-lock.json"
elif [ -f "$REPO_ROOT/bun.lockb" ]; then pkg_mgr="bun"; lockfile="bun.lockb"
elif [ -f "$REPO_ROOT/Cargo.lock" ]; then pkg_mgr="cargo"; lockfile="Cargo.lock"
elif [ -f "$REPO_ROOT/poetry.lock" ]; then pkg_mgr="poetry"; lockfile="poetry.lock"
elif [ -f "$REPO_ROOT/uv.lock" ]; then pkg_mgr="uv"; lockfile="uv.lock"
fi
lockfile_sha="$([ -n "$lockfile" ] && sha256_file "$REPO_ROOT/$lockfile" || echo "")"
languages_json="$( {
  [ -f "$REPO_ROOT/package.json" ] && echo javascript
  { [ -f "$REPO_ROOT/tsconfig.json" ] || ls "$REPO_ROOT"/*.ts >/dev/null 2>&1; } && echo typescript
  { [ -f "$REPO_ROOT/pyproject.toml" ] || [ -f "$REPO_ROOT/requirements.txt" ]; } && echo python
  [ -f "$REPO_ROOT/Cargo.toml" ] && echo rust
  [ -f "$REPO_ROOT/go.mod" ] && echo go
  { [ -f "$REPO_ROOT/Gemfile" ]; } && echo ruby
} | sort -u | arr_lines 12)"
devcontainer=false; [ -e "$REPO_ROOT/.devcontainer" ] && devcontainer=true
dockerfile=false; [ -f "$REPO_ROOT/Dockerfile" ] && dockerfile=true
node_v="$(command -v node >/dev/null 2>&1 && node -v 2>/dev/null || echo "")"
python_v="$(command -v python3 >/dev/null 2>&1 && python3 --version 2>/dev/null | awk '{print $2}' || echo "")"

# ---- codebase (structure, entry points, frameworks, routes, configs) -------
# Mechanical, bounded snapshot of *what this codebase looks like* so a resuming
# agent doesn't have to read src/ from scratch. Never reads .env*. Capped lists.

# 2-level dir tree, code-likely roots only
code_tree_json="$( ( cd "$REPO_ROOT" 2>/dev/null && \
  find . -mindepth 1 -maxdepth 2 -type d \
    \( -name '.git' -o -name 'node_modules' -o -name '.venv' -o -name 'venv' \
       -o -name '.vercel' -o -name 'dist' -o -name 'build' -o -name 'target' \
       -o -name 'vendor' -o -name 'graphify-out' -o -name '.sgnk' -o -name '.next' \
       -o -name 'site-packages' -o -name '__pycache__' -o -name '.pytest_cache' \
       -o -name '.mypy_cache' -o -name 'coverage' -o -name '.turbo' \
       -o -name '.cache' -o -name '.idea' -o -name '.vscode' \) -prune -o \
    -type d -print 2>/dev/null ) \
  | sed 's|^\./||' | grep -v '^\.$' | sort | head -60 | arr_lines 60)"
[ -z "$code_tree_json" ] && code_tree_json="[]"

# Top 10 modules by tracked file count. Mix of top-level files (e.g. app.py) and
# 2-deep dirs (e.g. apps/web) so flat repos and monorepos both surface honestly.
top_modules_json="$(g ls-files \
  | awk -F/ 'NF==1 {print $0; next} NF>1 {print $1"/"$2}' \
  | grep -vE '^(node_modules|\.venv|venv|dist|build|target|vendor|graphify-out|\.sgnk|\.next|\.vercel|site-packages|__pycache__|coverage|\.turbo|\.git)(/|$)' \
  | sort | uniq -c | sort -rn | head -10 \
  | awk '{c=$1; $1=""; sub(/^ /,""); printf "%s\t%d\n", $0, c}' \
  | jq -R -s 'split("\n")|map(select(length>0))|map(split("\t"))|map({path:.[0], files:(.[1]|tonumber? // 0)})')"
[ -z "$top_modules_json" ] && top_modules_json="[]"

# Frameworks detected from files (cheap presence checks)
frameworks_json="$( {
  { [ -f "$REPO_ROOT/next.config.js" ] || [ -f "$REPO_ROOT/next.config.ts" ] || [ -f "$REPO_ROOT/next.config.mjs" ]; } && echo nextjs
  { [ -f "$REPO_ROOT/vite.config.js" ] || [ -f "$REPO_ROOT/vite.config.ts" ]; } && echo vite
  [ -f "$REPO_ROOT/svelte.config.js" ] && echo sveltekit
  { [ -f "$REPO_ROOT/astro.config.mjs" ] || [ -f "$REPO_ROOT/astro.config.ts" ]; } && echo astro
  { [ -f "$REPO_ROOT/nuxt.config.ts" ] || [ -f "$REPO_ROOT/nuxt.config.js" ]; } && echo nuxt
  [ -f "$REPO_ROOT/remix.config.js" ] && echo remix
  [ -f "$REPO_ROOT/angular.json" ] && echo angular
  [ -d "$REPO_ROOT/src-tauri" ] && echo tauri
  [ -f "$REPO_ROOT/manage.py" ] && echo django
  { [ -f "$REPO_ROOT/pyproject.toml" ] && grep -q -i 'fastapi' "$REPO_ROOT/pyproject.toml" 2>/dev/null; } && echo fastapi
  { [ -f "$REPO_ROOT/requirements.txt" ] && grep -qi '^fastapi' "$REPO_ROOT/requirements.txt" 2>/dev/null; } && echo fastapi
  { [ -f "$REPO_ROOT/requirements.txt" ] && grep -qi '^flask' "$REPO_ROOT/requirements.txt" 2>/dev/null; } && echo flask
  [ -f "$REPO_ROOT/go.mod" ] && echo go
  { [ -f "$REPO_ROOT/Gemfile" ] && grep -q '^gem .rails.' "$REPO_ROOT/Gemfile" 2>/dev/null; } && echo rails
  [ -f "$REPO_ROOT/prisma/schema.prisma" ] && echo prisma
  { [ -f "$REPO_ROOT/drizzle.config.ts" ] || [ -f "$REPO_ROOT/drizzle.config.js" ]; } && echo drizzle
  [ -f "$REPO_ROOT/supabase/config.toml" ] && echo supabase
} | sort -u | arr_lines 12)"
[ -z "$frameworks_json" ] && frameworks_json="[]"

# Entry points from package.json
ep_main=""; ep_scripts_json="[]"; ep_bins_json="[]"
if [ -f "$REPO_ROOT/package.json" ]; then
  ep_main="$(jq -r '.main // empty' "$REPO_ROOT/package.json" 2>/dev/null)"
  ep_scripts_json="$(jq -c '(.scripts // {}) | to_entries | map({name:.key, cmd:.value}) | .[0:15]' "$REPO_ROOT/package.json" 2>/dev/null || echo '[]')"
  printf '%s' "$ep_scripts_json" | jq -e . >/dev/null 2>&1 || ep_scripts_json='[]'
  ep_bins_json="$(jq -c '(.bin // {}) | if type=="string" then {"_":.} else . end | to_entries | map({name:.key, path:.value}) | .[0:10]' "$REPO_ROOT/package.json" 2>/dev/null || echo '[]')"
  printf '%s' "$ep_bins_json" | jq -e . >/dev/null 2>&1 || ep_bins_json='[]'
fi

# Tauri config (bundle id + product name)
tauri_json='null'
for tc in src-tauri/tauri.conf.json tauri.conf.json; do
  if [ -f "$REPO_ROOT/$tc" ]; then
    tauri_json="$(jq -c --arg p "$tc" '{path:$p, identifier:(.identifier // .tauri.bundle.identifier // null), productName:(.productName // .package.productName // null), version:(.version // .package.version // null)}' "$REPO_ROOT/$tc" 2>/dev/null || echo 'null')"
    printf '%s' "$tauri_json" | jq -e . >/dev/null 2>&1 || tauri_json='null'
    break
  fi
done

# Python entry points (pyproject [project.scripts])
py_scripts_json='[]'
if [ -f "$REPO_ROOT/pyproject.toml" ]; then
  py_scripts_json="$(awk '
      /^\[project\.scripts\]/{f=1; next}
      /^\[/{f=0}
      f && /=/ { gsub(/[ \"\047]/,""); n=index($0,"="); if (n>0) print substr($0,1,n-1)"\t"substr($0,n+1) }
    ' "$REPO_ROOT/pyproject.toml" 2>/dev/null | head -10 \
    | jq -R -s 'split("\n")|map(select(length>0))|map(split("\t"))|map({name:.[0], cmd:.[1]})')"
  [ -z "$py_scripts_json" ] && py_scripts_json='[]'
fi

# Route files (cheap globs, capped)
routes_json="$( ( cd "$REPO_ROOT" 2>/dev/null && find app pages src/app src/pages src/routes \
    -type f \( -name 'page.tsx' -o -name 'page.ts' -o -name 'page.jsx' -o -name 'page.js' \
               -o -name 'route.ts' -o -name 'route.js' -o -name 'layout.tsx' \
               -o -name '+page.svelte' -o -name '+server.ts' \) 2>/dev/null ) \
  | sort -u | head -30 | arr_lines 30)"
[ -z "$routes_json" ] && routes_json="[]"

# Key configs present
configs_present_json="$( {
  for f in tsconfig.json next.config.ts next.config.js next.config.mjs \
           vite.config.ts vite.config.js tailwind.config.ts tailwind.config.js \
           prisma/schema.prisma drizzle.config.ts svelte.config.js astro.config.mjs \
           nuxt.config.ts remix.config.js angular.json pyproject.toml Cargo.toml \
           go.mod Gemfile manage.py vercel.json vercel.ts wrangler.toml \
           supabase/config.toml docker-compose.yml docker-compose.yaml \
           .github/workflows src-tauri/tauri.conf.json; do
    [ -e "$REPO_ROOT/$f" ] && echo "$f"
  done
} | sort -u | arr_lines 30)"
[ -z "$configs_present_json" ] && configs_present_json="[]"

# DB schema — prisma models (parse names + field counts), drizzle schema files,
# supabase migrations.
db_schema_json='null'
prisma_models_json='[]'
if [ -f "$REPO_ROOT/prisma/schema.prisma" ]; then
  prisma_models_json="$(awk '
      /^model[[:space:]]+/ { in_m=1; name=$2; fields=0; next }
      in_m && /^}/ { print name "\t" fields; in_m=0; next }
      in_m && /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]+/ && !/^[[:space:]]*\/\// && !/^[[:space:]]*@@/ { fields++ }
    ' "$REPO_ROOT/prisma/schema.prisma" 2>/dev/null \
    | head -40 \
    | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
                map({model:.[0], fields:(.[1]|tonumber? // 0)})')"
  [ -z "$prisma_models_json" ] && prisma_models_json='[]'
fi
drizzle_files_json="$( ( cd "$REPO_ROOT" 2>/dev/null && \
  find src/db src/schema drizzle src/drizzle db -type f \( -name 'schema.ts' -o -name 'schema.js' -o -name '*.schema.ts' \) 2>/dev/null ) \
  | sort -u | head -10 | arr_lines 10)"
[ -z "$drizzle_files_json" ] && drizzle_files_json='[]'
supabase_migrations="$( [ -d "$REPO_ROOT/supabase/migrations" ] && \
  ls -1 "$REPO_ROOT/supabase/migrations" 2>/dev/null | wc -l | tr -d ' ' || echo 0)"
supabase_migrations="${supabase_migrations:-0}"
db_schema_json="$(jq -n \
  --argjson prisma "$prisma_models_json" \
  --argjson drizzle "$drizzle_files_json" \
  --argjson supabase_count "$supabase_migrations" \
  '{
    prisma_models: $prisma,
    drizzle_schema_files: $drizzle,
    supabase_migrations: $supabase_count
   } | if (.prisma_models|length)==0 and (.drizzle_schema_files|length)==0 and .supabase_migrations==0 then null else . end')"
printf '%s' "$db_schema_json" | jq -e . >/dev/null 2>&1 || db_schema_json='null'

# env_groups deferred — req_env_json is populated by the runtime phase below;
# the actual computation happens after that, then is merged into codebase_json.
env_groups_json='[]'

# Convention docs — agent-readable rules at repo root. Each entry: path + first
# H1 (truncated). Lets recall point the resuming agent at them without reading.
convention_paths=$(for p in CLAUDE.md AGENTS.md GEMINI.md .windsurfrules \
                            .github/copilot-instructions.md .cursor/rules; do
  [ -e "$REPO_ROOT/$p" ] && echo "$p"
done)
convention_docs_json='[]'
if [ -n "$convention_paths" ]; then
  convention_docs_json="$(printf '%s\n' "$convention_paths" \
    | while IFS= read -r p; do
        [ -z "$p" ] && continue
        if [ -d "$REPO_ROOT/$p" ]; then
          # .cursor/rules — list files
          ( cd "$REPO_ROOT/$p" 2>/dev/null && ls -1 2>/dev/null | head -5 ) \
            | while IFS= read -r f; do
                [ -z "$f" ] && continue
                printf '%s/%s\t(rule file)\n' "$p" "$f"
              done
        else
          h1="$(awk '/^# / { sub(/^# /,""); print; exit }' "$REPO_ROOT/$p" 2>/dev/null | head -c 120)"
          [ -z "$h1" ] && h1="(no H1)"
          printf '%s\t%s\n' "$p" "$h1"
        fi
      done \
    | head -12 \
    | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
                map({path:.[0], h1:.[1]})')"
  [ -z "$convention_docs_json" ] && convention_docs_json='[]'
fi

# Top 15 prod dependencies — merge across language ecosystems present in the
# repo. Each entry tagged with `lang`. Falls back to devDependencies when
# `.dependencies` is empty (typical for monorepo roots). Capped 15 total.
top_deps_tmp="$(mktemp -t sgnk-deps.XXXXXX)"
if [ -f "$REPO_ROOT/package.json" ]; then
  pj_deps="$(jq -c '(.dependencies // {}) | to_entries | map({name:.key, version:.value, lang:"js"})' "$REPO_ROOT/package.json" 2>/dev/null || echo '[]')"
  if [ "$(printf '%s' "$pj_deps" | jq 'length' 2>/dev/null)" = "0" ]; then
    # monorepo root with empty .dependencies — show devDeps so the agent still
    # learns the toolchain (typescript, vitest, etc).
    pj_deps="$(jq -c '(.devDependencies // {}) | to_entries | map({name:.key, version:.value, lang:"js-dev"})' "$REPO_ROOT/package.json" 2>/dev/null || echo '[]')"
  fi
  printf '%s' "$pj_deps" | jq -c '.[]' >> "$top_deps_tmp" 2>/dev/null
fi
if [ -f "$REPO_ROOT/pyproject.toml" ]; then
  awk '
      /^\[project\]/ { in_p=1; next }
      /^\[/ { in_p=0 }
      in_p && /^dependencies[[:space:]]*=/ { in_d=1; next }
      in_d && /^[[:space:]]*\]/ { in_d=0; next }
      in_d && /[A-Za-z]/ { gsub(/[",\047[:space:]]/,""); if (length($0)>0) print $0 }
    ' "$REPO_ROOT/pyproject.toml" 2>/dev/null \
    | head -10 \
    | while IFS= read -r d; do jq -nc --arg n "$d" '{name:$n, version:null, lang:"py"}'; done \
    >> "$top_deps_tmp"
fi
if [ -f "$REPO_ROOT/requirements.txt" ]; then
  grep -avE '^[[:space:]]*(#|$)' "$REPO_ROOT/requirements.txt" 2>/dev/null \
    | sed 's/[<>=!~].*$//' | sed 's/[[:space:]]//g' | head -10 \
    | while IFS= read -r d; do
        [ -z "$d" ] && continue
        jq -nc --arg n "$d" '{name:$n, version:null, lang:"py"}'
      done \
    >> "$top_deps_tmp"
fi
if [ -f "$REPO_ROOT/Cargo.toml" ]; then
  awk '
      /^\[dependencies\]/ { in_d=1; next }
      /^\[/ { in_d=0 }
      in_d && /^[a-zA-Z]/ { sub(/[[:space:]]*=.*$/,""); print }
    ' "$REPO_ROOT/Cargo.toml" 2>/dev/null | head -10 \
    | while IFS= read -r d; do
        [ -z "$d" ] && continue
        jq -nc --arg n "$d" '{name:$n, version:null, lang:"rust"}'
      done \
    >> "$top_deps_tmp"
fi
top_deps_json="$(jq -s '.[0:15]' "$top_deps_tmp" 2>/dev/null)"
[ -z "$top_deps_json" ] && top_deps_json='[]'
printf '%s' "$top_deps_json" | jq -e . >/dev/null 2>&1 || top_deps_json='[]'
rm -f "$top_deps_tmp"

# ADRs — architectural decision records. Cheap detection.
adrs_json='[]'
for d in docs/adr docs/decisions docs/adrs adr; do
  if [ -d "$REPO_ROOT/$d" ]; then
    adrs_json="$( ( cd "$REPO_ROOT/$d" 2>/dev/null && ls -1 *.md 2>/dev/null ) \
      | head -15 \
      | while IFS= read -r f; do
          [ -z "$f" ] && continue
          h1="$(awk '/^# / { sub(/^# /,""); print; exit }' "$REPO_ROOT/$d/$f" 2>/dev/null | head -c 120)"
          [ -z "$h1" ] && h1="$f"
          printf '%s/%s\t%s\n' "$d" "$f" "$h1"
        done \
      | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
                  map({path:.[0], title:.[1]})')"
    [ -z "$adrs_json" ] && adrs_json='[]'
    break
  fi
done

# Test counts per top-module (so the agent knows which modules are tested).
# Joined into top_modules at assembly time.
tests_per_module_tmp="$(mktemp -t sgnk-tests.XXXXXX)"
g ls-files \
  | grep -aE '(test|spec)' \
  | grep -avE '(node_modules|\.venv|\.next|\.vercel|graphify-out|dist|build)' \
  | awk -F/ 'NF==1 {print $0; next} NF>1 {print $1"/"$2}' \
  | sort | uniq -c | sort -rn \
  | awk '{c=$1; $1=""; sub(/^ /,""); printf "%s\t%d\n", $0, c}' > "$tests_per_module_tmp"

# Description: package.json.description ?: first README paragraph
description=""
[ -f "$REPO_ROOT/package.json" ] && description="$(jq -r '.description // empty' "$REPO_ROOT/package.json" 2>/dev/null)"
if [ -z "$description" ]; then
  for f in README.md README.MD Readme.md readme.md README; do
    if [ -f "$REPO_ROOT/$f" ]; then
      description="$(awk '
          /^#/ {next}
          NF==0 { if (have) exit; next }
          { have=1; printf "%s ", $0 }
        ' "$REPO_ROOT/$f" 2>/dev/null | head -c 400 | sed 's/[[:space:]]*$//')"
      break
    fi
  done
fi

# Merge test counts into top_modules via a path → count lookup table
tests_per_module_json="$(jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
  map({path:.[0], tests:(.[1]|tonumber? // 0)})' < "$tests_per_module_tmp")"
[ -z "$tests_per_module_json" ] && tests_per_module_json='[]'
rm -f "$tests_per_module_tmp"
top_modules_json="$(jq -n --argjson modules "$top_modules_json" --argjson tests "$tests_per_module_json" \
  '($tests | map({(.path): .tests}) | add // {}) as $tlu
   | $modules | map(. + {tests: ($tlu[.path] // 0)})')"

codebase_json="$(jq -n \
  --argjson tree "$code_tree_json" \
  --argjson top_modules "$top_modules_json" \
  --argjson frameworks "$frameworks_json" \
  --arg ep_main "$ep_main" \
  --argjson ep_scripts "$ep_scripts_json" \
  --argjson ep_bins "$ep_bins_json" \
  --argjson tauri "$tauri_json" \
  --argjson py_scripts "$py_scripts_json" \
  --argjson routes "$routes_json" \
  --argjson configs "$configs_present_json" \
  --argjson db_schema "$db_schema_json" \
  --argjson env_groups "$env_groups_json" \
  --argjson convention_docs "$convention_docs_json" \
  --argjson top_deps "$top_deps_json" \
  --argjson adrs "$adrs_json" \
  --arg description "$description" \
  '{
    description: (if $description=="" then null else $description end),
    frameworks: $frameworks,
    tree: $tree,
    top_modules: $top_modules,
    entry_points: {
      package_main: (if $ep_main=="" then null else $ep_main end),
      package_scripts: $ep_scripts,
      package_bins: $ep_bins,
      tauri: $tauri,
      python_scripts: $py_scripts
    },
    db_schema: $db_schema,
    env_groups: $env_groups,
    convention_docs: $convention_docs,
    top_deps: $top_deps,
    adrs: $adrs,
    routes: $routes,
    configs_present: $configs
  }')"
printf '%s' "$codebase_json" | jq -e . >/dev/null 2>&1 || codebase_json='{}'

# ---- runtime (dev servers / ports) ----------------------------------------
# Use lsof -F (field-tagged) output — robust to command names containing spaces,
# unlike positional column parsing. One `p<pid>`/`c<cmd>` per process, then an
# `n<addr:port>` per listening socket.
#
# Only emit services whose process cwd is *inside* $REPO_ROOT — otherwise the
# snapshot fills with unrelated OS daemons (Electron, Logitech, Raycast, IDE
# helpers, etc.) that have nothing to do with this project's runtime.
services_json="[]"; ports_json="[]"
if command -v lsof >/dev/null 2>&1; then
  lsof_out="$(lsof -nP -iTCP -sTCP:LISTEN -Fcn 2>/dev/null)"
  if [ -n "$lsof_out" ]; then
    # Build raw triples (cmd, pid, port) for every listening socket.
    raw_triples="$(printf '%s\n' "$lsof_out" | awk '
        /^p/{pid=substr($0,2)} /^c/{cmd=substr($0,2)}
        /^n/{ name=substr($0,2); m=split(name,a,":"); printf "%s\t%s\t%s\n", cmd, pid, a[m] }' \
      | sort -u)"
    # Keep only triples whose PID's cwd resolves under $REPO_ROOT.
    project_triples=""
    if [ -n "$raw_triples" ]; then
      while IFS=$'\t' read -r _cmd _pid _port; do
        [ -z "$_pid" ] && continue
        pid_cwd="$(lsof -a -p "$_pid" -d cwd -Fn 2>/dev/null | awk '/^n/{print substr($0,2); exit}')"
        case "$pid_cwd" in
          "$REPO_ROOT"|"$REPO_ROOT"/*) project_triples="${project_triples}${_cmd}	${_pid}	${_port}
";;
        esac
      done <<EOF
$raw_triples
EOF
    fi
    if [ -n "$project_triples" ]; then
      services_json="$(printf '%s' "$project_triples" | sort -u | head -20 \
        | jq -R -s 'split("\n")|map(select(length>0))|map(split("\t"))|map({name:.[0], pid:(.[1]|tonumber? // .[1]), port:(.[2]|tonumber? // .[2]), status:"listening"})')"
      ports_json="$(printf '%s' "$project_triples" | awk -F'\t' '{print $3}' \
        | grep -E '^[0-9]+$' | sort -un | head -20 \
        | jq -R -s 'split("\n")|map(select(length>0))|map(tonumber)')"
    fi
  fi
fi
[ -z "$services_json" ] && services_json="[]"
[ -z "$ports_json" ] && ports_json="[]"

containers="none"
if command -v docker >/dev/null 2>&1; then
  dc="$(timeout 3 docker ps --format '{{.Names}}' 2>/dev/null | grep -c . )"; dc="${dc:-0}"
  [ "$dc" -gt 0 ] && containers="$dc running"
fi

# required_env: NAMES ONLY from a tracked example file. Never read real .env.
req_env_json="[]"
for f in .env.example .env.sample .env.template; do
  if [ -f "$REPO_ROOT/$f" ]; then
    req_env_json="$(grep -aoE '^[A-Za-z_][A-Za-z0-9_]*=' "$REPO_ROOT/$f" 2>/dev/null | sed 's/=$//' | sort -u | arr_lines 60)"
    break
  fi
done

# env_groups (deferred from the codebase phase — needs req_env_json from above).
# Buckets env vars by provider prefix (GITHUB_*, STRIPE_*, …) so the agent sees
# which services this app is wired to without parsing the raw list.
env_groups_json="$(printf '%s' "$req_env_json" | jq -c '
  if type=="array" and length>0 then
    reduce .[] as $v ({};
      ( $v | ascii_upcase | capture("^(?<p>[A-Z][A-Z0-9]*)_")? // {p:"_UNGROUPED"} ).p as $prefix
      | .[$prefix] = ((.[$prefix] // 0) + 1)
    )
    | to_entries | map({prefix:.key, count:.value}) | sort_by(-.count) | .[0:15]
  else [] end
' 2>/dev/null)"
[ -z "$env_groups_json" ] && env_groups_json='[]'
printf '%s' "$env_groups_json" | jq -e . >/dev/null 2>&1 || env_groups_json='[]'

# Patch codebase_json to include the now-computed env_groups (the earlier
# assembly used a placeholder []).
codebase_json="$(printf '%s' "$codebase_json" | jq --argjson eg "$env_groups_json" '.env_groups = $eg')"

# ---- contracts / migrations (names of files in flight) ---------------------
changed_now="$( { g diff --name-only HEAD; g ls-files --others --exclude-standard; } | sort -u )"
migration_files_json="$(echo "$changed_now" | grep -aiE '(migrations?|migrate)/' | arr_lines 20)"
api_schema_json="$(echo "$changed_now" | grep -aiE '\.(graphql|gql|proto|openapi\.(ya?ml|json))$|openapi|swagger' | arr_lines 20)"

# ---- transcript discovery (Claude Code session jsonl) ----------------------
# Claude stores each session's full jsonl under
#   ~/.claude/projects/$(echo $PWD | tr /. -)/<uuid>.jsonl
# (path mapping: every '/' and '.' becomes '-'). Pick the newest as the live
# session so /sgnk-recall can grep verbatim user prompts as ground truth when the
# narrative cards are thin. Best-effort, never fails.
transcript_path=""; transcript_lines=0; transcript_session=""
proj_san="$(printf '%s' "$REPO_ROOT" | tr '/.' '--')"
proj_dir="$HOME/.claude/projects/$proj_san"
if [ -d "$proj_dir" ]; then
  newest="$(ls -t "$proj_dir"/*.jsonl 2>/dev/null | head -1)"
  if [ -n "$newest" ] && [ -f "$newest" ]; then
    transcript_path="$newest"
    transcript_lines="$(wc -l < "$newest" 2>/dev/null | tr -d ' ')"
    case "$transcript_lines" in (''|*[!0-9]*) transcript_lines=0;; esac
    transcript_session="$(basename "$newest" .jsonl)"
  fi
fi

# ---- knowledge graph (graphify) -------------------------------------------
# Detection only (cheap/deterministic). Building/refresh is the skill body's job.
kg_cli=false; command -v graphify >/dev/null 2>&1 && kg_cli=true
kg_present=false; kg_stale=false; kg_report=""; kg_graph=""; kg_html=""; kg_built=""
GO="$REPO_ROOT/graphify-out"
if [ -f "$GO/graph.json" ]; then
  kg_present=true
  kg_graph="graphify-out/graph.json"
  [ -f "$GO/GRAPH_REPORT.md" ] && kg_report="graphify-out/GRAPH_REPORT.md"
  [ -f "$GO/graph.html" ] && kg_html="graphify-out/graph.html"
  g_mtime="$(stat -f %m "$GO/graph.json" 2>/dev/null || echo 0)"
  kg_built="$(date -u -r "${g_mtime:-0}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")"
  head_ct="$(g log -1 --format=%ct 2>/dev/null || echo 0)"
  case "$head_ct" in (''|*[!0-9]*) head_ct=0;; esac
  case "$g_mtime" in (''|*[!0-9]*) g_mtime=0;; esac
  [ "$head_ct" -gt "$g_mtime" ] && kg_stale=true   # code committed after graph was built
fi

# ---- auto-graphify: rebuild stale (or first-time) graph in full mode -------
# macOS has no `timeout` — run in background, poll PID with sleep. Cap controlled
# by SGNK_GRAPHIFY_TIMEOUT (default 30s stale-refresh, 60s first-build).
# Skip entirely if SGNK_NO_GRAPHIFY=1, mode=quick, or no graphify CLI.
if [ "${SGNK_NO_GRAPHIFY:-0}" != "1" ] && [ "$MODE" != "quick" ] && [ "$kg_cli" = "true" ]; then
  graphify_should_run=false; graphify_timeout=30
  if [ "$kg_present" = "true" ] && [ "$kg_stale" = "true" ]; then
    graphify_should_run=true; graphify_timeout="${SGNK_GRAPHIFY_TIMEOUT:-30}"
  elif [ "$kg_present" = "false" ]; then
    graphify_should_run=true; graphify_timeout="${SGNK_GRAPHIFY_TIMEOUT:-60}"
  fi
  if [ "$graphify_should_run" = "true" ]; then
    ( cd "$REPO_ROOT" && graphify update . >/dev/null 2>&1 ) &
    gpid=$!
    waited=0
    while kill -0 "$gpid" 2>/dev/null && [ "$waited" -lt "$graphify_timeout" ]; do
      sleep 1; waited=$((waited+1))
    done
    if kill -0 "$gpid" 2>/dev/null; then
      kill -9 "$gpid" 2>/dev/null || true
      # leave kg_stale=true so the resuming agent knows the graph wasn't refreshed
    else
      # Rebuilt; re-detect outputs
      if [ -f "$GO/graph.json" ]; then
        kg_present=true; kg_graph="graphify-out/graph.json"; kg_stale=false
        [ -f "$GO/GRAPH_REPORT.md" ] && kg_report="graphify-out/GRAPH_REPORT.md"
        [ -f "$GO/graph.html" ] && kg_html="graphify-out/graph.html"
        g_mtime="$(stat -f %m "$GO/graph.json" 2>/dev/null || echo 0)"
        kg_built="$(date -u -r "${g_mtime:-0}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")"
      fi
    fi
    unset gpid waited graphify_should_run graphify_timeout
  fi
fi

# ---- remote (skippable, time-boxed) ---------------------------------------
remote_json='{"enabled":false}'
if [ "$MODE" = "full" ] && [ "${SGNK_NO_REMOTE:-0}" != "1" ] && command -v gh >/dev/null 2>&1; then
  if run_to "$GH_TIMEOUT" gh auth status >/dev/null 2>&1; then
    prs="$(run_to "$GH_TIMEOUT" gh pr list --state open --limit 10 \
      --json number,title,headRefName,isDraft,mergeable,reviewDecision 2>/dev/null || echo '[]')"
    printf '%s' "$prs" | jq -e . >/dev/null 2>&1 || prs='[]'   # never feed argjson garbage
    ci_status="$(run_to "$GH_TIMEOUT" gh pr checks --json state -q '[.[].state] | join(",")' 2>/dev/null || echo "")"
    issues="$(run_to "$GH_TIMEOUT" gh issue list --state open --limit 10 \
      --json number,title,labels 2>/dev/null || echo '[]')"
    printf '%s' "$issues" | jq -e . >/dev/null 2>&1 || issues='[]'
    runs="$(run_to "$GH_TIMEOUT" gh run list --limit 5 \
      --json status,conclusion,workflowName,displayTitle,createdAt 2>/dev/null || echo '[]')"
    printf '%s' "$runs" | jq -e . >/dev/null 2>&1 || runs='[]'
    remote_json="$(jq -n --argjson prs "$prs" --arg ci "$ci_status" \
      --argjson issues "$issues" --argjson runs "$runs" \
      '{enabled:true, open_prs:$prs, ci:{status:$ci}, open_issues:$issues, recent_runs:$runs}')"
    printf '%s' "$remote_json" | jq -e . >/dev/null 2>&1 || remote_json='{"enabled":false}'
  fi
fi

# ---- assemble manifest with a single jq -n (all values safely escaped) -----
tmp="$OUT_DIR/.manifest.json.tmp.$$"
jq -n \
  --arg id "$id_val" \
  --arg utc "$now_utc" \
  --arg mode "$MODE" \
  --arg tool "$prov_tool" --arg account "$prov_account" --arg host "$prov_host" \
  --arg user "$prov_user" --arg os "$prov_os" \
  --arg repo_root "$REPO_ROOT" --argjson is_worktree "$is_worktree" --arg worktree_path "$worktree_path" \
  --argjson worktrees "$worktrees_json" --argjson submodules "$submodules_json" \
  --arg branch "$branch" --arg head_sha "$head_sha" --arg upstream "$upstream" \
  --argjson ahead "$ahead" --argjson behind "$behind" \
  --arg base_branch "$base_branch" --arg merge_base_sha "${merge_base_sha:-}" \
  --arg in_progress_op "$in_progress_op" \
  --argjson dirty_count "$dirty_count" --argjson staged_count "$staged_count" --argjson untracked_count "$untracked_count" \
  --argjson ds_files "$ds_files" --argjson ds_ins "$ds_ins" --argjson ds_del "$ds_del" \
  --argjson dirty_paths "$dirty_paths_json" --argjson recent_branches "$recent_branches_json" \
  --argjson branches_detail "$branches_detail_json" --argjson remote_branches "$remote_branches_json" \
  --argjson peers_authors "$peers_authors_json" --argjson peers_coauth "$peers_coauth_json" \
  --argjson stash_count "$stash_count" --argjson stash_msgs "$stash_msgs_json" \
  --argjson last_commits "$last_commits_json" \
  --arg mono_tool "$mono_tool" \
  --argjson languages "$languages_json" --arg pkg_mgr "$pkg_mgr" \
  --arg node_v "$node_v" --arg python_v "$python_v" \
  --arg lockfile "$lockfile" --arg lockfile_sha "$lockfile_sha" \
  --argjson devcontainer "$devcontainer" --argjson dockerfile "$dockerfile" \
  --argjson services "$services_json" --argjson ports "$ports_json" --arg containers "$containers" \
  --argjson required_env "$req_env_json" \
  --argjson migration_files "$migration_files_json" --argjson api_schema "$api_schema_json" \
  --argjson kg_cli "$kg_cli" --argjson kg_present "$kg_present" --argjson kg_stale "$kg_stale" \
  --arg kg_report "$kg_report" --arg kg_graph "$kg_graph" --arg kg_html "$kg_html" --arg kg_built "$kg_built" \
  --arg transcript_path "$transcript_path" --argjson transcript_lines "$transcript_lines" \
  --arg transcript_session "$transcript_session" \
  --argjson remote "$remote_json" \
  --argjson codebase "$codebase_json" \
  '{
    schema_version: 3,
    id: $id, utc: $utc, mode: $mode,
    provenance: {tool:$tool, account:$account, agent_id:null, host:$host, user:$user, os:$os},
    vcs: {
      repo_root:$repo_root, is_worktree:$is_worktree, worktree_path:$worktree_path,
      worktrees:$worktrees, submodules:$submodules,
      branch:$branch, head_sha:$head_sha, upstream:$upstream, ahead:$ahead, behind:$behind,
      base_branch:$base_branch, merge_base_sha:$merge_base_sha, in_progress_op:$in_progress_op,
      dirty_count:$dirty_count, staged_count:$staged_count, untracked_count:$untracked_count,
      diffstat:{files:$ds_files, insertions:$ds_ins, deletions:$ds_del},
      dirty_paths_top:$dirty_paths, recent_branches:$recent_branches,
      branches_detail:$branches_detail, remote_branches:$remote_branches,
      stashes:{count:$stash_count, messages:$stash_msgs}, last_commits:$last_commits
    },
    peers: {authors:$peers_authors, co_authored:$peers_coauth},
    monorepo: {tool:$mono_tool, changed_targets:[]},
    toolchain: {
      languages:$languages, package_manager:$pkg_mgr,
      runtime_versions:{node:$node_v, python:$python_v},
      lockfile:$lockfile, lockfile_sha256:$lockfile_sha,
      devcontainer:$devcontainer, dockerfile:$dockerfile
    },
    codebase: $codebase,
    runtime: {services:$services, ports_in_use:$ports, background_jobs:[], containers:$containers, required_env:$required_env},
    dependencies: {dep_drift:false, pending_migrations:$migration_files, feature_flags_changed:[]},
    contracts: {api_schema_files_in_flight:$api_schema, migration_files:$migration_files},
    knowledge_graph: {
      tool:"graphify", cli_available:$kg_cli, present:$kg_present, dir:"graphify-out",
      report:(if $kg_report=="" then null else $kg_report end),
      graph_json:(if $kg_graph=="" then null else $kg_graph end),
      html:(if $kg_html=="" then null else $kg_html end),
      built_utc:(if $kg_built=="" then null else $kg_built end),
      stale:$kg_stale
    },
    verify: {
      gates:{lint:null,typecheck:null,test:null,build:null},
      focused_verify_cmd:null,
      last_test_run:{cmd:null,passed:null,failed:null,failing_tests:[],coverage_delta:null}
    },
    remote: $remote,
    session_activity: {commands_run:[], last_error:null, last_focus:null},
    refs: {
      tickets:[],
      transcript_path:(if $transcript_path=="" then null else $transcript_path end),
      transcript_lines:$transcript_lines,
      transcript_session:(if $transcript_session=="" then null else $transcript_session end),
      related_docs:[], links:[]
    }
  }' > "$tmp" || die "manifest assembly failed"

# atomic publish + self-check
mv -f "$tmp" "$OUT_DIR/manifest.json"
jq . "$OUT_DIR/manifest.json" >/dev/null 2>&1 || die "produced manifest is not valid JSON"

# Always emit the mechanical narrative cards (01..05). Idempotent: existing cards
# (e.g. a model-authored richer 02-tasks.md) are not overwritten. The derive step
# is also called here so 05 has feature-clusters / branch-diffstats / TODOs even
# when the caller doesn't explicitly invoke sgnk-derive.sh.
DERIVE_SH="$(dirname "$0")/sgnk-derive.sh"
WRITE_CARDS_SH="$(dirname "$0")/sgnk-write-cards.sh"
if [ -f "$DERIVE_SH" ] && [ ! -f "$OUT_DIR/derived.json" ]; then
  bash "$DERIVE_SH" "$REPO_ROOT" "$OUT_DIR/manifest.json" > "$OUT_DIR/derived.json.tmp" 2>/dev/null \
    && mv -f "$OUT_DIR/derived.json.tmp" "$OUT_DIR/derived.json" \
    || rm -f "$OUT_DIR/derived.json.tmp"
fi
[ -f "$WRITE_CARDS_SH" ] && bash "$WRITE_CARDS_SH" "$OUT_DIR" "$REPO_ROOT" >/dev/null 2>&1 || true

echo "$OUT_DIR/manifest.json"
