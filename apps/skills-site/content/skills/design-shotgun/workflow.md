# Design Shotgun — Workflow

## Overview

How the `design-shotgun` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# design-shotgun — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Design shotgun: generate multiple AI design variants, open a comparison board, collect structured feedback, and iterate. Standalone design exploration you can run anytime. Use when: "explore designs", "show me options", "design variants", "visual brainstorm", or "I don't like how this looks". Proactively suggest when the user describes a UI feature but hasn't seen what it could look like. (gstack)

## Triggers

- `explore designs`
- `show me options`
- `design variants`
- `visual brainstorm`
- `I don`

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
20. DESIGN SETUP (run this check BEFORE any design mockup command)
21. UX Principles: How Users Actually Behave
22. Step 0: Session Detection
23. Step 1: Context Gathering
24. Step 2: Taste Memory
25. Step 3: Generate Variants
26. Step 4: Comparison Board + Feedback Loop
27. Step 5: Feedback Confirmation
28. Step 6: Save & Next Steps
29. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/design-shotgun`
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

- Claude — invoked via the `Skill` tool with `skill: "design-shotgun"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Design Shotgun/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/design-shotgun/WORKFLOW.md_
