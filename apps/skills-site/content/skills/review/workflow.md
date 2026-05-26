# Review — Workflow

## Overview

How the `review` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# review — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Pre-landing PR review. Analyzes diff against the base branch for SQL safety, LLM trust boundary violations, conditional side effects, and other structural issues. Use when asked to "review this PR", "code review", "pre-landing review", or "check my diff". Proactively suggest when the user is about to merge or land code changes. (gstack)

## Triggers

- `review this PR`
- `code review`
- `pre-landing review`
- `check my diff`

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
23. Step 1: Check branch
24. Step 1.5: Scope Drift Detection
25. Implementation Items
26. Test Items
27. Migration Items
28. Cross-Repo / External Items
29. Step 2: Read the checklist
30. Step 2.5: Check for Greptile review comments
31. Step 3: Get the diff
32. Step 3.4: Workspace-aware queue status (advisory)
33. Step 3.5: Slop scan (advisory)
34. Prior Learnings
35. Step 4: Critical pass (core review)
36. Confidence Calibration
37. Step 4.5: Review Army — Specialist Dispatch
38. Step 5: Fix-First Review
39. Step 5.5: TODOS cross-reference
40. Step 5.6: Documentation staleness check
41. Step 5.7: Adversarial review (always-on)
42. Step 5.8: Persist Eng Review result
43. Capture Learnings
44. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/review`
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

- Claude — invoked via the `Skill` tool with `skill: "review"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Review/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/review/WORKFLOW.md_
