# Benchmark — Workflow

## Overview

How the `benchmark` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# benchmark — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Performance regression detection using the browse daemon. Establishes baselines for page load times, Core Web Vitals, and resource sizes. Compares before/after on every PR. Tracks performance trends over time. Use when: "performance", "benchmark", "page speed", "lighthouse", "web vitals", "bundle size", "load time". (gstack) Voice triggers (speech-to-text aliases): "speed test", "check performance".

## Triggers

- `performance`
- `benchmark`
- `page speed`
- `lighthouse`
- `web vitals`
- `bundle size`
- `load time`
- `speed test`
- `check performance`

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
12. SETUP (run this check BEFORE any browse command)
13. User-invocable
14. Arguments
15. Instructions
16. Important Rules

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/benchmark`
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

- Claude — invoked via the `Skill` tool with `skill: "benchmark"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Benchmark/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/benchmark/WORKFLOW.md_
