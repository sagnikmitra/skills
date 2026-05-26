# Vercel Cli With Tokens — Workflow

## Overview

How the `vercel-cli-with-tokens` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# vercel-cli-with-tokens — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Deploy and manage projects on Vercel using token-based authentication. Use when working with Vercel CLI using access tokens rather than interactive login — e.g. "deploy to vercel", "set up vercel", "add environment variables to vercel".

## Triggers

- `deploy to vercel`
- `set up vercel`
- `add environment variables to vercel`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Step 1: Locate the Vercel Token
2. Step 2: Locate the Project and Team
3. CLI Setup
4. Deploying a Project
5. Managing Environment Variables
6. Inspecting Deployments
7. Managing Domains
8. Working Agreement
9. Troubleshooting

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/vercel-cli-with-tokens`
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

- Claude — invoked via the `Skill` tool with `skill: "vercel-cli-with-tokens"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Vercel Cli With Tokens/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/vercel-cli-with-tokens/WORKFLOW.md_
