#!/usr/bin/env bash
# SessionStart hook — surface the repo's latest KEY card as session context.
# stdout from a SessionStart hook is injected into Claude's context.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
# portable bounded stdin read (macOS has no `timeout`); reads JSON until EOF, 5s cap.
IFS= read -r -t 5 -d '' input 2>/dev/null || true; [ -n "${input:-}" ] || exit 0
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$cwd" ] || exit 0
key="$cwd/.sgnk/LATEST-KEY.md"
[ -f "$key" ] || exit 0
echo "## SGNK — prior-session handoff for $cwd"
echo
cat "$key"
echo
echo "_Run /sgnk-recall for full reconciliation across chats/tools and live git drift before acting._"
exit 0
