# Sentry React Sdk — Workflow

## Overview

How the `sentry-react-sdk` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# sentry-react-sdk — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Full Sentry SDK setup for React. Use when asked to "add Sentry to React", "install @sentry/react", or configure error monitoring, tracing, session replay, profiling, or logging for React applications. Supports React 16+, React Router v5-v7, TanStack Router, Redux, Vite, and webpack.

## Triggers

- `add Sentry to React`
- `install @sentry/react`

## How it works

Workflow outline (sections of `SKILL.md`):

1. Invoke This Skill When
2. Phase 1: Detect
3. Phase 2: Recommend
4. Phase 3: Guide
5. Configuration Reference
6. Verification
7. Phase 4: Cross-Link
8. Troubleshooting

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/sentry-react-sdk`
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

- Claude — invoked via the `Skill` tool with `skill: "sentry-react-sdk"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Sentry React Sdk/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/sentry-react-sdk/WORKFLOW.md_
