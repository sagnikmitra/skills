# Deploy To Vercel — Workflow

## Overview

How the `deploy-to-vercel` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# deploy-to-vercel — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Deploy applications and websites to Vercel. Use when the user requests deployment actions like "deploy my app", "deploy and give me the link", "push this live", or "create a preview deployment".

## Triggers

- `deploy my app`
- `deploy and give me the link`
- `push this live`
- `create a preview deployment`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Step 1: Gather Project State
2. Step 2: Choose a Deploy Method
3. Agent-Specific Notes
4. Output
5. Troubleshooting

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/deploy-to-vercel`
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

- Claude — invoked via the `Skill` tool with `skill: "deploy-to-vercel"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Deploy To Vercel/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/deploy-to-vercel/WORKFLOW.md_
