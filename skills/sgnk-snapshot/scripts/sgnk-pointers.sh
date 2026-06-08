#!/usr/bin/env bash
# sgnk-pointers.sh — atomically publish a finished snapshot as the repo's LATEST,
# append the journal, refresh the global registry, and prune to N newest.
# Shared by manual snapshots (skill body) and the SessionEnd auto-capture hook,
# so there is exactly ONE implementation of the concurrency-sensitive bookkeeping.
#
# Usage: sgnk-pointers.sh <REPO_ROOT> <ID> <MODE> <HEAD_SHA> <SUMMARY> [TOOL] [ACCOUNT]
# Precondition: <REPO_ROOT>/.sgnk/snapshots/<ID>/{manifest.json,00-KEY.md} exist.
#
# Concurrency: two mutexes — a per-repo lock for repo-local files (LATEST/JOURNAL/
# prune) and a GLOBAL lock for ~/.sgnk/GLOBAL-REGISTRY.md (which is shared across
# repos, so the per-repo lock cannot serialize it). Each lock dir holds an `owner`
# PID file; a lock is only broken if its owner process is dead or it is >2 min old,
# avoiding the rm-rf-an-unowned-lock race.
set -uo pipefail

REPO_ROOT="${1:-}"; ID="${2:-}"; MODE="${3:-full}"; HEAD_SHA="${4:-}"; SUMMARY="${5:-}"
TOOL="${6:-${SGNK_TOOL:-claude}}"; ACCOUNT="${7:-${SGNK_ACCOUNT:-unknown}}"
RETAIN="${SGNK_RETAIN:-100}"; JOURNAL_MAX="${SGNK_JOURNAL_MAX:-5000}"
case "$RETAIN" in (''|*[!0-9]*) RETAIN=100;; esac          # guard set -u arithmetic
case "$JOURNAL_MAX" in (''|*[!0-9]*) JOURNAL_MAX=5000;; esac

die() { echo "sgnk: $*" >&2; exit 1; }
[ -n "$REPO_ROOT" ] && [ -n "$ID" ] || die "usage: sgnk-pointers.sh <REPO_ROOT> <ID> <MODE> <HEAD_SHA> <SUMMARY>"

SGNK_DIR="$REPO_ROOT/.sgnk"
SNAP_DIR="$SGNK_DIR/snapshots/$ID"
[ -f "$SNAP_DIR/manifest.json" ] || die "missing manifest for $ID"
mkdir -p "$SGNK_DIR/snapshots" "$HOME/.sgnk"

# journal fields are pipe-delimited and one-line — keep separators out of the data
SUMMARY="$(printf '%s' "$SUMMARY" | tr '|\n\r' '   ')"
TOOL="$(printf '%s' "$TOOL" | tr -d '|\n\r')"
ACCOUNT="$(printf '%s' "$ACCOUNT" | tr -d '|\n\r')"

REPO_LOCK="$SGNK_DIR/.lock.d"
GLOBAL_LOCK="$HOME/.sgnk/.lock.d"
HELD=""
acquire() { # <lockdir> ; returns 0 if held, 1 if it gave up (caller still proceeds)
  local lock="$1" tries=0 opid
  while ! mkdir "$lock" 2>/dev/null; do
    opid="$(cat "$lock/owner" 2>/dev/null || true)"
    if [ -n "$opid" ] && ! kill -0 "$opid" 2>/dev/null; then rm -rf "$lock" 2>/dev/null; continue; fi
    if find "$lock" -maxdepth 0 -mmin +2 >/dev/null 2>&1; then rm -rf "$lock" 2>/dev/null; continue; fi
    tries=$((tries+1)); [ "$tries" -ge 100 ] && { echo "sgnk: lock $lock busy >10s, proceeding" >&2; return 1; }
    sleep 0.1
  done
  echo $$ > "$lock/owner" 2>/dev/null || true
  HELD="$HELD $lock"
  return 0
}
release() { rm -rf "$1" 2>/dev/null || true; }
release_all() { local l; for l in $HELD; do rm -rf "$l" 2>/dev/null || true; done; }
write_atomic() { local dest="$1" tmp; tmp="$(dirname "$dest")/.$(basename "$dest").tmp.$$"; cat > "$tmp" && mv -f "$tmp" "$dest"; }

trap release_all EXIT

# ---- repo-local section (LATEST-KEY, LATEST, JOURNAL, prune) ----------------
acquire "$REPO_LOCK"

[ -f "$SNAP_DIR/00-KEY.md" ] && write_atomic "$SGNK_DIR/LATEST-KEY.md" < "$SNAP_DIR/00-KEY.md"
printf '%s\n' "$ID" | write_atomic "$SGNK_DIR/LATEST"

JOURNAL="$SGNK_DIR/JOURNAL.md"
[ -f "$JOURNAL" ] || printf '# SGNK Journal — append-only snapshot log\n' > "$JOURNAL"
printf '%s|%s/%s|%s|%s|%s|%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$TOOL" "$ACCOUNT" "$ID" "$MODE" "${HEAD_SHA:0:12}" "$SUMMARY" >> "$JOURNAL"
jlines="$(wc -l < "$JOURNAL" | tr -d ' ')"; case "$jlines" in (''|*[!0-9]*) jlines=0;; esac
if [ "$jlines" -gt "$JOURNAL_MAX" ]; then
  { head -n1 "$JOURNAL"; tail -n "$((JOURNAL_MAX/2))" "$JOURNAL"; } | write_atomic "$JOURNAL"
fi

# prune snapshots to RETAIN newest (IDs timestamp-prefixed -> lexical == chrono).
# Guarded: only ever operates inside this repo's .sgnk/snapshots.
# IDs containing "_eod_" or "_milestone_" are NEVER pruned — they are the historical
# archive. Working-memory snapshots cap at RETAIN; eod/milestone grow forever
# (each is ~20KB; 1000 of them = ~20MB. Cheap.).
if [ -d "$SGNK_DIR/snapshots" ]; then
  ( cd "$SGNK_DIR/snapshots" && ls -1 2>/dev/null | grep -v -E '_eod_|_milestone_' | sort -r | tail -n "+$((RETAIN+1))" | while IFS= read -r old; do
      [ -n "$old" ] && [ -d "$old" ] && rm -rf -- "./$old"
    done )
fi
release "$REPO_LOCK"

# ---- global section (cross-repo registry) ----------------------------------
acquire "$GLOBAL_LOCK"
REG="$HOME/.sgnk/GLOBAL-REGISTRY.md"
[ -f "$REG" ] || printf '# SGNK Global Registry — repo -> latest snapshot\n' > "$REG"
{ grep -v -F "	$REPO_ROOT	" "$REG" 2>/dev/null || true
  printf '\t%s\t%s\t%s\t%s/%s\n' "$REPO_ROOT" "$ID" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$TOOL" "$ACCOUNT"
} | write_atomic "$REG"
release "$GLOBAL_LOCK"

trap - EXIT
echo "published LATEST=$ID"
