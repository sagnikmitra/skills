# Devex Review — Workflow

## Overview

How the `devex-review` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# devex-review — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Live developer experience audit. Uses the browse tool to actually TEST the developer experience: navigates docs, tries the getting started flow, times TTHW, screenshots error messages, evaluates CLI help text. Produces a DX scorecard with evidence. Compares against /plan-devex-review scores if they exist (the boomerang: plan said 3 minutes, reality says 8). Use when asked to "test the DX", "DX audit", "developer experience test", or "try the onboarding". Proactively suggest after shipping a developer-facing feature. (gstack) Voice triggers (speech-to-text aliases): "dx audit", "test the developer experience", "try the onboarding", "developer experience test".

## Triggers

- `test the DX`
- `DX audit`
- `developer experience test`
- `try the onboarding`
- `dx audit`
- `test the developer experience`

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
23. SETUP (run this check BEFORE any browse command)
24. DX First Principles
25. The Seven DX Characteristics
26. Cognitive Patterns — How Great DX Leaders Think
27. DX Scoring Rubric (0-10 calibration)
28. TTHW Benchmarks (Time to Hello World)
29. Hall of Fame Reference
30. Scope Declaration
31. Step 0: Target Discovery
32. Step 1: Getting Started Audit
33. Step 2: API/CLI/SDK Ergonomics Audit
34. Step 3: Error Message Audit
35. Step 4: Documentation Audit
36. Step 5: Upgrade Path Audit
37. Step 6: Developer Environment Audit
38. Step 7: Community & Ecosystem Audit
39. Step 8: DX Measurement Audit
40. DX Scorecard with Evidence
41. Boomerang Comparison
42. Review Log
43. Review Readiness Dashboard
44. Plan File Review Report
45. GSTACK REVIEW REPORT
46. Capture Learnings
47. Next Steps
48. Formatting Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/devex-review`
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

- Claude — invoked via the `Skill` tool with `skill: "devex-review"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Devex Review/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/devex-review/WORKFLOW.md_
