# Autoplan — Workflow

## Overview

How the `autoplan` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# autoplan — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Auto-review pipeline — reads the full CEO, design, eng, and DX review skills from disk and runs them sequentially with auto-decisions using 6 decision principles. Surfaces taste decisions (close approaches, borderline scope, codex disagreements) at a final approval gate. One command, fully reviewed plan out. Use when asked to "auto review", "autoplan", "run all reviews", "review this plan automatically", or "make the decisions for me". Proactively suggest when the user has a plan file and wants to run the full review gauntlet without answering 15-30 intermediate questions. (gstack) Voice triggers (speech-to-text aliases): "auto plan", "automatic review".

## Triggers

- `auto review`
- `autoplan`
- `run all reviews`
- `review this plan automatically`
- `make the decisions for me`
- `auto plan`
- `automatic review`

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
22. Step 0: Detect platform and base branch
23. Prerequisite Skill Offer
24. The 6 Decision Principles
25. Decision Classification
26. Sequential Execution — MANDATORY
27. What "Auto-Decide" Means
28. Filesystem Boundary — Codex Prompts
29. Phase 0: Intake + Restore Point
30. Re-run Instructions
31. Original Plan State
32. Phase 0.5: Codex auth + version preflight
33. Phase 1: CEO Review (Strategy & Scope)
34. Phase 2: Design Review (conditional — skip if no UI scope)
35. Phase 3: Eng Review + Dual Voices
36. Phase 3.5: DX Review (conditional — skip if no developer-facing scope)
37. Decision Audit Trail
38. Decision Audit Trail
39. Pre-Gate Verification
40. Phase 4: Final Approval Gate
41. /autoplan Review Complete
42. Completion: Write Review Logs
43. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/autoplan`
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

- Claude — invoked via the `Skill` tool with `skill: "autoplan"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Autoplan/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/autoplan/WORKFLOW.md_
