# Browse — Workflow

## Overview

How the `browse` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# browse — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Fast headless browser for QA testing and site dogfooding. Navigate any URL, interact with elements, verify page state, diff before/after actions, take annotated screenshots, check responsive layouts, test forms and uploads, handle dialogs, and assert element states. ~100ms per command. Use when you need to test a feature, verify a deployment, dogfood a user flow, or file a bug with evidence. Use when asked to "open in browser", "test the site", "take a screenshot", or "dogfood this". (gstack)

## Triggers

- `open in browser`
- `test the site`
- `take a screenshot`
- `dogfood this`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Preamble (run first)
2. Plan Mode Safe Operations
3. Skill Invocation During Plan Mode
4. Skill routing
5. Artifacts Sync (skill start)
6. Model-Specific Behavioral Patch (claude)
7. Voice
8. Completion Status Protocol
9. Operational Self-Improvement
10. Telemetry (run last)
11. Plan Status Footer
12. SETUP (run this check BEFORE any browse command)
13. Core QA Patterns
14. Puppeteer → browse cheatsheet
15. User Handoff
16. Headed Mode + Proxy + Anti-Bot Sites
17. Snapshot Flags
18. CSS Inspector & Style Modification
19. Full Command List

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/browse`
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

- Claude — invoked via the `Skill` tool with `skill: "browse"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Browse/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/browse/WORKFLOW.md_
