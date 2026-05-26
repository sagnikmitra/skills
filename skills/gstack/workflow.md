# Gstack — Workflow

## Overview

How the `gstack` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# gstack — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Fast headless browser for QA testing and site dogfooding. Navigate pages, interact with elements, verify state, diff before/after, take annotated screenshots, test responsive layouts, forms, uploads, dialogs, and capture bug evidence. Use when asked to open or test a site, verify a deployment, dogfood a user flow, or file a bug with screenshots. (gstack)

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
13. IMPORTANT
14. QA Workflows
15. Quick Assertion Patterns
16. Snapshot System
17. Command Reference
18. Tips

## Components

- `scripts/` (31): analytics.ts, app, archetypes.ts, build-app.sh, compare-pr-version.ts, detect-bump.ts, dev-skill.ts, discover-skills.ts, eval-compare.ts, eval-list.ts, eval-select.ts, eval-summary.ts, eval-watch.ts, garry-output-comparison.ts, gen-llms-txt.ts, gen-skill-docs.ts, host-adapters, host-config-export.ts, host-config.ts, jargon-list.json, models.ts, one-way-doors.ts, preflight-agent-sdk.ts, psychographic-signals.ts, question-registry.ts, resolvers, setup-scc.sh, skill-check.ts, slop-diff.ts, test-free-shards.ts, update-readme-throughput.ts
- `agents/` (1): openai.yaml

## Invoke

- Slash: `/gstack`
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

- Claude — invoked via the `Skill` tool with `skill: "gstack"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Gstack/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/gstack/WORKFLOW.md_
