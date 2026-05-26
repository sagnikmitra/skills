# Plan Devex Review — Workflow

## Overview

How the `plan-devex-review` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# plan-devex-review — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Interactive developer experience plan review. Explores developer personas, benchmarks against competitors, designs magical moments, and traces friction points before scoring. Three modes: DX EXPANSION (competitive advantage), DX POLISH (bulletproof every touchpoint), DX TRIAGE (critical gaps only). Use when asked to "DX review", "developer experience audit", "devex review", or "API design review". Proactively suggest when the user has a plan for developer-facing products (APIs, CLIs, SDKs, libraries, platforms, docs). (gstack) Voice triggers (speech-to-text aliases): "dx review", "developer experience review", "devex review", "devex audit", "API design review", "onboarding review".

## Triggers

- `DX review`
- `developer experience audit`
- `devex review`
- `API design review`
- `dx review`
- `developer experience review`
- `devex audit`
- `onboarding review`

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
23. DX First Principles
24. The Seven DX Characteristics
25. Cognitive Patterns — How Great DX Leaders Think
26. DX Scoring Rubric (0-10 calibration)
27. TTHW Benchmarks (Time to Hello World)
28. Hall of Fame Reference
29. Priority Hierarchy Under Context Pressure
30. PRE-REVIEW SYSTEM AUDIT (before Step 0)
31. Prerequisite Skill Offer
32. Auto-Detect Product Type + Applicability Gate
33. Step 0: DX Investigation (before scoring)
34. The 0-10 Rating Method
35. Review Sections (8 passes, after Step 0 is complete)
36. Prior Learnings
37. Outside Voice — Independent Plan Challenge (optional, recommended)
38. CRITICAL RULE — How to ask questions
39. Required Outputs
40. Review Readiness Dashboard
41. Plan File Review Report
42. GSTACK REVIEW REPORT
43. Capture Learnings
44. Next Steps — Review Chaining
45. Mode Quick Reference
46. Formatting Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/plan-devex-review`
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

- Claude — invoked via the `Skill` tool with `skill: "plan-devex-review"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Plan Devex Review/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/plan-devex-review/WORKFLOW.md_
