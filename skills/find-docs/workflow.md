# Find Docs — Workflow

## Overview

How the `find-docs` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# find-docs — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Retrieves up-to-date documentation, API references, and code examples for any developer technology. Use this skill whenever the user asks about a specific library, framework, SDK, CLI tool, or cloud service -- even for well-known ones like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. Your training data may not reflect recent API changes or version updates.

## How it works

Workflow outline (sections of `SKILL.md`):

1. Workflow
2. Step 1: Resolve a Library
3. Step 2: Query Documentation
4. Authentication
5. Error Handling
6. Common Mistakes

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/find-docs`
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

- Claude — invoked via the `Skill` tool with `skill: "find-docs"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Find Docs/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/find-docs/WORKFLOW.md_
