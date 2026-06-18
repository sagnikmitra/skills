#!/usr/bin/env bash
# SessionEnd hook — mechanical safety net. NO model. If the user forgot to snapshot,
# write a minimal AUTO snapshot so the work is still resumable. Reuses the snapshot
# skill's collector + pointer scripts (single source of truth). Gated on the repo
# already opting in (a .sgnk/ dir exists), so it's a fast no-op everywhere else.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0
IFS= read -r -t 5 -d '' input 2>/dev/null || true; [ -n "${input:-}" ] || exit 0
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
reason="$(printf '%s' "$input" | jq -r '.reason // "other"' 2>/dev/null)"
sid="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"

# housekeeping: drop this session's nudge counter
[ -n "$sid" ] && rm -f "$HOME/.sgnk/state/${sid}.count" 2>/dev/null || true

[ -n "$cwd" ] || exit 0
git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
sgnk="$cwd/.sgnk"
[ -d "$sgnk" ] || exit 0   # only auto-capture in repos already using SGNK

COLLECT="$HOME/.claude/skills/sgnk-snapshot/scripts/sgnk-collect.sh"
POINTERS="$HOME/.claude/skills/sgnk-snapshot/scripts/sgnk-pointers.sh"
WRITE_CARDS="$HOME/.claude/skills/sgnk-snapshot/scripts/sgnk-write-cards.sh"
[ -f "$COLLECT" ] && [ -f "$POINTERS" ] || exit 0

# A fresh manual snapshot (<10 min)? Don't overwrite it — just note the session end.
if [ -f "$sgnk/LATEST-KEY.md" ] && find "$sgnk/LATEST-KEY.md" -mmin -10 >/dev/null 2>&1; then
  printf '%s|%s/%s|-|sessionend|-|fresh manual snapshot present; auto-capture skipped (reason=%s)\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${SGNK_TOOL:-claude}" "${SGNK_ACCOUNT:-unknown}" "$reason" \
    >> "$sgnk/JOURNAL.md" 2>/dev/null || true
  exit 0
fi

rand="$(od -An -N2 -tx1 /dev/urandom 2>/dev/null | tr -d ' \n')"; rand="${rand:-0000}"
ID="$(date -u +%Y%m%dT%H%M%SZ)_auto-${reason}_${rand}"
OUT="$sgnk/snapshots/$ID"
SGNK_ID="$ID" SGNK_NO_REMOTE=1 bash "$COLLECT" "$cwd" "$OUT" auto >/dev/null 2>&1 || exit 0

branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)"
head="$(git -C "$cwd" rev-parse HEAD 2>/dev/null)"
{ printf '```yaml\nid: %s\nhead_sha: %s\nbranch: %s\nutc: %s\n```\n\n' \
    "$ID" "$head" "$branch" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '# AUTO snapshot — SessionEnd safety net (reason=%s)\n\n' "$reason"
  printf 'Mechanical capture, no narrative: the session ended without a manual /sgnk-snapshot.\n'
  printf 'Resume: open this repo, run /sgnk-recall, and read manifest.json for live state.\n'
} > "$OUT/00-KEY.md"

# Emit the full narrative-card set so auto-captures aren't mechanical-only.
# write-cards itself is idempotent and silent on failure — never blocks publish.
[ -f "$WRITE_CARDS" ] && bash "$WRITE_CARDS" "$OUT" "$cwd" >/dev/null 2>&1 || true

bash "$POINTERS" "$cwd" "$ID" auto "$head" "AUTO safety-net snapshot (reason=$reason)" \
  "${SGNK_TOOL:-claude}" "${SGNK_ACCOUNT:-unknown}" >/dev/null 2>&1 || true
exit 0
