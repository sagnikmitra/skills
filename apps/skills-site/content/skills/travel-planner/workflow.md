# Travel Planner — Workflow

## Overview

How the `travel-planner` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# travel-planner — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Expert travel planner and itinerary creator. Use this skill whenever a user asks about planning a trip, visiting a place, travel itinerary, where to stay, what to eat, places to visit, road trips, travel budget, or any travel-related planning query. Triggers include: "plan a trip to X", "itinerary for X", "visiting X for N days", "best places in X", "where to stay in X", "what to eat in X", "road trip to X", "family trip to X", "travel guide for X", "budget travel X", or any message mentioning a destination alongside travel intent. This skill does real research — web searches, map data, review analysis — and never hallucinates. Always use this skill instead of relying on memory for travel advice.

## Triggers

- `plan a trip to X`
- `itinerary for X`
- `visiting X for N days`
- `best places in X`
- `where to stay in X`
- `what to eat in X`
- `road trip to X`
- `family trip to X`
- `travel guide for X`
- `budget travel X`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Step 0 — Gather Trip Context (if not already provided)
2. Step 1 — Research Phase
3. Step 2 — Review Filtering
4. Step 3 — Route Optimization (Own Vehicle or Walking Routes)
5. Step 4 — Build the Itinerary
6. ✈️ Trip Plan: [Destination] — [Duration] | [Month/Season] | [Trip Type]
7. Anti-Hallucination Rules
8. Tool Usage Reference
9. Tone & Style

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/travel-planner`
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

- Claude — invoked via the `Skill` tool with `skill: "travel-planner"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Travel Planner/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/travel-planner/WORKFLOW.md_
