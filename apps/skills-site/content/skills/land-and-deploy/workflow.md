# Land And Deploy — Workflow

## Overview

How the `land-and-deploy` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# land-and-deploy — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Land and deploy workflow. Merges the PR, waits for CI and deploy, verifies production health via canary checks. Takes over after /ship creates the PR. Use when: "merge", "land", "deploy", "merge and verify", "land it", "ship it to production". (gstack)

## Triggers

- `merge`
- `land`
- `deploy`
- `merge and verify`
- `land it`
- `ship it to production`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Preamble (run first)
2. Plan Mode Safe Operations
3. Skill Invocation During Plan Mode
4. Skill routing
5. AskUserQuestion Format
6. Artifacts Sync (skill start)
7. Model-Specific Behavioral Patch (claude)
8. Voice
9. Context Recovery
10. Writing Style (skip entirely if EXPLAIN_LEVEL: terse appears in the preamble echo OR the user's current message explicitly requests terse / no-explanations output)
11. Completeness Principle — Boil the Lake
12. Confusion Protocol
13. Continuous Checkpoint Mode
14. Context Health (soft directive)
15. Question Tuning (skip entirely if QUESTION_TUNING: false)
16. Repo Ownership — See Something, Say Something
17. Search Before Building
18. Completion Status Protocol
19. Operational Self-Improvement
20. Telemetry (run last)
21. Plan Status Footer
22. SETUP (run this check BEFORE any browse command)
23. Step 0: Detect platform and base branch
24. User-invocable
25. Arguments
26. Non-interactive philosophy (like /ship) — with one critical gate
27. Voice & Tone
28. Step 1: Pre-flight
29. Step 1.5: First-run dry-run validation
30. Step 2: Pre-merge checks
31. Step 3: Wait for CI (if pending)
32. Step 3.4: VERSION drift detection (workspace-aware ship)
33. Step 3.5: Pre-merge readiness gate
34. Step 4: Merge the PR
35. Step 5: Deploy strategy detection
36. Step 6: Wait for deploy (if applicable)
37. Step 7: Canary verification (conditional depth)
38. Step 8: Revert (if needed)
39. Step 9: Deploy report
40. Step 10: Suggest follow-ups
41. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/land-and-deploy`
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

- Claude — invoked via the `Skill` tool with `skill: "land-and-deploy"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Land And Deploy/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/land-and-deploy/WORKFLOW.md_
