# Web Design Guidelines — Workflow

## Overview

How the `web-design-guidelines` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# web-design-guidelines — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Review UI code for Web Interface Guidelines compliance. Use when asked to "review my UI", "check accessibility", "audit design", "review UX", or "check my site against best practices".

## Triggers

- `review my UI`
- `check accessibility`
- `audit design`
- `review UX`
- `check my site against best practices`

## How it works

Workflow outline (sections of `SKILL.md`):

1. How It Works
2. Guidelines Source
3. Usage

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/web-design-guidelines`
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

- Claude — invoked via the `Skill` tool with `skill: "web-design-guidelines"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Web Design Guidelines/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/web-design-guidelines/WORKFLOW.md_
