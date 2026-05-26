# Gstack Upgrade — Workflow

## Overview

How the `gstack-upgrade` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# gstack-upgrade — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Upgrade gstack to the latest version. Detects global vs vendored install, runs the upgrade, and shows what's new. Use when asked to "upgrade gstack", "update gstack", or "get latest version". Voice triggers (speech-to-text aliases): "upgrade the tools", "update the tools", "gee stack upgrade", "g stack upgrade".

## Triggers

- `s new. Use when asked to`
- `update gstack`
- `get latest version`
- `upgrade the tools`
- `update the tools`
- `gee stack upgrade`
- `g stack upgrade`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Inline upgrade flow
2. Standalone usage

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/gstack-upgrade`
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

- Claude — invoked via the `Skill` tool with `skill: "gstack-upgrade"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Gstack Upgrade/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/gstack-upgrade/WORKFLOW.md_
