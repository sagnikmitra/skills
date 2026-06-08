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
[ -n "$REPO" ] && [ -d "$REPO/.git" ] || { echo '{}' ; exit 0; }
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
  '{
    schema:"sgnk-derive/1",
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
    recent_diffs: $recent_diffs
  }'
