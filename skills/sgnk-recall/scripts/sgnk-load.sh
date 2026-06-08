#!/usr/bin/env bash
# sgnk-load.sh — deterministically load a snapshot and compute EXACT live drift now.
# Emits one compact JSON object {manifest, drift, journal} to stdout. JSON in, JSON
# out — the recall skill never has to parse prose to reconcile state.
#
# Usage: sgnk-load.sh <REPO_ROOT> [ID]   (ID defaults to contents of .sgnk/LATEST)
set -uo pipefail

REPO_ROOT="${1:-}"; WANT_ID="${2:-}"
GH_TIMEOUT="${SGNK_GH_TIMEOUT:-5}"
die() { echo "sgnk: $*" >&2; exit 1; }

[ -n "$REPO_ROOT" ] || die "usage: sgnk-load.sh <REPO_ROOT> [ID]"
command -v jq >/dev/null 2>&1 || die "jq required (brew install jq)"
SGNK_DIR="$REPO_ROOT/.sgnk"
[ -d "$SGNK_DIR/snapshots" ] || die "no snapshots at $SGNK_DIR (run /sgnk-snapshot first)"

# --- list mode -------------------------------------------------------------
# `sgnk-load.sh <repo> list [N]`  -> emit chronological snapshot history
# (latest first), as a JSON array of {id, utc, mode, branch, head, kind,
# summary, is_latest}. Default N=50.
if [ "$WANT_ID" = "list" ] || [ "$WANT_ID" = "--list" ] || [ "$WANT_ID" = "history" ]; then
  N="${3:-50}"; case "$N" in (''|*[!0-9]*) N=50;; esac
  LATEST_ID="$([ -f "$SGNK_DIR/LATEST" ] && head -n1 "$SGNK_DIR/LATEST" 2>/dev/null || true)"
  JOURNAL="$SGNK_DIR/JOURNAL.md"
  # Build a side table: id -> summary, from JOURNAL.md (most recent wins).
  sum_tmp="$(mktemp -t sgnk-sum.XXXXXX)"
  if [ -f "$JOURNAL" ]; then
    grep -v '^#' "$JOURNAL" 2>/dev/null | awk -F'|' 'NF>=6 {print $3 "\t" $6}' > "$sum_tmp"
  fi
  # Walk snapshots/ newest-first (IDs are YYYYMMDDTHHMMSSZ_... so lexical desc == chrono desc).
  ( cd "$SGNK_DIR/snapshots" 2>/dev/null && ls -1 2>/dev/null | sort -r | head -n "$N" \
    | while IFS= read -r id; do
        m="$id/manifest.json"
        [ -f "$m" ] || continue
        kind="manual"
        case "$id" in
          *_eod_*)       kind="eod";;
          *_milestone_*) kind="milestone";;
          *_auto-*)      kind="auto";;
        esac
        sum="$(grep -F "	$id" /dev/null 2>/dev/null; awk -F'\t' -v id="$id" '$1==id{print $2}' "$sum_tmp" 2>/dev/null | head -1)"
        jq -n --arg id "$id" --arg kind "$kind" --arg sum "$sum" \
              --arg latest_id "$LATEST_ID" --slurpfile mf "$m" \
              '{id:$id, kind:$kind, summary:$sum, is_latest:($id == $latest_id),
                utc:$mf[0].utc, mode:$mf[0].mode,
                branch:$mf[0].vcs.branch, head:($mf[0].vcs.head_sha[0:12]),
                dirty:$mf[0].vcs.dirty_count, in_progress_op:$mf[0].vcs.in_progress_op}'
      done ) | jq -s '.'
  rm -f "$sum_tmp"
  exit 0
fi

ID="$WANT_ID"
[ -z "$ID" ] && [ -f "$SGNK_DIR/LATEST" ] && ID="$(head -n1 "$SGNK_DIR/LATEST" 2>/dev/null)"
[ -z "$ID" ] && die "no LATEST pointer and no ID given"
MAN="$SGNK_DIR/snapshots/$ID/manifest.json"
[ -f "$MAN" ] || die "manifest not found for id=$ID"
jq -e . "$MAN" >/dev/null 2>&1 || die "stored manifest is not valid JSON: $MAN"

g() { git -C "$REPO_ROOT" --no-pager "$@" 2>/dev/null; }
gp() { git -C "$REPO_ROOT" rev-parse --git-path "$1" 2>/dev/null; }
if command -v timeout >/dev/null 2>&1; then _TO=timeout
elif command -v gtimeout >/dev/null 2>&1; then _TO=gtimeout
else _TO=""; fi
run_to() { local d="$1"; shift; if [ -n "$_TO" ]; then "$_TO" "$d" "$@"; else "$@"; fi; }

rec_head="$(jq -r '.vcs.head_sha // ""' "$MAN")"
rec_branch="$(jq -r '.vcs.branch // ""' "$MAN")"
rec_dirty="$(jq -r '.vcs.dirty_count // 0' "$MAN")"
rec_op="$(jq -r '.vcs.in_progress_op // "none"' "$MAN")"

# --- live git now ---
branch_now="$(g rev-parse --abbrev-ref HEAD)"; branch_now="${branch_now:-unknown}"
head_now="$(g rev-parse HEAD)"; head_now="${head_now:-}"
dirty_now="$(g status --porcelain | grep -c . )"; dirty_now="${dirty_now:-0}"
commits_since=0; commits_oneline_json="[]"
if [ -n "$rec_head" ] && g cat-file -e "${rec_head}^{commit}" 2>/dev/null; then
  commits_since="$(g rev-list --count "${rec_head}..HEAD")"; commits_since="${commits_since:-0}"
  commits_oneline_json="$(g log --pretty=oneline --abbrev-commit --no-color "${rec_head}..HEAD" | head -20 \
    | jq -R -s 'split("\n") | map(select(length>0))')"
else
  commits_oneline_json='["(recorded head not in current history — rebased/force-pushed/different clone)"]'
fi
ahead_now=0; behind_now=0
up="$(g rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"
if [ -n "$up" ]; then lr="$(g rev-list --left-right --count "${up}...HEAD")"; behind_now="$(echo "$lr" | awk '{print $1+0}')"; ahead_now="$(echo "$lr" | awk '{print $2+0}')"; fi
op_now="none"
if   [ -d "$(gp rebase-merge)" ] || [ -d "$(gp rebase-apply)" ]; then op_now="rebase"
elif [ -f "$(gp MERGE_HEAD)" ]; then op_now="merge"
elif [ -f "$(gp CHERRY_PICK_HEAD)" ]; then op_now="cherry-pick"
elif [ -f "$(gp REVERT_HEAD)" ]; then op_now="revert"
elif [ -f "$(gp BISECT_LOG)" ]; then op_now="bisect"
fi

# --- runtime now: which recorded ports are still listening ---
runtime_now_json="[]"
if command -v lsof >/dev/null 2>&1; then
  rec_ports="$(jq -r '.runtime.ports_in_use[]? | tostring' "$MAN")"
  if [ -n "$rec_ports" ]; then
    runtime_now_json="$(while IFS= read -r p; do
        [ -n "$p" ] || continue
        if lsof -nP -iTCP:"$p" -sTCP:LISTEN >/dev/null 2>&1; then st=up; else st=down; fi
        printf '%s\t%s\n' "$p" "$st"
      done <<< "$rec_ports" | jq -R -s 'split("\n") | map(select(length>0)) | map(split("\t")) | map({port:.[0], status:.[1]})')"
  fi
fi

# --- remote now (optional, time-boxed, full reconcile only) ---
remote_now_json='{"checked":false}'
if [ "${SGNK_NO_REMOTE:-0}" != "1" ] && command -v gh >/dev/null 2>&1 && run_to "$GH_TIMEOUT" gh auth status >/dev/null 2>&1; then
  prs="$(run_to "$GH_TIMEOUT" gh pr list --state open --limit 10 --json number,title,headRefName,reviewDecision 2>/dev/null || echo '[]')"
  printf '%s' "$prs" | jq -e . >/dev/null 2>&1 || prs='[]'
  remote_now_json="$(jq -n --argjson prs "$prs" '{checked:true, open_prs:$prs}')"
fi

# --- journal digest (recent, with provenance) ---
journal_json='[]'
if [ -f "$SGNK_DIR/JOURNAL.md" ]; then
  journal_json="$(grep -v '^#' "$SGNK_DIR/JOURNAL.md" | tail -10 | jq -R -s '
    split("\n") | map(select(length>0)) | map(split("|") |
      {utc:.[0], by:.[1], id:.[2], mode:.[3], head:.[4], summary:.[5]})')"
fi

# --- assemble ---
jq -n \
  --slurpfile manifest "$MAN" \
  --arg id "$ID" \
  --arg rec_head "$rec_head" --arg rec_branch "$rec_branch" --argjson rec_dirty "${rec_dirty:-0}" --arg rec_op "$rec_op" \
  --arg branch_now "$branch_now" --arg head_now "$head_now" --argjson dirty_now "$dirty_now" \
  --argjson commits_since "${commits_since:-0}" --argjson commits_oneline "$commits_oneline_json" \
  --argjson ahead_now "$ahead_now" --argjson behind_now "$behind_now" --arg op_now "$op_now" \
  --argjson runtime_now "$runtime_now_json" --argjson remote_now "$remote_now_json" \
  --argjson journal "$journal_json" \
  '{
    id: $id,
    manifest: $manifest[0],
    drift: {
      branch: {recorded:$rec_branch, now:$branch_now, changed: ($rec_branch != $branch_now)},
      head:   {recorded:$rec_head, now:$head_now, commits_since:$commits_since, new_commits:$commits_oneline},
      dirty:  {recorded:$rec_dirty, now:$dirty_now},
      upstream: {ahead:$ahead_now, behind:$behind_now},
      in_progress_op: {recorded:$rec_op, now:$op_now, still_pending: ($op_now != "none")},
      runtime: $runtime_now,
      remote: $remote_now
    },
    journal: $journal
  }'
