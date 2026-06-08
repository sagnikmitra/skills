#!/usr/bin/env bash
# sgnk-eod.sh — end-of-day daily archival snapshot, fired by launchd.
# Scope: every repo in ~/.sgnk/GLOBAL-REGISTRY.md that has had ANY snapshot
# (i.e. is opted in). Skips repos that already have an `_eod_` snapshot from today.
# Snapshot ID embeds `_eod_<YYYY-MM-DD>_` so the prune logic in sgnk-pointers.sh
# never deletes it — these are the permanent historical record.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

REG="$HOME/.sgnk/GLOBAL-REGISTRY.md"
[ -f "$REG" ] || exit 0
COLLECT="$HOME/.claude/skills/sgnk-snapshot/scripts/sgnk-collect.sh"
POINTERS="$HOME/.claude/skills/sgnk-snapshot/scripts/sgnk-pointers.sh"
[ -f "$COLLECT" ] && [ -f "$POINTERS" ] || exit 0

today="$(date +%Y-%m-%d)"
LOG="$HOME/.sgnk/eod.log"
{ printf '\n=== EOD run %s ===\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"; } >> "$LOG"

# tab-separated, lines start with \t<repo>\t<id>\t...
grep -v '^#' "$REG" 2>/dev/null | awk -F'\t' 'NF>=3 {print $2}' | sort -u | while IFS= read -r repo; do
  [ -n "$repo" ] && [ -d "$repo" ] || { echo "skip (gone): $repo" >> "$LOG"; continue; }
  git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "skip (not git): $repo" >> "$LOG"; continue; }

  # already have an EOD snapshot for today?
  if ls "$repo/.sgnk/snapshots" 2>/dev/null | grep -q "_eod_${today}_"; then
    echo "skip (already eod $today): $repo" >> "$LOG"
    continue
  fi

  rand="$(od -An -N2 -tx1 /dev/urandom 2>/dev/null | tr -d ' \n')"; rand="${rand:-0000}"
  ID="$(date -u +%Y%m%dT%H%M%SZ)_eod_${today}_${rand}"
  OUT="$repo/.sgnk/snapshots/$ID"
  if ! SGNK_ID="$ID" SGNK_NO_REMOTE=1 bash "$COLLECT" "$repo" "$OUT" auto >>"$LOG" 2>&1; then
    echo "collect failed: $repo" >> "$LOG"; continue
  fi

  branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  head="$(git -C "$repo" rev-parse HEAD 2>/dev/null)"
  { printf '```yaml\nid: %s\nhead_sha: %s\nbranch: %s\nutc: %s\nkind: eod-daily\n```\n\n' \
      "$ID" "$head" "$branch" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '# EOD snapshot — %s\n\n' "$today"
    printf 'Automatic end-of-day capture. Mechanical (no narrative). Use it as a\n'
    printf 'historical anchor for "where were we on %s". Manual /sgnk-snapshot\n' "$today"
    printf 'snapshots stay in rotation; these eod snapshots are kept forever.\n\n'
    printf '## Quick stats\n'
    printf -- '- branch: %s\n- head: %s\n' "$branch" "${head:0:12}"
    dirty="$(git -C "$repo" status --porcelain 2>/dev/null | grep -c .)"
    printf -- '- dirty files: %s\n' "$dirty"
    printf '\nResume: open this repo, run /sgnk-recall.\n'
  } > "$OUT/00-KEY.md"

  bash "$POINTERS" "$repo" "$ID" auto "$head" "EOD daily archive ($today)" \
    "${SGNK_TOOL:-claude}" "${SGNK_ACCOUNT:-eod}" >>"$LOG" 2>&1 || true
  echo "eod ok: $repo -> $ID" >> "$LOG"
done

# rotate log if huge
[ -f "$LOG" ] && [ "$(wc -l <"$LOG" | tr -d ' ')" -gt 5000 ] && tail -2000 "$LOG" > "$LOG.tmp" && mv -f "$LOG.tmp" "$LOG"
exit 0
