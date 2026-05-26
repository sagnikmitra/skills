# Investigate — Workflow

## Overview

How the `investigate` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# investigate — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Systematic debugging with root cause investigation. Four phases: investigate, analyze, hypothesize, implement. Iron Law: no fixes without root cause. Use when asked to "debug this", "fix this bug", "why is this broken", "investigate this error", or "root cause analysis". Proactively invoke this skill (do NOT debug directly) when the user reports errors, 500 errors, stack traces, unexpected behavior, "it was working yesterday", or is troubleshooting why something stopped working. (gstack)

## Triggers

- `debug this`
- `fix this bug`
- `why is this broken`
- `investigate this error`
- `root cause analysis`
- `it was working yesterday`

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
20. Iron Law
21. Phase 1: Root Cause Investigation
22. Prior Learnings
23. Scope Lock
24. Phase 2: Pattern Analysis
25. Phase 3: Hypothesis Testing
26. Phase 4: Implementation
27. Phase 5: Verification & Report
28. Capture Learnings
29. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/investigate`
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

- Claude — invoked via the `Skill` tool with `skill: "investigate"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Investigate/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/investigate/WORKFLOW.md_
