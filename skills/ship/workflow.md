# Ship — Workflow

## Overview

How the `ship` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# ship — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Ship workflow: detect + merge base branch, run tests, review diff, bump VERSION, update CHANGELOG, commit, push, create PR. Use when asked to "ship", "deploy", "push to main", "create a PR", "merge and push", or "get it deployed". Proactively invoke this skill (do NOT push/PR directly) when the user says code is ready, asks about deploying, wants to push code up, or asks to create a PR. (gstack)

## Triggers

- `ship`
- `deploy`
- `push to main`
- `create a PR`
- `merge and push`
- `get it deployed`

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
23. Step 1: Pre-flight
24. Review Readiness Dashboard
25. Step 2: Distribution Pipeline Check
26. Step 3: Merge the base branch (BEFORE tests)
27. Step 4: Test Framework Bootstrap
28. Test Framework Bootstrap
29. Step 5: Run tests (on merged code)
30. Test Failure Ownership Triage
31. Step 6: Eval Suites (conditional)
32. Step 7: Test Coverage Audit
33. Affected Pages/Routes
34. Key Interactions to Verify
35. Edge Cases
36. Critical Paths
37. Step 8: Plan Completion Audit
38. Implementation Items
39. Test Items
40. Migration Items
41. Cross-Repo / External Items
42. Step 8.1: Plan Verification
43. Prior Learnings
44. Step 8.2: Scope Drift Detection
45. Step 9: Pre-Landing Review
46. Confidence Calibration
47. Design Review (conditional, diff-scoped)
48. Step 9.1: Review Army — Specialist Dispatch
49. Step 10: Address Greptile review comments (if PR exists)
50. Step 11: Adversarial review (always-on)
51. Capture Learnings
52. Step 12: Version bump (auto-decide)
53. Step 13: CHANGELOG (auto-generate)
54. Step 14: TODOS.md (auto-update)
55. Step 15: Commit (bisectable chunks)
56. Step 16: Verification Gate
57. Step 17: Push
58. Step 18: Documentation sync (via subagent, before PR creation)
59. Step 19: Create PR/MR
60. Summary
61. Test Coverage
62. Pre-Landing Review
63. Design Review
64. Eval Results
65. Greptile Review
66. Scope Drift
67. Plan Completion
68. Verification Results
69. TODOS
70. Documentation
71. Test plan
72. Step 20: Persist ship metrics
73. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/ship`
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

- Claude — invoked via the `Skill` tool with `skill: "ship"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Ship/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/ship/WORKFLOW.md_
