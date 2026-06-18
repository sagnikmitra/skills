#!/usr/bin/env bash
# sgnk-write-cards.sh — mechanical narrative-card writer for a snapshot.
#
# Reads <OUT_DIR>/manifest.json (and <OUT_DIR>/derived.json if present, else
# computes it via sgnk-derive.sh) and emits the always-present cards:
#
#   01-context.md             — frameworks, stack, configs, ADRs, convention docs
#   02-tasks.md               — verbatim user prompts from the Claude Code
#                                transcript jsonl + recent commits + branches/peers
#                                + TODOs (the mechanical floor for "what was
#                                this session about").
#   03-runtime.md             — services, ports, required env names, restart
#                                commands inferred from package_scripts.
#   04-codebase.md            — what-app-does + frameworks + top modules + tree
#                                + top deps + entry points + routes + db schema
#                                + env groups + convention docs + ADRs + configs.
#   05-features-and-issues.md — feature thrust + branches in flight + CI + open
#                                PRs/issues + TODOs + recent diffs.
#
# Behavior:
#   * Idempotent: cards that already exist are LEFT ALONE — so a model that
#     wrote a richer 02-tasks.md for a live session is never overwritten.
#   * --force: rebuild all cards regardless of what's on disk (used by recall
#     auto-heal when it detects a thin snapshot, or when explicitly rebuilding).
#   * Cheap: never reads .env*, never invokes the model, never makes network
#     calls. All inputs are the manifest + derived.json + the transcript jsonl
#     referenced in manifest.refs.transcript_path.
#
# Usage: sgnk-write-cards.sh <OUT_DIR> <REPO_ROOT> [--force]
set -uo pipefail

OUT_DIR="${1:-}"; REPO_ROOT="${2:-}"; FORCE_FLAG="${3:-}"
die() { echo "sgnk-write-cards: $*" >&2; exit 1; }
log() { :; }   # silent by default; flip to 'echo "$@" >&2' to debug

[ -n "$OUT_DIR" ] && [ -d "$OUT_DIR" ] || die "OUT_DIR missing: $OUT_DIR"
[ -n "$REPO_ROOT" ] && [ -d "$REPO_ROOT" ] || die "REPO_ROOT missing: $REPO_ROOT"
# Prefer manifest-current.json (written by recall auto-heal against today's repo
# state). Falls back to the historical manifest.json. Lets old thin archives heal
# while the original archive manifest stays untouched.
if [ -f "$OUT_DIR/manifest-current.json" ]; then
  MAN="$OUT_DIR/manifest-current.json"
else
  MAN="$OUT_DIR/manifest.json"
fi
[ -f "$MAN" ] || die "no manifest.json in $OUT_DIR"
command -v jq >/dev/null 2>&1 || die "jq required"
FORCE=0; [ "$FORCE_FLAG" = "--force" ] && FORCE=1

# derived.json — compute if absent (cheap; bounded git log + grep)
DER="$OUT_DIR/derived.json"
if [ ! -f "$DER" ]; then
  DERIVE_SH="$(dirname "$0")/sgnk-derive.sh"
  if [ -f "$DERIVE_SH" ]; then
    bash "$DERIVE_SH" "$REPO_ROOT" "$MAN" > "$DER.tmp" 2>/dev/null \
      && mv -f "$DER.tmp" "$DER" || { rm -f "$DER.tmp"; echo '{}' > "$DER"; }
  else
    echo '{}' > "$DER"
  fi
fi

# Atomic-ish write helper. Skips when target exists unless FORCE=1.
emit() { # <relpath>  (stdin -> file)
  local rel="$1" dest="$OUT_DIR/$1" tmp
  if [ -f "$dest" ] && [ "$FORCE" -ne 1 ]; then
    log "skip (exists): $rel"
    cat > /dev/null
    return 0
  fi
  tmp="$dest.tmp.$$"
  cat > "$tmp" && mv -f "$tmp" "$dest"
}

# convenience JSON extractors
mj() { jq -r "$1 // \"\"" "$MAN" 2>/dev/null; }
mjq() { jq -c "$1 // []" "$MAN" 2>/dev/null; }
dj() { jq -r "$1 // \"\"" "$DER" 2>/dev/null; }
djq() { jq -c "$1 // []" "$DER" 2>/dev/null; }

ID="$(mj .id)"; HEAD="$(mj .vcs.head_sha)"; BR="$(mj .vcs.branch)"
UTC="$(mj .utc)"; MODE="$(mj .mode)"

# yaml header used on every card we write here
yaml_header() { # <kind>
  printf -- '---\nid: %s\nhead_sha: %s\nbranch: %s\nutc: %s\nkind: %s\n---\n\n' \
    "$ID" "$HEAD" "$BR" "$UTC" "$1"
}

# ──────────────────────────────────────────────────────────────────────────────
# 04-codebase.md  — pure manifest.codebase render. The structural card.
# ──────────────────────────────────────────────────────────────────────────────
{
  yaml_header "codebase-derived"
  printf '# Codebase you are inheriting\n\n'

  desc="$(mj .codebase.description)"
  if [ -n "$desc" ] && [ "$desc" != "null" ]; then
    printf '## What this app does\n%s\n\n' "$desc"
  fi

  printf '## Frameworks & stack\n'
  fw="$(mjq .codebase.frameworks | jq -r 'join(", ")' 2>/dev/null)"
  langs="$(mjq .toolchain.languages | jq -r 'join(", ")' 2>/dev/null)"
  pm="$(mj .toolchain.package_manager)"
  nv="$(mj .toolchain.runtime_versions.node)"; pv="$(mj .toolchain.runtime_versions.python)"
  [ -n "$fw" ]    && printf -- '- Frameworks: %s\n' "$fw"
  [ -n "$langs" ] && printf -- '- Languages: %s\n' "$langs"
  [ -n "$pm" ]    && [ "$pm" != "none" ] && printf -- '- Package manager: %s\n' "$pm"
  [ -n "$nv" ]    && printf -- '- Node: %s\n' "$nv"
  [ -n "$pv" ]    && printf -- '- Python: %s\n' "$pv"
  printf '\n'

  printf '## Top modules (by file count, with tests)\n'
  jq -r '.codebase.top_modules[]? | "- `\(.path)` — \(.files) files, \(.tests // 0) tests"' "$MAN" 2>/dev/null
  printf '\n'

  printf '## Tree (2 levels)\n```\n'
  jq -r '.codebase.tree[]?' "$MAN" 2>/dev/null
  printf '```\n\n'

  printf '## Top dependencies\n'
  jq -r '.codebase.top_deps[]? | "- `\(.name)` \(if .version then "@ \(.version) " else "" end)(\(.lang))"' "$MAN" 2>/dev/null
  printf '\n'

  printf '## Entry points\n'
  scripts_count="$(mjq .codebase.entry_points.package_scripts | jq 'length' 2>/dev/null)"
  if [ "${scripts_count:-0}" -gt 0 ]; then
    printf '### Package scripts\n'
    jq -r '.codebase.entry_points.package_scripts[]? | "- `\(.name)` → `\(.cmd)`"' "$MAN" 2>/dev/null
    printf '\n'
  fi
  py_count="$(mjq .codebase.entry_points.python_scripts | jq 'length' 2>/dev/null)"
  if [ "${py_count:-0}" -gt 0 ]; then
    printf '### Python entry points\n'
    jq -r '.codebase.entry_points.python_scripts[]? | "- `\(.name)` → `\(.cmd)`"' "$MAN" 2>/dev/null
    printf '\n'
  fi
  ep_main="$(mj .codebase.entry_points.package_main)"
  if [ -n "$ep_main" ] && [ "$ep_main" != "null" ]; then
    printf '### package.json main\n- `%s`\n\n' "$ep_main"
  fi
  tauri_id="$(mj .codebase.entry_points.tauri.identifier)"
  if [ -n "$tauri_id" ] && [ "$tauri_id" != "null" ]; then
    tauri_prod="$(mj .codebase.entry_points.tauri.productName)"
    tauri_ver="$(mj .codebase.entry_points.tauri.version)"
    printf '### Tauri\n- identifier: `%s`\n- product: %s\n- version: %s\n\n' \
      "$tauri_id" "$tauri_prod" "$tauri_ver"
  fi

  routes_count="$(mjq .codebase.routes | jq 'length' 2>/dev/null)"
  if [ "${routes_count:-0}" -gt 0 ]; then
    printf '## Routes / public surface\n'
    jq -r '.codebase.routes[]? | "- `\(.)`"' "$MAN" 2>/dev/null
    printf '\n'
  else
    printf '## Routes / public surface\nNo route files detected.\n\n'
  fi

  has_db="$(jq -r '.codebase.db_schema | if . == null then "no" else "yes" end' "$MAN" 2>/dev/null)"
  if [ "$has_db" = "yes" ]; then
    printf '## DB schema\n'
    pmc="$(jq '.codebase.db_schema.prisma_models | length' "$MAN" 2>/dev/null)"
    if [ "${pmc:-0}" -gt 0 ]; then
      printf '### Prisma models\n'
      jq -r '.codebase.db_schema.prisma_models[]? | "- `\(.model)` (\(.fields) fields)"' "$MAN" 2>/dev/null
      printf '\n'
    fi
    dsc="$(jq '.codebase.db_schema.drizzle_schema_files | length' "$MAN" 2>/dev/null)"
    if [ "${dsc:-0}" -gt 0 ]; then
      printf '### Drizzle schema files\n'
      jq -r '.codebase.db_schema.drizzle_schema_files[]? | "- `\(.)`"' "$MAN" 2>/dev/null
      printf '\n'
    fi
    smc="$(mj .codebase.db_schema.supabase_migrations)"
    if [ -n "$smc" ] && [ "$smc" != "0" ] && [ "$smc" != "null" ]; then
      printf '### Supabase migrations\n- %s migration files in `supabase/migrations/`\n\n' "$smc"
    fi
  fi

  egc="$(mjq .codebase.env_groups | jq 'length' 2>/dev/null)"
  if [ "${egc:-0}" -gt 0 ]; then
    printf '## External services (env-prefix groups)\n'
    jq -r '.codebase.env_groups[]? | "- `\(.prefix)_*` (\(.count) vars)"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  reqc="$(mjq .runtime.required_env | jq 'length' 2>/dev/null)"
  if [ "${reqc:-0}" -gt 0 ]; then
    printf '## Required env (names only)\n'
    jq -r '.runtime.required_env | join(", ")' "$MAN" 2>/dev/null
    printf '\n\n'
  fi

  conv_c="$(mjq .codebase.convention_docs | jq 'length' 2>/dev/null)"
  if [ "${conv_c:-0}" -gt 0 ]; then
    printf '## Convention docs (READ THESE)\n'
    jq -r '.codebase.convention_docs[]? | "- `\(.path)` — \(.h1)"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  adr_c="$(mjq .codebase.adrs | jq 'length' 2>/dev/null)"
  if [ "${adr_c:-0}" -gt 0 ]; then
    printf '## ADRs\n'
    jq -r '.codebase.adrs[]? | "- `\(.path)` — \(.title)"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  cfg_c="$(mjq .codebase.configs_present | jq 'length' 2>/dev/null)"
  if [ "${cfg_c:-0}" -gt 0 ]; then
    printf '## Key configs present\n'
    jq -r '.codebase.configs_present | join(", ")' "$MAN" 2>/dev/null
    printf '\n\n'
  fi

  kg_present="$(mj .knowledge_graph.present)"
  if [ "$kg_present" = "true" ]; then
    printf '## Knowledge graph (graphify)\n'
    printf -- '- Built: %s%s\n' "$(mj .knowledge_graph.built_utc)" "$([ "$(mj .knowledge_graph.stale)" = "true" ] && echo ' (STALE — head moved since build)' || echo '')"
    printf -- '- Report: `%s`\n' "$(mj .knowledge_graph.report)"
    printf -- '- Graph: `%s`\n' "$(mj .knowledge_graph.graph_json)"
    printf -- '- Query: `graphify query "<question>"`  ·  `graphify explain "Symbol"`  ·  `graphify path "A" "B"`\n\n'
  fi
} | emit "04-codebase.md"

# ──────────────────────────────────────────────────────────────────────────────
# 05-features-and-issues.md  — what's in flight + what hurts
# ──────────────────────────────────────────────────────────────────────────────
{
  yaml_header "features-issues-derived"
  printf '# Features in flight & open issues\n\n'

  fcc="$(djq .feature_clusters | jq 'length' 2>/dev/null)"
  if [ "${fcc:-0}" -gt 0 ]; then
    printf '## Current feature thrust (top dirs by commit count, last 30 commits)\n'
    jq -r '.feature_clusters[]? | "### `\(.dir)` — \(.commit_count) commits\n" + ((.recent_subjects // []) | map("- " + .) | join("\n"))' "$DER" 2>/dev/null
    printf '\n\n'
  fi

  bdc="$(djq .branch_diffstats.entries | jq 'length' 2>/dev/null)"
  if [ "${bdc:-0}" -gt 0 ]; then
    printf '## Branches in flight (vs `%s`)\n' "$(dj .branch_diffstats.base)"
    jq -r '.branch_diffstats.entries[]? | "- `\(.branch)`: \(.vs_base)"' "$DER" 2>/dev/null
    printf '\n'
  fi

  rrc="$(mjq .remote.recent_runs | jq 'length' 2>/dev/null)"
  if [ "${rrc:-0}" -gt 0 ]; then
    printf '## Recent CI runs (latest 5)\n'
    jq -r '.remote.recent_runs[]? | "- [\(.status)/\(.conclusion // "—")] **\(.workflowName)** — \(.displayTitle)  ·  \(.createdAt)"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  prc="$(mjq .remote.open_prs | jq 'length' 2>/dev/null)"
  if [ "${prc:-0}" -gt 0 ]; then
    printf '## Open PRs\n'
    jq -r '.remote.open_prs[]? | "- #\(.number) **\(.title)** — `\(.headRefName)`\(if .isDraft then " (draft)" else "" end)\(if .reviewDecision then " · review: \(.reviewDecision)" else "" end)"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  isc="$(mjq .remote.open_issues | jq 'length' 2>/dev/null)"
  if [ "${isc:-0}" -gt 0 ]; then
    printf '## Open issues\n'
    jq -r '.remote.open_issues[]? | "- #\(.number) **\(.title)**\(if .labels and (.labels|length>0) then " — " + ((.labels // []) | map(.name) | join(", ")) else "" end)"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  tdc="$(djq .todos_sample | jq 'length' 2>/dev/null)"
  if [ "${tdc:-0}" -gt 0 ]; then
    printf '## TODO / FIXME sample (excludes vendored deps)\n'
    jq -r '.todos_sample[]? | "- `\(.)`"' "$DER" 2>/dev/null
    printf '\n'
  fi

  rdc="$(djq .recent_diffs | jq 'length' 2>/dev/null)"
  if [ "${rdc:-0}" -gt 0 ]; then
    printf '## Last 5 commits (diff highlights)\n'
    jq -r '.recent_diffs[]? | "- `\(.sha)` \(.subject) — \(.stat // "")"' "$DER" 2>/dev/null
    printf '\n'
  fi
} | emit "05-features-and-issues.md"

# ──────────────────────────────────────────────────────────────────────────────
# 03-runtime.md  — write only if services or required_env are non-empty
# ──────────────────────────────────────────────────────────────────────────────
svc_count="$(mjq .runtime.services | jq 'length' 2>/dev/null)"
env_count="$(mjq .runtime.required_env | jq 'length' 2>/dev/null)"
if [ "${svc_count:-0}" -gt 0 ] || [ "${env_count:-0}" -gt 0 ]; then
  {
    yaml_header "runtime-derived"
    printf '# Runtime — services & restart steps\n\n'

    if [ "${svc_count:-0}" -gt 0 ]; then
      printf '## Listening services (in this repo, at snapshot time)\n'
      jq -r '.runtime.services[]? | "- `\(.name)` pid \(.pid) port \(.port) — \(.status)"' "$MAN" 2>/dev/null
      printf '\n'
    fi

    cntrs="$(mj .runtime.containers)"
    if [ -n "$cntrs" ] && [ "$cntrs" != "none" ] && [ "$cntrs" != "null" ]; then
      printf '## Docker\n- %s\n\n' "$cntrs"
    fi

    if [ "${env_count:-0}" -gt 0 ]; then
      printf '## Required env (names only — read `.env.example` for values)\n'
      jq -r '.runtime.required_env[]? | "- `\(.)`"' "$MAN" 2>/dev/null
      printf '\n'
    fi

    printf '## Likely restart commands\n'
    has_pkg_scripts="$(jq '.codebase.entry_points.package_scripts | length' "$MAN" 2>/dev/null)"
    if [ "${has_pkg_scripts:-0}" -gt 0 ]; then
      printf -- '- `'
      pm="$(mj .toolchain.package_manager)"; [ "$pm" = "none" ] && pm="npm"
      printf '%s run dev`' "$pm"
      printf '   (or `start`/`build` — see 04-codebase.md → Entry points)\n'
    fi
    if jq -e '.codebase.entry_points.python_scripts | length > 0' "$MAN" >/dev/null 2>&1; then
      printf -- '- Python entry points listed in 04-codebase.md\n'
    fi
    if [ "$(mj .toolchain.dockerfile)" = "true" ]; then
      printf -- '- Dockerfile present — `docker compose up` if compose file exists\n'
    fi
    printf '\n'
  } | emit "03-runtime.md"
fi

# ──────────────────────────────────────────────────────────────────────────────
# 01-context.md  — frameworks, decisions, gotchas, navigation pointer
# ──────────────────────────────────────────────────────────────────────────────
{
  yaml_header "context-derived"
  printf '# Project context\n\n'

  desc="$(mj .codebase.description)"
  [ -n "$desc" ] && [ "$desc" != "null" ] && printf '## At a glance\n%s\n\n' "$desc"

  printf '## Key technical concepts\n'
  fw="$(mjq .codebase.frameworks | jq -r 'join(", ")' 2>/dev/null)"
  langs="$(mjq .toolchain.languages | jq -r 'join(", ")' 2>/dev/null)"
  [ -n "$fw" ] && [ "$fw" != "" ] && printf -- '- Frameworks: %s\n' "$fw"
  [ -n "$langs" ] && [ "$langs" != "" ] && printf -- '- Languages: %s\n' "$langs"
  egc="$(mjq .codebase.env_groups | jq 'length' 2>/dev/null)"
  if [ "${egc:-0}" -gt 0 ]; then
    printf -- '- External integrations (env-prefix detected): '
    jq -r '.codebase.env_groups[]? | "\(.prefix)"' "$MAN" 2>/dev/null | paste -sd ", " -
    printf '\n'
  fi
  printf '\n'

  printf '## README head (first 50 lines)\n'
  readme="$(dj .project.readme_head)"
  if [ -n "$readme" ] && [ "$readme" != "null" ]; then
    printf '%s\n' "$readme"
  else
    printf '(no README detected)\n'
  fi
  printf '\n'

  conv_c="$(mjq .codebase.convention_docs | jq 'length' 2>/dev/null)"
  if [ "${conv_c:-0}" -gt 0 ]; then
    printf '## Read these convention docs before editing\n'
    jq -r '.codebase.convention_docs[]? | "- `\(.path)`"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  adr_c="$(mjq .codebase.adrs | jq 'length' 2>/dev/null)"
  if [ "${adr_c:-0}" -gt 0 ]; then
    printf '## Architectural decisions on file\n'
    jq -r '.codebase.adrs[]? | "- `\(.path)` — \(.title)"' "$MAN" 2>/dev/null
    printf '\n'
  fi

  printf '## Navigation\n'
  printf -- '- Codebase structure → `04-codebase.md`\n'
  printf -- '- Features in flight + PRs/issues → `05-features-and-issues.md`\n'
  printf -- '- Verbatim user prompts + session log → `02-tasks.md`\n'
  if [ "${svc_count:-0}" -gt 0 ] || [ "${env_count:-0}" -gt 0 ]; then
    printf -- '- Runtime restart → `03-runtime.md`\n'
  fi
  kg_present="$(mj .knowledge_graph.present)"
  [ "$kg_present" = "true" ] && printf -- '- Knowledge graph → `%s` · `graphify query "<q>"`\n' "$(mj .knowledge_graph.report)"
  printf '\n'
} | emit "01-context.md"

# ──────────────────────────────────────────────────────────────────────────────
# 02-tasks.md  — the highest-signal card. Verbatim user prompts + branches/
# peers/TODOs/recent work. Lead with user prompts when transcript is available.
# ──────────────────────────────────────────────────────────────────────────────
{
  TR_PATH="$(mj .refs.transcript_path)"
  TR_LINES="$(mj .refs.transcript_lines)"; case "$TR_LINES" in (''|*[!0-9]*) TR_LINES=0;; esac

  # Decide kind. Live transcript (>= 50 lines) → "live-derived" — has user prompts.
  # Thin (< 50) or absent → "derived-stub" — pure mechanical, no prompts.
  if [ -n "$TR_PATH" ] && [ -f "$TR_PATH" ] && [ "$TR_LINES" -ge 50 ]; then
    kind="live-derived"
  else
    kind="derived-stub"
  fi

  yaml_header "$kind"
  printf '# Session log (mechanical floor)\n\n'

  if [ "$kind" = "live-derived" ]; then
    printf '## 1. Verbatim user prompts (most recent first, transcript jsonl)\n\n'
    # Extract text content from each user-typed message. Filters out:
    #   * isMeta=true entries (skill bodies / harness-injected content)
    #   * content that begins with <command-message> or <command-name> (the
    #     slash-command echo block — not the user's words)
    #   * content that begins with <system-reminder> or "Caveat:" (harness chrome)
    #   * tool_result blocks (content arrays with type="tool_result")
    # Then: cap each at ~600 chars, take the last 30, reverse so newest is first,
    # number them with awk (portable across mac/linux; macOS has no `tac`).
    jq -r '
      select(.type=="user" and (.message.role // "user")=="user" and (.isMeta // false) == false) |
      ( .message.content
        | if type=="string" then .
          elif type=="array" then
            ([.[] | select(.type=="text") | .text] | join(" "))
          else "" end )
      | gsub("\r";"") | gsub("\n+"; " ") | gsub("  +"; " ")
      | select(length>0)
      | select(test("^<command-(message|name)>") | not)
      | select(test("^<system-reminder>") | not)
      | select(test("^Caveat:") | not)
      | select(test("^\\[Request interrupted") | not)
      | select(test("^Tool ran without output") | not)
    ' "$TR_PATH" 2>/dev/null \
      | awk '{ if (length($0) > 600) print substr($0,1,580) " […]"; else print }' \
      | tail -30 \
      | awk '{ lines[NR]=$0 } END { for (i=NR; i>=1; i--) printf "%d. %s\n", (NR-i+1), lines[i] }'
    printf '\n_(Full transcript: `%s` — %s lines. `jq` it directly for anything missing here.)_\n\n' "$TR_PATH" "$TR_LINES"
  else
    printf '_No live transcript captured (transcript_lines=%s). This card is a mechanical stub — see §3 for branches/peers and §4 for TODOs._\n\n' "$TR_LINES"
  fi

  printf '## 2. Recent work (last 15 commits)\n'
  jq -r '.vcs.last_commits[]? | "- " + .' "$MAN" 2>/dev/null
  printf '\n'

  printf '## 3. Branches & peers\n'
  bdc="$(mjq .vcs.branches_detail | jq 'length' 2>/dev/null)"
  if [ "${bdc:-0}" -gt 0 ]; then
    printf '### Branches (most recent commit per branch)\n'
    jq -r '.vcs.branches_detail[]? | "- `\(.name)` — \(.last_commit_utc) · \(.last_author) · \(.last_subject)"' "$MAN" 2>/dev/null
    printf '\n'
  fi
  pac="$(mjq .peers.authors | jq 'length' 2>/dev/null)"
  if [ "${pac:-0}" -gt 0 ]; then
    printf '### Top committers (last 200 commits)\n'
    jq -r '.peers.authors[]? | "- \(.who) — \(.commits) commits"' "$MAN" 2>/dev/null
    printf '\n'
  fi
  pcc="$(mjq .peers.co_authored | jq 'length' 2>/dev/null)"
  if [ "${pcc:-0}" -gt 0 ]; then
    printf '### Co-authored-by\n'
    jq -r '.peers.co_authored[]? | "- " + .' "$MAN" 2>/dev/null
    printf '\n'
  fi

  printf '## 4. TODO / FIXME (cleanup candidates)\n'
  tdc="$(djq .todos_sample | jq 'length' 2>/dev/null)"
  if [ "${tdc:-0}" -gt 0 ]; then
    jq -r '.todos_sample[]? | "- `\(.)`"' "$DER" 2>/dev/null
  else
    printf '(none found)\n'
  fi
  printf '\n'

  printf '## 5. In-progress git operation\n'
  ipop="$(mj .vcs.in_progress_op)"
  if [ -n "$ipop" ] && [ "$ipop" != "none" ]; then
    printf -- '- **%s** in progress at snapshot time. Resolve before resuming.\n\n' "$ipop"
  else
    printf '(none)\n\n'
  fi

  printf '## 6. Dirty paths at snapshot time\n'
  dpc="$(mjq .vcs.dirty_paths_top | jq 'length' 2>/dev/null)"
  if [ "${dpc:-0}" -gt 0 ]; then
    jq -r '.vcs.dirty_paths_top[]? | "- `\(.)`"' "$MAN" 2>/dev/null
  else
    printf '(working tree clean)\n'
  fi
  printf '\n'

  if [ "$kind" = "derived-stub" ]; then
    printf '## 7. Why this is a stub\n'
    printf 'No live-session transcript was attached to this snapshot (transcript_lines=%s).\n' "$TR_LINES"
    printf 'For "what was being worked on", read sections 2-6 above + `05-features-and-issues.md`.\n'
    printf 'When the next live session runs `/sgnk-snapshot`, this card will be replaced with\n'
    printf 'a live-derived version that includes verbatim user prompts.\n\n'
  fi
} | emit "02-tasks.md"

# done — print emitted card paths (one per line) for caller inspection
ls -1 "$OUT_DIR"/*.md 2>/dev/null
exit 0
