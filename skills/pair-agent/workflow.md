# Pair Agent — Workflow

## Overview

How the `pair-agent` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# pair-agent — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Pair a remote AI agent with your browser. One command generates a setup key and prints instructions the other agent can follow to connect. Works with OpenClaw, Hermes, Codex, Cursor, or any agent that can make HTTP requests. The remote agent gets its own tab with scoped access (read+write by default, admin on request). Use when asked to "pair agent", "connect agent", "share browser", "remote browser", "let another agent use my browser", or "give browser access". (gstack) Voice triggers (speech-to-text aliases): "pair agent", "connect agent", "share my browser", "remote browser access".

## Triggers

- `pair agent`
- `connect agent`
- `share browser`
- `remote browser`
- `let another agent use my browser`
- `give browser access`
- `share my browser`
- `remote browser access`

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
22. How it works
23. SETUP (run this check BEFORE any browse command)
24. Step 1: Check prerequisites
25. Step 2: Ask what they want
26. Step 3: Local or remote?
27. Step 4: Execute pairing
28. Step 5: Verify connection
29. What the remote agent can do
30. Troubleshooting
31. Platform-specific notes
32. Revoking access

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/pair-agent`
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

- Claude — invoked via the `Skill` tool with `skill: "pair-agent"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Pair Agent/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/pair-agent/WORKFLOW.md_
