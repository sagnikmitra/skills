# Unfreeze — Workflow

## Overview

How the `unfreeze` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# unfreeze — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Clear the freeze boundary set by /freeze, allowing edits to all directories again. Use when you want to widen edit scope without ending the session. Use when asked to "unfreeze", "unlock edits", "remove freeze", or "allow all edits". (gstack)

## Triggers

- `unfreeze`
- `unlock edits`
- `remove freeze`
- `allow all edits`

## How it works

1. Invoke the skill (`/unfreeze` or matching natural-language request).
2. Claude loads `SKILL.md` and follows its instructions.
3. It produces the output described above, using any bundled resources.

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/unfreeze`
- Or a natural-language request matching the triggers above.

---
_Source: `SKILL.md` in this directory._

## Execution Logic

The skill executes when its trigger fires (slash command, natural-language match, or direct invocation). It reads its references, applies its rules, and produces the documented outputs.

## Edge Cases

See the source skill's `references/` and `scripts/` folders for edge-case handling.

## Failure Handling

A skill failure surfaces as a tool error or a partial output; never a silent skip. Re-run with `--verbose` (where applicable) for diagnostics.

## Integration Notes

- Claude — invoked via the `Skill` tool with `skill: "unfreeze"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Unfreeze/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/unfreeze/WORKFLOW.md_
