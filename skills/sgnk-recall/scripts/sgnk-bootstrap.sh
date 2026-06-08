#!/usr/bin/env bash
# sgnk-bootstrap.sh — one-time, idempotent, PER-REPO cross-tool wiring:
#   * add ".sgnk/" to the repo .gitignore (snapshots stay local by default)
#   * write a single delimited SGNK pointer block into each tool's instruction file
#     so Codex/Copilot/Cursor/Windsurf/Antigravity auto-read .sgnk/LATEST-KEY.md too.
# Re-running replaces the block in place; it never duplicates or touches other content.
#
# Usage: sgnk-bootstrap.sh <REPO_ROOT>
set -uo pipefail
REPO="${1:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$REPO" ] && [ -d "$REPO" ] || { echo "sgnk-bootstrap: not a repo: $REPO" >&2; exit 1; }

BEGIN="<!-- SGNK:BEGIN -->"
END="<!-- SGNK:END -->"
read -r -d '' BODY <<'EOF' || true
Before doing anything, read `.sgnk/LATEST-KEY.md` for prior-session context (it
references the matching `.sgnk/snapshots/<id>/manifest.json`). Follow the REPLAY
block, avoid the listed DEAD-ENDS, and run `/sgnk-recall` if your tool supports it.
EOF

# 1. .gitignore
GI="$REPO/.gitignore"
if [ ! -f "$GI" ] || ! grep -qxF '.sgnk/' "$GI" 2>/dev/null; then
  printf '\n# SGNK continuity snapshots (local working memory)\n.sgnk/\n' >> "$GI"
  echo "gitignore: added .sgnk/"
else
  echo "gitignore: .sgnk/ already present"
fi

# upsert a delimited block into a file; preserves all other content.
# Strategy: strip any existing block, trim trailing blanks, then append a fresh
# block. Stable across re-runs (no growth). awk only ever sees single-line
# delimiters as -v (BSD awk rejects multiline -v values).
upsert_block() { # <file> [frontmatter]
  local file="$1" frontmatter="${2:-}" dir tmp had_block=0
  dir="$(dirname "$file")"; mkdir -p "$dir"
  tmp="$file.sgnk.tmp.$$"

  if [ -f "$file" ]; then
    grep -qF "$BEGIN" "$file" 2>/dev/null && had_block=1
    awk -v b="$BEGIN" -v e="$END" 'BEGIN{skip=0} $0==b{skip=1;next} $0==e{skip=0;next} skip==0{print}' "$file" > "$tmp"
  elif [ -n "$frontmatter" ]; then
    printf '%s\n' "$frontmatter" > "$tmp"
  else
    : > "$tmp"
  fi

  # trim trailing blank lines so the separator stays exactly one line
  awk 'NF{last=NR} {line[NR]=$0} END{for(i=1;i<=last;i++) print line[i]}' "$tmp" > "$tmp.2" && mv -f "$tmp.2" "$tmp"

  { [ -s "$tmp" ] && printf '\n'; printf '%s\n%s\n%s\n' "$BEGIN" "$BODY" "$END"; } >> "$tmp"
  mv -f "$tmp" "$file"

  if [ "$had_block" -eq 1 ]; then echo "updated block: ${file#$REPO/}"; else echo "added block: ${file#$REPO/}"; fi
}

upsert_block "$REPO/AGENTS.md"
upsert_block "$REPO/.github/copilot-instructions.md"
upsert_block "$REPO/.windsurfrules"
# Current Cursor reads .cursor/rules/*.mdc (NOT legacy .md) and wants frontmatter.
upsert_block "$REPO/.cursor/rules/sgnk.mdc" "$(printf -- '---\ndescription: SGNK continuity — read prior-session handoff\nalwaysApply: true\n---')"

echo
echo "NOTE: if AGENTS.md or .claude/ is gitignored in this repo, the block is LOCAL-only —"
echo "every tool on THIS machine still auto-reads it, but it won't reach teammates via git."
echo "That's fine for solo cross-tool continuity. Use /sgnk-snapshot ... sync to share."
