# Plan Eng Review — Workflow

## Overview

How the `plan-eng-review` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# plan-eng-review — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Eng manager-mode plan review. Lock in the execution plan — architecture, data flow, diagrams, edge cases, test coverage, performance. Walks through issues interactively with opinionated recommendations. Use when asked to "review the architecture", "engineering review", or "lock in the plan". Proactively suggest when the user has a plan or design doc and is about to start coding — to catch architecture issues before implementation. (gstack) Voice triggers (speech-to-text aliases): "tech review", "technical review", "plan engineering review".

## Triggers

- `review the architecture`
- `engineering review`
- `lock in the plan`
- `tech review`
- `technical review`
- `plan engineering review`

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
22. Priority hierarchy
23. My engineering preferences (use these to guide your recommendations):
24. Cognitive Patterns — How Great Eng Managers Think
25. Documentation and diagrams:
26. BEFORE YOU START:
27. Prerequisite Skill Offer
28. Review Sections (after scope is agreed)
29. Prior Learnings
30. Confidence Calibration
31. Affected Pages/Routes
32. Key Interactions to Verify
33. Edge Cases
34. Critical Paths
35. Outside Voice — Independent Plan Challenge (optional, recommended)
36. CRITICAL RULE — How to ask questions
37. Required outputs
38. Retrospective learning
39. Formatting rules
40. Review Log
41. Review Readiness Dashboard
42. Plan File Review Report
43. GSTACK REVIEW REPORT
44. Capture Learnings
45. Next Steps — Review Chaining
46. Unresolved decisions

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/plan-eng-review`
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

- Claude — invoked via the `Skill` tool with `skill: "plan-eng-review"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Plan Eng Review/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/plan-eng-review/WORKFLOW.md_
