#!/usr/bin/env bash
# sgnk-install.sh — one-time, idempotent global wiring:
#   * create ~/.sgnk/{bin,state} + GLOBAL-REGISTRY.md
#   * install the three hook scripts into ~/.sgnk/bin
#   * merge SessionStart/UserPromptSubmit/SessionEnd hooks into ~/.claude/settings.json
#     WITHOUT clobbering existing entries (caveman, graphify, …). Backs up first.
# Safe to re-run: every step is a no-op if already present.
set -uo pipefail
die() { echo "sgnk-install: $*" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || die "jq required (brew install jq)"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_SRC="$HERE/hooks"
[ -d "$HOOKS_SRC" ] || die "hook sources not found at $HOOKS_SRC"

SGNK_HOME="$HOME/.sgnk"
mkdir -p "$SGNK_HOME/bin" "$SGNK_HOME/state"
[ -f "$SGNK_HOME/GLOBAL-REGISTRY.md" ] || printf '# SGNK Global Registry — repo -> latest snapshot\n' > "$SGNK_HOME/GLOBAL-REGISTRY.md"

for h in sgnk-autorecall.sh sgnk-nudge.sh sgnk-capture.sh sgnk-eod.sh; do
  cp -f "$HOOKS_SRC/$h" "$SGNK_HOME/bin/$h"
  chmod +x "$SGNK_HOME/bin/$h"
done
echo "installed hooks -> $SGNK_HOME/bin"

# --- launchd: end-of-day daily snapshot daemon ---------------------------------
# Fires every day at 23:55 local. Iterates the global registry and writes an
# `_eod_<date>_` snapshot per repo. Those snapshots are NEVER pruned (sgnk-pointers
# guards them) — they are the permanent historical record.
PLIST_DST="$HOME/Library/LaunchAgents/ai.sgnk.eod.plist"
mkdir -p "$HOME/Library/LaunchAgents"
sed -e "s|SGNK_EOD_SCRIPT|$SGNK_HOME/bin/sgnk-eod.sh|g" \
    -e "s|SGNK_HOME|$SGNK_HOME|g" \
    "$HOOKS_SRC/ai.sgnk.eod.plist" > "$PLIST_DST.tmp" && mv -f "$PLIST_DST.tmp" "$PLIST_DST"
# launchctl: bootout the previous (idempotent), then bootstrap fresh.
# Errors are non-fatal — user may not have allowed launchd from this terminal.
if command -v launchctl >/dev/null 2>&1; then
  uid="$(id -u)"
  launchctl bootout "gui/$uid/ai.sgnk.eod" 2>/dev/null || true
  if launchctl bootstrap "gui/$uid" "$PLIST_DST" 2>/dev/null; then
    echo "launchd: EOD daemon active (runs daily at 23:55)"
  else
    # legacy fallback (older macOS, or no GUI session)
    launchctl unload "$PLIST_DST" 2>/dev/null || true
    if launchctl load "$PLIST_DST" 2>/dev/null; then
      echo "launchd: EOD daemon loaded (legacy mode)"
    else
      echo "launchd: install skipped (no GUI session); load manually: launchctl load $PLIST_DST"
    fi
  fi
fi

SETTINGS="$HOME/.claude/settings.json"
[ -f "$SETTINGS" ] || die "no settings.json at $SETTINGS"
jq -e . "$SETTINGS" >/dev/null 2>&1 || die "settings.json is not valid JSON — aborting"

# Quote the script path inside the command string so it survives a $HOME with spaces.
SA="bash \"$SGNK_HOME/bin/sgnk-autorecall.sh\""
NU="bash \"$SGNK_HOME/bin/sgnk-nudge.sh\""
CA="bash \"$SGNK_HOME/bin/sgnk-capture.sh\""

backup="$SETTINGS.sgnk-bak.$(date -u +%Y%m%dT%H%M%SZ)"
cp -f "$SETTINGS" "$backup"

# Self-healing merge: drop ANY prior SGNK entry (matched by script filename, so it
# converges even if the command string changed), then append the canonical entry.
# Non-SGNK hooks (caveman, graphify, …) are preserved untouched.
tmp="$SETTINGS.tmp.$$"
jq \
  --arg sa "$SA" --arg nu "$NU" --arg ca "$CA" \
  --arg san "sgnk-autorecall.sh" --arg nun "sgnk-nudge.sh" --arg can "sgnk-capture.sh" \
  '
  .hooks //= {}
  | .hooks.SessionStart    = (((.hooks.SessionStart // [])    | map(select(any(.hooks[]?; (.command // "") | contains($san)) | not))) + [{hooks:[{type:"command", command:$sa}]}])
  | .hooks.UserPromptSubmit = (((.hooks.UserPromptSubmit // []) | map(select(any(.hooks[]?; (.command // "") | contains($nun)) | not))) + [{hooks:[{type:"command", command:$nu, timeout:20}]}])
  | .hooks.SessionEnd      = (((.hooks.SessionEnd // [])      | map(select(any(.hooks[]?; (.command // "") | contains($can)) | not))) + [{hooks:[{type:"command", command:$ca}]}])
  ' "$SETTINGS" > "$tmp" || { rm -f "$tmp"; die "jq merge failed (settings.json unchanged; backup at $backup)"; }

jq -e . "$tmp" >/dev/null 2>&1 || { rm -f "$tmp"; die "merged settings invalid (unchanged; backup at $backup)"; }
mv -f "$tmp" "$SETTINGS"
echo "merged hooks into settings.json (backup: $backup)"
echo "SessionStart/UserPromptSubmit/SessionEnd wired. Existing hooks preserved."
