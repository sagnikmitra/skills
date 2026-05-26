# Careful — Workflow

## Overview

How the `careful` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# careful — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Safety guardrails for destructive commands. Warns before rm -rf, DROP TABLE, force-push, git reset --hard, kubectl delete, and similar destructive operations. User can override each warning. Use when touching prod, debugging live systems, or working in a shared environment. Use when asked to "be careful", "safety mode", "prod mode", or "careful mode". (gstack)

## Triggers

- `be careful`
- `safety mode`
- `prod mode`
- `careful mode`

## How it works

Workflow outline (sections of `SKILL.md`):

1. What's protected
2. Safe exceptions
3. How it works

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/careful`
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

- Claude — invoked via the `Skill` tool with `skill: "careful"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Careful/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/careful/WORKFLOW.md_
