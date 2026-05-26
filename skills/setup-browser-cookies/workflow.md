# Setup Browser Cookies — Workflow

## Overview

How the `setup-browser-cookies` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# setup-browser-cookies — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Import cookies from your real Chromium browser into the headless browse session. Opens an interactive picker UI where you select which cookie domains to import. Use before QA testing authenticated pages. Use when asked to "import cookies", "login to the site", or "authenticate the browser". (gstack)

## Triggers

- `import cookies`
- `login to the site`
- `authenticate the browser`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Preamble (run first)
2. Plan Mode Safe Operations
3. Skill Invocation During Plan Mode
4. Skill routing
5. Artifacts Sync (skill start)
6. Model-Specific Behavioral Patch (claude)
7. Voice
8. Completion Status Protocol
9. Operational Self-Improvement
10. Telemetry (run last)
11. Plan Status Footer
12. CDP mode check
13. How it works
14. Steps
15. SETUP (run this check BEFORE any browse command)
16. Notes

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/setup-browser-cookies`
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

- Claude — invoked via the `Skill` tool with `skill: "setup-browser-cookies"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Setup Browser Cookies/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/setup-browser-cookies/WORKFLOW.md_
