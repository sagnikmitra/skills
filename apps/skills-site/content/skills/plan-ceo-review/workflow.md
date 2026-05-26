# Plan Ceo Review — Workflow

## Overview

How the `plan-ceo-review` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# plan-ceo-review — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

CEO/founder-mode plan review. Rethink the problem, find the 10-star product, challenge premises, expand scope when it creates a better product. Four modes: SCOPE EXPANSION (dream big), SELECTIVE EXPANSION (hold scope + cherry-pick expansions), HOLD SCOPE (maximum rigor), SCOPE REDUCTION (strip to essentials). Use when asked to "think bigger", "expand scope", "strategy review", "rethink this", or "is this ambitious enough". Proactively suggest when the user is questioning scope or ambition of a plan, or when the plan feels like it could be thinking bigger. (gstack)

## Triggers

- `think bigger`
- `expand scope`
- `strategy review`
- `rethink this`
- `is this ambitious enough`

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
23. Philosophy
24. Prime Directives
25. Engineering Preferences (use these to guide every recommendation)
26. Cognitive Patterns — How Great CEOs Think
27. Priority Hierarchy Under Context Pressure
28. PRE-REVIEW SYSTEM AUDIT (before Step 0)
29. Prerequisite Skill Offer
30. Prior Learnings
31. Step 0: Nuclear Scope Challenge + Mode Selection
32. Vision
33. Scope Decisions
34. Accepted Scope (added to this plan)
35. Deferred to TODOS.md
36. Spec Review Loop
37. Review Sections (11 sections, after scope and mode are agreed)
38. Outside Voice — Independent Plan Challenge (optional, recommended)
39. Post-Implementation Design Audit (if UI scope detected)
40. CRITICAL RULE — How to ask questions
41. Required Outputs
42. Handoff Note Cleanup
43. Review Log
44. Review Readiness Dashboard
45. Plan File Review Report
46. GSTACK REVIEW REPORT
47. Next Steps — Review Chaining
48. docs/designs Promotion (EXPANSION and SELECTIVE EXPANSION only)
49. Formatting Rules
50. Capture Learnings
51. Mode Quick Reference

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/plan-ceo-review`
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

- Claude — invoked via the `Skill` tool with `skill: "plan-ceo-review"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Plan Ceo Review/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/plan-ceo-review/WORKFLOW.md_
