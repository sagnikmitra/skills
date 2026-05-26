# Office Hours — Workflow

## Overview

How the `office-hours` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# office-hours — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

YC Office Hours — two modes. Startup mode: six forcing questions that expose demand reality, status quo, desperate specificity, narrowest wedge, observation, and future-fit. Builder mode: design thinking brainstorming for side projects, hackathons, learning, and open source. Saves a design doc. Use when asked to "brainstorm this", "I have an idea", "help me think through this", "office hours", or "is this worth building". Proactively invoke this skill (do NOT answer directly) when the user describes a new product idea, asks whether something is worth building, wants to think through design decisions for something that doesn't exist yet, or is exploring a concept before any code is written. Use before /plan-ceo-review or /plan-eng-review. (gstack)

## Triggers

- `brainstorm this`
- `I have an idea`
- `help me think through this`
- `office hours`
- `is this worth building`

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
23. Phase 1: Context Gathering
24. Prior Learnings
25. Phase 2A: Startup Mode — YC Product Diagnostic
26. Phase 2B: Builder Mode — Design Partner
27. Phase 2.5: Related Design Discovery
28. Phase 2.75: Landscape Awareness
29. Phase 3: Premise Challenge
30. Phase 3.5: Cross-Model Second Opinion (optional)
31. Phase 4: Alternatives Generation (MANDATORY)
32. Visual Design Exploration
33. Visual Sketch (UI ideas only)
34. Phase 4.5: Founder Signal Synthesis
35. Phase 5: Design Doc
36. Problem Statement
37. Demand Evidence
38. Status Quo
39. Target User & Narrowest Wedge
40. Constraints
41. Premises
42. Cross-Model Perspective
43. Approaches Considered
44. Recommended Approach
45. Open Questions
46. Success Criteria
47. Distribution Plan
48. Dependencies
49. The Assignment
50. What I noticed about how you think
51. Problem Statement
52. What Makes This Cool
53. Constraints
54. Premises
55. Cross-Model Perspective
56. Approaches Considered
57. Recommended Approach
58. Open Questions
59. Success Criteria
60. Distribution Plan
61. Next Steps
62. What I noticed about how you think
63. Spec Review Loop
64. Phase 6: Handoff — The Relationship Closing
65. Capture Learnings
66. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/office-hours`
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

- Claude — invoked via the `Skill` tool with `skill: "office-hours"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Office Hours/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/office-hours/WORKFLOW.md_
