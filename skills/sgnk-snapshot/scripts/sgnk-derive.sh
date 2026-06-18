#!/usr/bin/env bash
# sgnk-derive.sh — mechanically derive richer narrative inputs from a repo when no
# live session context is available (multi-repo snapshots, `auto` mode, EOD, etc).
# Output: one JSON object on stdout that the snapshot SKILL.md body uses to write
# 01-context.md / 02-tasks.md *with real content*, not a stub.
#
# Pulls from: git log (last 30 commits), recent diffs, top-level file structure,
# README/CHANGELOG, package metadata, and the SGNK manifest already produced.
#
# Usage: sgnk-derive.sh <REPO_ROOT> [<manifest.json>]
set -uo pipefail
REPO="${1:-}"
MAN="${2:-}"
# Validate via rev-parse, not `-d $REPO/.git`: in a linked worktree `.git` is a
# FILE (gitdir pointer), so the `-d` test would wrongly emit an empty {} and
# strand 05-features-and-issues.md. This mirrors sgnk-collect.sh, which already
# supports worktrees.
[ -n "$REPO" ] && git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo '{}' ; exit 0; }
command -v jq >/dev/null 2>&1 || { echo '{}' ; exit 0; }

g() { git -C "$REPO" --no-pager "$@" 2>/dev/null; }

# Last 30 commits — TSV: sha\tunix\tauthor\tsubject
commits_json="$(g log -30 --format='%h%x09%at%x09%an%x09%s' \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
              map({sha:.[0], unix:(.[1]|tonumber? // 0), author:.[2], subject:.[3]})')"
[ -z "$commits_json" ] && commits_json="[]"

# Distinct topics from commit subjects (very rough — first word per Conventional Commit)
topics_json="$(g log -100 --format='%s' \
  | awk -F'[:(]' 'NF>1 && $1 ~ /^(feat|fix|chore|docs|refactor|perf|test|build|ci|style|revert)/ {print $1}' \
  | sort | uniq -c | sort -rn | head -10 \
  | awk '{type=$2; count=$1; printf "%s\t%d\n", type, count}' \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
              map({type:.[0], count:(.[1]|tonumber? // 0)})')"
[ -z "$topics_json" ] && topics_json="[]"

# Files modified across the last 30 commits, ranked by churn (touches)
churn_json="$(g log -30 --format='' --name-only | grep -v '^$' \
  | sort | uniq -c | sort -rn | head -20 \
  | awk '{count=$1; $1=""; sub(/^ /,""); printf "%s\t%d\n", $0, count}' \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
              map({path:.[0], touches:(.[1]|tonumber? // 0)})')"
[ -z "$churn_json" ] && churn_json="[]"

# Branches with their last commit subject (≤15)
branches_json="$(g for-each-ref --sort=-committerdate --count=15 \
  --format='%(refname:short)%09%(committerdate:iso-strict)%09%(authorname)%09%(subject)' refs/heads/ \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
              map({name:.[0], last_utc:.[1], last_author:.[2], last_subject:.[3]})')"
[ -z "$branches_json" ] && branches_json="[]"

# Project metadata (READMEs / package.json / pyproject — first hits, head only)
readme_path=""; for f in README.md README.MD Readme.md readme.md README; do
  [ -f "$REPO/$f" ] && readme_path="$f" && break
done
readme_head=""
[ -n "$readme_path" ] && readme_head="$(head -50 "$REPO/$readme_path" 2>/dev/null)"

pkgjson="$(jq -c '{name, version, description, scripts: (.scripts // {} | keys), deps: (.dependencies // {} | keys), devDeps: (.devDependencies // {} | keys | length)}' "$REPO/package.json" 2>/dev/null || echo null)"
pyproject_summary=""
if [ -f "$REPO/pyproject.toml" ]; then
  pyproject_summary="$(head -40 "$REPO/pyproject.toml" 2>/dev/null)"
fi

# Open TODO/FIXME (cheap grep, capped, excludes vendored deps & build artefacts
# so project TODOs aren't drowned in noise from site-packages / node_modules etc.)
todos_json="$(grep -RnE '(TODO|FIXME|XXX|HACK)' "$REPO" \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    --include='*.py' --include='*.go' --include='*.rs' --include='*.md' \
    --exclude-dir='.git' --exclude-dir='node_modules' --exclude-dir='.venv' \
    --exclude-dir='venv' --exclude-dir='.vercel' --exclude-dir='dist' \
    --exclude-dir='build' --exclude-dir='target' --exclude-dir='vendor' \
    --exclude-dir='graphify-out' --exclude-dir='.sgnk' --exclude-dir='.next' \
    --exclude-dir='site-packages' --exclude-dir='__pycache__' \
    --exclude-dir='.pytest_cache' --exclude-dir='.mypy_cache' \
    --exclude-dir='coverage' --exclude-dir='.turbo' 2>/dev/null \
  | head -20 | sed "s|^${REPO}/||" \
  | jq -R -s 'split("\n") | map(select(length>0))')"
[ -z "$todos_json" ] && todos_json="[]"

# Recent diff highlights — for the 5 most recent commits, capture stat totals
recent_diffs_json="$(g log -5 --format='%h%x09%s' \
  | while IFS=$'\t' read -r sha subject; do
      [ -z "$sha" ] && continue
      stat="$(g show --shortstat --format= "$sha" 2>/dev/null | tail -1 | sed 's/^ *//')"
      printf '%s\t%s\t%s\n' "$sha" "$subject" "$stat"
    done \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
              map({sha:.[0], subject:.[1], stat:.[2]})')"
[ -z "$recent_diffs_json" ] && recent_diffs_json="[]"

# Feature clusters — group last 30 commits by dominant top-2-dir prefix. Tells
# the resuming agent "the active feature thrust right now is in <dir>". Mechanical.
clusters_tmp="$(mktemp -t sgnk-clust.XXXXXX)"
g log -30 --format='__C__%h%x09%s' --name-only 2>/dev/null \
  | awk '
      BEGIN { sha=""; subj="" }
      /^__C__/ {
        if (sha != "") for (d in dc) print sha "\t" subj "\t" d "\t" dc[d]
        split(substr($0,6), a, "\t"); sha=a[1]; subj=a[2]
        delete dc; next
      }
      NF==0 { next }
      {
        n=split($0, p, "/")
        if (n>=2) key=p[1]"/"p[2]; else key=p[1]
        dc[key]++
      }
      END { if (sha != "") for (d in dc) print sha "\t" subj "\t" d "\t" dc[d] }
    ' > "$clusters_tmp"
feature_clusters_json="$(awk -F'\t' '
    { count[$3]++; if (length(subjs[$3]) < 220) subjs[$3] = subjs[$3] (length(subjs[$3])?"|":"") $2 }
    END { for (k in count) print k "\t" count[k] "\t" subjs[k] }
  ' "$clusters_tmp" \
  | sort -t$'\t' -k2 -rn | head -5 \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
              map({dir:.[0], commit_count:(.[1]|tonumber? // 0),
                   recent_subjects: (.[2] // "" | split("|") | .[0:3])})')"
rm -f "$clusters_tmp"
[ -z "$feature_clusters_json" ] && feature_clusters_json="[]"

# Branch diffstats vs base — for each non-base local branch (capped)
base_branch_for_diff="$(g symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|.*/||')"
base_branch_for_diff="${base_branch_for_diff:-main}"
branch_diffstats_json="$(g for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null \
  | grep -v "^${base_branch_for_diff}$" | head -8 \
  | while read -r br; do
      [ -z "$br" ] && continue
      stat="$(g diff --shortstat "${base_branch_for_diff}...${br}" 2>/dev/null | sed 's/^ *//')"
      [ -n "$stat" ] && printf '%s\t%s\n' "$br" "$stat"
    done \
  | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) |
              map({branch:.[0], vs_base:.[1]})')"
[ -z "$branch_diffstats_json" ] && branch_diffstats_json="[]"

# Assemble
jq -n \
  --argjson commits "$commits_json" \
  --argjson topics "$topics_json" \
  --argjson churn "$churn_json" \
  --argjson branches "$branches_json" \
  --arg readme_path "$readme_path" \
  --arg readme_head "$readme_head" \
  --argjson pkgjson "$pkgjson" \
  --arg pyproject "$pyproject_summary" \
  --argjson todos "$todos_json" \
  --argjson recent_diffs "$recent_diffs_json" \
  --argjson feature_clusters "$feature_clusters_json" \
  --argjson branch_diffstats "$branch_diffstats_json" \
  --arg base_branch_for_diff "$base_branch_for_diff" \
  '{
    schema:"sgnk-derive/2",
    commits: $commits,
    commit_topics: $topics,
    file_churn: $churn,
    branches: $branches,
    project: {
      readme_path: (if $readme_path=="" then null else $readme_path end),
      readme_head: (if $readme_head=="" then null else $readme_head end),
      package_json: $pkgjson,
      pyproject_head: (if $pyproject=="" then null else $pyproject end)
    },
    todos_sample: $todos,
    recent_diffs: $recent_diffs,
    feature_clusters: $feature_clusters,
    branch_diffstats: {base: $base_branch_for_diff, entries: $branch_diffstats}
  }'
