# Market Researcher — Workflow

## Overview

How the `market-researcher` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# market-researcher — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Expert market researcher that finds, analyzes, and ranks the best options for any topic or query. Use this skill whenever the user asks for recommendations, comparisons, or "best of" queries — such as "best restaurants near me", "top gyms in Bangalore", "which laptop should I buy", "recommend a plumber", "best SaaS tools for invoicing", or any question where the user wants vetted, fact-based suggestions ranked by quality. Also trigger when the user says "research for me", "compare options", "find the best", "suggest top 3", or "which is better". This skill eliminates guesswork and hallucination by grounding every recommendation in live web data, maps, and review analysis.

## Triggers

- `best of`
- `best restaurants near me`
- `top gyms in Bangalore`
- `which laptop should I buy`
- `recommend a plumber`
- `best SaaS tools for invoicing`
- `research for me`
- `compare options`
- `find the best`
- `suggest top 3`
- `which is better`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Core Principles
2. Research Workflow
3. 🏆 Top 3: [Topic] — [Location/Context if applicable]
4. Anti-Hallucination Rules
5. Location Context
6. Tool Usage Reference

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/market-researcher`
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

- Claude — invoked via the `Skill` tool with `skill: "market-researcher"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Market Researcher/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/market-researcher/WORKFLOW.md_
