# Design Consultation — Workflow

## Overview

How the `design-consultation` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# design-consultation — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Design consultation: understands your product, researches the landscape, proposes a complete design system (aesthetic, typography, color, layout, spacing, motion), and generates font+color preview pages. Creates DESIGN.md as your project's design source of truth. For existing sites, use /plan-design-review to infer the system instead. Use when asked to "design system", "brand guidelines", or "create DESIGN.md". Proactively suggest when starting a new project's UI with no existing design system or DESIGN.md. (gstack)

## Triggers

- `design system`
- `brand guidelines`
- `create DESIGN.md`

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
22. Phase 0: Pre-checks
23. SETUP (run this check BEFORE any browse command)
24. DESIGN SETUP (run this check BEFORE any design mockup command)
25. Prior Learnings
26. Phase 1: Product Context
27. Phase 2: Research (only if user said yes)
28. Design Outside Voices (parallel)
29. Phase 3: The Complete Proposal
30. Phase 4: Drill-downs (only if user requests adjustments)
31. Phase 5: Design System Preview (default ON)
32. Phase 6: Write DESIGN.md & Confirm
33. Product Context
34. Aesthetic Direction
35. Typography
36. Color
37. Spacing
38. Layout
39. Motion
40. Decisions Log
41. Design System
42. Capture Learnings
43. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/design-consultation`
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

- Claude — invoked via the `Skill` tool with `skill: "design-consultation"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Design Consultation/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/design-consultation/WORKFLOW.md_
