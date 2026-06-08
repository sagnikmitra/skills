#!/usr/bin/env bash
# update.sh — pull latest sgnk-md, rebuild the Tauri macOS app, swap into
# /Applications, relaunch. Idempotent and aborts on first hard error.
#
# Usage:
#   bash ~/.claude/skills/sgnk-md-update/scripts/update.sh [flags]
#
# Flags:
#   --no-pull         skip git pull (build current checkout)
#   --no-install      skip npm install even if package.json moved
#   --skip-relaunch   install but don't auto-open the new .app
#   --dry-run         print steps without executing
#
# Exit codes:
#   0  upgrade complete
#   1  preflight failed (dirty working tree, missing repo, etc.)
#   2  build failed
#   3  install failed

set -euo pipefail

# ── config ───────────────────────────────────────────────────────────────
REPO_DIR="${SGNK_MD_REPO:-$HOME/Desktop/GitHub/md}"
APP_NAME="sgnk-md"
APP_BUNDLE_NAME="${APP_NAME}.app"
APPLICATIONS_DIR="/Applications"
INSTALLED_APP="$APPLICATIONS_DIR/$APP_BUNDLE_NAME"
PREV_APP="$APPLICATIONS_DIR/${APP_NAME}-prev.app"

# Build artifact lives at either of these (Cargo may put target/ at workspace
# root or under src-tauri/ depending on invocation cwd).
BUILT_APP_CANDIDATES=(
  "$REPO_DIR/src-tauri/target/release/bundle/macos/$APP_BUNDLE_NAME"
  "$REPO_DIR/target/release/bundle/macos/$APP_BUNDLE_NAME"
)
BUILT_DMG_CANDIDATES=(
  "$REPO_DIR/src-tauri/target/release/bundle/dmg"
  "$REPO_DIR/target/release/bundle/dmg"
)

PULL=1
INSTALL_DEPS=1
RELAUNCH=1
DRY=0
for arg in "$@"; do
  case "$arg" in
    --no-pull)       PULL=0 ;;
    --no-install)    INSTALL_DEPS=0 ;;
    --skip-relaunch) RELAUNCH=0 ;;
    --dry-run)       DRY=1 ;;
    -h|--help)
      sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# ── helpers ──────────────────────────────────────────────────────────────
log()  { printf "\033[36m▸\033[0m %s\n" "$*"; }
ok()   { printf "\033[32m✓\033[0m %s\n" "$*"; }
warn() { printf "\033[33m⚠\033[0m %s\n" "$*"; }
die()  { printf "\033[31m✗\033[0m %s\n" "$*" >&2; exit "${2:-1}"; }
run()  { if [ "$DRY" = "1" ]; then echo "  [dry] $*"; else "$@"; fi; }

# ── preflight ────────────────────────────────────────────────────────────
log "preflight"
[ -d "$REPO_DIR/.git" ] || die "repo not found at $REPO_DIR (set SGNK_MD_REPO if it lives elsewhere)"
cd "$REPO_DIR"

# Source git/vercel tokens if the file exists (lets gh + git push work; we
# only read so refusing if missing is fine for an update-only flow).
if [ -f "$HOME/.config/codex-env/tokens.zsh" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.config/codex-env/tokens.zsh"
fi

# Refuse on dirty tracked files. Untracked files are fine.
# Noisy paths (Obsidian local UI state) are tolerated — they wiggle constantly.
NOISY_RE='^(\.obsidian/workspace\.json|\.obsidian/workspaces\.json)$'
DIRTY_REAL=$(git status --porcelain | awk '$1 ~ /^[MARC]/ {print $2}' | grep -Ev "$NOISY_RE" || true)
if [ -n "$DIRTY_REAL" ]; then
  warn "uncommitted changes in tracked files:"
  echo "$DIRTY_REAL" | sed 's/^/  /'
  die "commit or stash first, then re-run" 1
fi

# Rust check (cargo must be on PATH).
if ! command -v cargo >/dev/null 2>&1; then
  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  fi
fi
command -v cargo >/dev/null 2>&1 || die "cargo not found — install rustup: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" 1
command -v node  >/dev/null 2>&1 || die "node not found" 1

START_SHA=$(git rev-parse HEAD)
ok "preflight passed (HEAD ${START_SHA:0:8})"

# ── pull ─────────────────────────────────────────────────────────────────
if [ "$PULL" = "1" ]; then
  log "git pull --rebase"
  run git pull --rebase
fi
END_SHA=$(git rev-parse HEAD)

if [ "$START_SHA" = "$END_SHA" ]; then
  log "no new commits — rebuilding current checkout anyway"
  N_COMMITS=0
else
  N_COMMITS=$(git rev-list "$START_SHA..$END_SHA" --count)
  ok "pulled $N_COMMITS new commit(s)"
fi

# ── install deps if package.json or package-lock.json changed ────────────
if [ "$INSTALL_DEPS" = "1" ] && [ "$N_COMMITS" -gt 0 ]; then
  if git diff --name-only "$START_SHA" "$END_SHA" | grep -qE "^(package\.json|package-lock\.json)$"; then
    log "package.json moved — npm install"
    run npm install
    ok "deps in sync"
  fi
fi

# ── build ────────────────────────────────────────────────────────────────
log "tauri build (this can take ~90s clean / ~5s incremental)"
if [ "$DRY" = "0" ]; then
  if ! npm run tauri:build 2>&1 | tail -100; then
    die "tauri build failed — installed app left untouched" 2
  fi
else
  echo "  [dry] npm run tauri:build"
fi

BUILT_APP=""
for cand in "${BUILT_APP_CANDIDATES[@]}"; do
  if [ -d "$cand" ]; then BUILT_APP="$cand"; break; fi
done
[ -n "$BUILT_APP" ] || die "build finished but $APP_BUNDLE_NAME not found" 2
APP_SIZE=$(du -sh "$BUILT_APP" 2>/dev/null | awk '{print $1}')
ok "built $BUILT_APP ($APP_SIZE)"

BUILT_DMG=""
for cand in "${BUILT_DMG_CANDIDATES[@]}"; do
  d=$(ls -1 "$cand"/*.dmg 2>/dev/null | head -n1 || true)
  if [ -n "$d" ]; then BUILT_DMG="$d"; break; fi
done

# ── quit running app ─────────────────────────────────────────────────────
if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
  log "quitting running $APP_NAME"
  if ! run osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null; then
    warn "graceful quit failed — killing"
    run pkill -x "$APP_NAME" || true
  fi
  # Wait up to 5s for the process to disappear.
  for _ in 1 2 3 4 5; do
    pgrep -x "$APP_NAME" >/dev/null 2>&1 || break
    sleep 1
  done
fi

# ── swap into /Applications ──────────────────────────────────────────────
if [ -d "$INSTALLED_APP" ]; then
  if [ -d "$PREV_APP" ]; then
    log "removing stale backup $PREV_APP"
    run rm -rf "$PREV_APP"
  fi
  log "backing up old app → ${PREV_APP##*/}"
  run mv "$INSTALLED_APP" "$PREV_APP"
fi
log "installing new app → $INSTALLED_APP"
run cp -R "$BUILT_APP" "$INSTALLED_APP" || die "cp into /Applications failed (perms?)" 3

# Strip Gatekeeper quarantine attribute so it opens without right-click on
# unsigned local builds.
if [ "$DRY" = "0" ]; then
  xattr -dr com.apple.quarantine "$INSTALLED_APP" 2>/dev/null || true
fi

# ── relaunch ─────────────────────────────────────────────────────────────
if [ "$RELAUNCH" = "1" ]; then
  log "launching $APP_NAME"
  run open "$INSTALLED_APP"
fi

# ── summary ──────────────────────────────────────────────────────────────
printf "\n"
printf "\033[32m═══════════════════════════════════════════════\033[0m\n"
printf "  \033[1msgnk-md updated\033[0m\n"
printf "\033[32m═══════════════════════════════════════════════\033[0m\n"
printf "  commits pulled : %s\n" "$N_COMMITS"
printf "  HEAD           : %s\n" "${END_SHA:0:8}"
printf "  app installed  : %s (%s)\n" "$INSTALLED_APP" "$APP_SIZE"
[ -n "$BUILT_DMG" ] && printf "  dmg            : %s\n" "$BUILT_DMG"
[ -d "$PREV_APP" ] && printf "  previous       : %s (rollback target)\n" "$PREV_APP"
printf "  login          : preserved (bundle ID ai.sgnk.md unchanged)\n"
[ "$RELAUNCH" = "1" ] && printf "  status         : launched\n" || printf "  status         : installed, not launched\n"
printf "\n"
