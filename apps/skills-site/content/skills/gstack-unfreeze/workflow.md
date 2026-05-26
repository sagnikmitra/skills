# Gstack Unfreeze — Workflow

## Overview

How the `gstack-unfreeze` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly -->
<!-- Regenerate: bun run gen:skill-docs -->

# /unfreeze — Clear Freeze Boundary

Remove the edit restriction set by `/freeze`, allowing edits to all directories.

```bash
mkdir -p ~/.gstack/analytics
echo '{"skill":"unfreeze","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","repo":"'$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")'"}'  >> ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null || true
```

## Clear the boundary

```bash
eval "$(~/.claude/skills/gstack/bin/gstack-paths)"
STATE_DIR="$GSTACK_STATE_ROOT"
if [ -f "$STATE_DIR/freeze-dir.txt" ]; then
  PREV=$(cat "$STATE_DIR/freeze-dir.txt")
  rm -f "$STATE_DIR/freeze-dir.txt"
  echo "Freeze boundary cleared (was: $PREV). Edits are now allowed everywhere."
else
  echo "No freeze boundary was set."
fi
```

Tell the user the result. Note that `/freeze` hooks are still registered for the
session — they will just allow everything since no state file exists. To re-freeze,
run `/freeze` again.

## Execution Logic

The skill executes when its trigger fires (slash command, natural-language match, or direct invocation). It reads its references, applies its rules, and produces the documented outputs.

## Edge Cases

See the source skill's `references/` and `scripts/` folders for edge-case handling.

## Failure Handling

A skill failure surfaces as a tool error or a partial output; never a silent skip. Re-run with `--verbose` (where applicable) for diagnostics.

## Integration Notes

- Claude — invoked via the `Skill` tool with `skill: "gstack-unfreeze"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Gstack Unfreeze/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: (none)_
