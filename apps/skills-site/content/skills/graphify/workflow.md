# Graphify — Workflow

## Overview

How the `graphify` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# graphify — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

any input (code, docs, papers, images, videos) to knowledge graph. Use when user asks any question about a codebase, documents, or project content - especially if graphify-out/ exists, treat the question as a /graphify query.

## How it works

Workflow outline (sections of `SKILL.md`):

1. Usage
2. What graphify is for
3. What You Must Do When Invoked
4. Interpreter guard for subcommands
5. For --update (incremental re-extraction)
6. For --cluster-only
7. For /graphify query
8. For /graphify path
9. For /graphify explain
10. For /graphify add
11. For --watch
12. For git commit hook
13. For native CLAUDE.md integration
14. Honesty Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/graphify`
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

- Claude — invoked via the `Skill` tool with `skill: "graphify"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Graphify/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/graphify/WORKFLOW.md_
