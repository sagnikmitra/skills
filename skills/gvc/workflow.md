# Gvc — Workflow

## Overview

How the `gvc` skill works, step by step.

## Source Workflow

Codex skill workflow.

## Step-by-step Workflow

# gvc — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

GitHub + Vercel + Cloudflare project bootstrap. Use when the user gives a project name and wants a private GitHub repository, local clone, hello-world Next.js app, initial commit and push, Vercel project/deployment, Cloudflare DNS custom domain such as project.sgnk.ai, and live health checks. Trigger on requests like "use gvc for xyz", "create/deploy xyz", "make xyz.sgnk.ai live", or any one-name repo-to-Vercel-to-domain bootstrap.

## Triggers

- `use gvc for xyz`
- `create/deploy xyz`
- `make xyz.sgnk.ai live`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Overview
2. Project Name Rules
3. Quick Start
4. Workflow
5. Local Dev Launcher
6. Failure Rules
7. Resources

## Components

- `references/` (1): operator-guide.md
- `scripts/` (1): gvc_bootstrap.py
- `agents/` (1): openai.yaml

## Invoke

- Slash: `/gvc`
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

- Claude — invoked via the `Skill` tool with `skill: "gvc"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Gvc/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.codex/skills/gvc/WORKFLOW.md_
