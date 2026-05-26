# Open Gstack Browser — Workflow

## Overview

How the `open-gstack-browser` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# open-gstack-browser — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Launch GStack Browser — AI-controlled Chromium with the sidebar extension baked in. Opens a visible browser window where you can watch every action in real time. The sidebar shows a live activity feed and chat. Anti-bot stealth built in. Use when asked to "open gstack browser", "launch browser", "connect chrome", "open chrome", "real browser", "launch chrome", "side panel", or "control my browser". Voice triggers (speech-to-text aliases): "show me the browser".

## Triggers

- `open gstack browser`
- `launch browser`
- `connect chrome`
- `open chrome`
- `real browser`
- `launch chrome`
- `side panel`
- `control my browser`
- `show me the browser`

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
23. Step 0: Pre-flight cleanup
24. Step 1: Connect
25. Step 2: Verify
26. Step 3: Guide the user to the Side Panel
27. Step 4: Demo
28. Step 5: Sidebar chat
29. Step 6: What's next

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/open-gstack-browser`
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

- Claude — invoked via the `Skill` tool with `skill: "open-gstack-browser"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Open Gstack Browser/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/open-gstack-browser/WORKFLOW.md_
