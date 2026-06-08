#!/usr/bin/env bash
# UserPromptSubmit hook — after a long session, nudge to snapshot before the limit.
# Does NOT use transcript_path (undocumented/unavailable). Uses a per-session prompt
# counter keyed on session_id, which IS provided on stdin. 30s hook budget — stay fast.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
IFS= read -r -t 5 -d '' input 2>/dev/null || true; [ -n "${input:-}" ] || exit 0
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
sid="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$cwd" ] && [ -n "$sid" ] || exit 0

state_dir="$HOME/.sgnk/state"; mkdir -p "$state_dir" 2>/dev/null || exit 0
cf="$state_dir/${sid}.count"
n=0; [ -f "$cf" ] && n="$(cat "$cf" 2>/dev/null || echo 0)"
case "$n" in (*[!0-9]*|'') n=0;; esac
n=$((n+1)); printf '%s' "$n" > "$cf"

after="${SGNK_NUDGE_AFTER:-25}"
[ "$n" -lt "$after" ] && exit 0

# Skip if a fresh snapshot already exists (LATEST-KEY modified in last 30 min).
key="$cwd/.sgnk/LATEST-KEY.md"
if [ -f "$key" ] && find "$key" -mmin -30 >/dev/null 2>&1; then exit 0; fi

echo "⚠️ SGNK: long session (${n} prompts) — run /sgnk-snapshot quick before you hit the limit so the next account/tool can resume cleanly."

# If the user has ignored the nudge and we're now at 2× the threshold, ALSO fire
# a mechanical safety-net snapshot in the background so context isn't lost if the
# limit hits mid-prompt. Same machinery as the SessionEnd capture, NEVER overwrites
# a fresh manual snapshot (10 min guard inside sgnk-capture.sh).
if [ "$n" -ge $((after*2)) ]; then
  if [ -x "$HOME/.sgnk/bin/sgnk-capture.sh" ]; then
    printf '{"cwd":"%s","session_id":"%s","reason":"near-limit"}' "$cwd" "$sid" \
      | nohup bash "$HOME/.sgnk/bin/sgnk-capture.sh" >/dev/null 2>&1 &
    echo "   (auto-captured a safety-net snapshot in the background)"
  fi
fi

printf '0' > "$cf"   # reset so it re-nudges each interval
exit 0
