# Plan Design Review — Workflow

## Overview

How the `plan-design-review` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# plan-design-review — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Designer's eye plan review — interactive, like CEO and Eng review. Rates each design dimension 0-10, explains what would make it a 10, then fixes the plan to get there. Works in plan mode. For live site visual audits, use /design-review. Use when asked to "review the design plan" or "design critique". Proactively suggest when the user has a plan with UI/UX components that should be reviewed before implementation. (gstack)

## Triggers

- `review the design plan`
- `design critique`

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
23. Design Philosophy
24. Design Principles
25. Cognitive Patterns — How Great Designers See
26. UX Principles: How Users Actually Behave
27. Priority Hierarchy Under Context Pressure
28. PRE-REVIEW SYSTEM AUDIT (before Step 0)
29. DESIGN SETUP (run this check BEFORE any design mockup command)
30. Step 0: Design Scope Assessment
31. Step 0.5: Visual Mockups (DEFAULT when DESIGN_READY)
32. Design Outside Voices (parallel)
33. The 0-10 Rating Method
34. Review Sections (7 passes, after scope is agreed)
35. Prior Learnings
36. CRITICAL RULE — How to ask questions
37. Required Outputs
38. Approved Mockups
39. Review Log
40. Review Readiness Dashboard
41. Plan File Review Report
42. GSTACK REVIEW REPORT
43. Capture Learnings
44. Next Steps — Review Chaining
45. Formatting Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/plan-design-review`
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

- Claude — invoked via the `Skill` tool with `skill: "plan-design-review"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Plan Design Review/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/plan-design-review/WORKFLOW.md_
