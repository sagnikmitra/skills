# Document Release — Workflow

## Overview

How the `document-release` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# document-release — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Post-ship documentation update. Reads all project docs, cross-references the diff, builds a Diataxis coverage map (reference/how-to/tutorial/explanation), updates README/ARCHITECTURE/CONTRIBUTING/CLAUDE.md to match what shipped, detects architecture diagram drift, polishes CHANGELOG voice with a sell-test rubric, cleans up TODOS, and optionally bumps VERSION. Surfaces documentation debt in the PR body. Use when asked to "update the docs", "sync documentation", or "post-ship docs". Proactively suggest after a PR is merged or code is shipped. (gstack)

## Triggers

- `update the docs`
- `sync documentation`
- `post-ship docs`

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
16. Completion Status Protocol
17. Operational Self-Improvement
18. Telemetry (run last)
19. Plan Status Footer
20. Step 0: Detect platform and base branch
21. Step 1: Pre-flight & Diff Analysis
22. Step 1.5: Coverage Map (Blast-Radius Analysis)
23. Step 2: Per-File Documentation Audit
24. Step 3: Apply Auto-Updates
25. Step 4: Ask About Risky/Questionable Changes
26. Step 5: CHANGELOG Voice Polish
27. Step 6: Cross-Doc Consistency & Discoverability Check
28. Step 7: TODOS.md Cleanup
29. Step 8: VERSION Bump Question
30. Step 9: Commit & Output
31. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/document-release`
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

- Claude — invoked via the `Skill` tool with `skill: "document-release"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Document Release/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/document-release/WORKFLOW.md_
