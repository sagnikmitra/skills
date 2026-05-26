# Design Review — Workflow

## Overview

How the `design-review` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# design-review — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Designer's eye QA: finds visual inconsistency, spacing issues, hierarchy problems, AI slop patterns, and slow interactions — then fixes them. Iteratively fixes issues in source code, committing each fix atomically and re-verifying with before/after screenshots. For plan-mode design review (before implementation), use /plan-design-review. Use when asked to "audit the design", "visual QA", "check if it looks good", or "design polish". Proactively suggest when the user mentions visual inconsistencies or wants to polish the look of a live site. (gstack)

## Triggers

- `audit the design`
- `visual QA`
- `check if it looks good`
- `design polish`

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
22. Setup
23. SETUP (run this check BEFORE any browse command)
24. Test Framework Bootstrap
25. DESIGN SETUP (run this check BEFORE any design mockup command)
26. Prior Learnings
27. UX Principles: How Users Actually Behave
28. Phases 1-6: Design Audit Baseline
29. Modes
30. Phase 1: First Impression
31. Phase 2: Design System Extraction
32. Phase 3: Page-by-Page Visual Audit
33. Phase 4: Interaction Flow Review
34. Phase 5: Cross-Page Consistency
35. Phase 6: Compile Report
36. Design Critique Format
37. Important Rules
38. Output Structure
39. Design Outside Voices (parallel)
40. Phase 7: Triage
41. Phase 8: Fix Loop
42. Phase 9: Final Design Audit
43. Phase 10: Report
44. Phase 11: TODOS.md Update
45. Capture Learnings
46. Additional Rules (design-review specific)

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/design-review`
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

- Claude — invoked via the `Skill` tool with `skill: "design-review"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Design Review/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/design-review/WORKFLOW.md_
