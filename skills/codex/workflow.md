# Codex — Workflow

## Overview

How the `codex` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# codex — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

OpenAI Codex CLI wrapper — three modes. Code review: independent diff review via codex review with pass/fail gate. Challenge: adversarial mode that tries to break your code. Consult: ask codex anything with session continuity for follow-ups. The "200 IQ autistic developer" second opinion. Use when asked to "codex review", "codex challenge", "ask codex", "second opinion", or "consult codex". (gstack) Voice triggers (speech-to-text aliases): "code x", "code ex", "get another opinion".

## Triggers

- `200 IQ autistic developer`
- `codex review`
- `codex challenge`
- `ask codex`
- `second opinion`
- `consult codex`
- `code x`
- `code ex`
- `get another opinion`

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
23. Step 0.4: Check codex binary
24. Step 0.5: Auth probe + version check
25. Step 0.6: Resolve portable roots
26. Step 1: Detect mode
27. Filesystem Boundary
28. Step 2A: Review Mode
29. Plan File Review Report
30. GSTACK REVIEW REPORT
31. Step 2B: Challenge (Adversarial) Mode
32. Step 2C: Consult Mode
33. Model & Reasoning
34. Cost Estimation
35. Error Handling
36. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/codex`
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

- Claude — invoked via the `Skill` tool with `skill: "codex"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Codex/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/codex/WORKFLOW.md_
