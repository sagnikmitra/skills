# Cso — Workflow

## Overview

How the `cso` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# cso — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Chief Security Officer mode. Infrastructure-first security audit: secrets archaeology, dependency supply chain, CI/CD pipeline security, LLM/AI security, skill supply chain scanning, plus OWASP Top 10, STRIDE threat modeling, and active verification. Two modes: daily (zero-noise, 8/10 confidence gate) and comprehensive (monthly deep scan, 2/10 bar). Trend tracking across audit runs. Use when: "security audit", "threat model", "pentest review", "OWASP", "CSO review". (gstack) Voice triggers (speech-to-text aliases): "see-so", "see so", "security review", "security check", "vulnerability scan", "run security".

## Triggers

- `security audit`
- `threat model`
- `pentest review`
- `OWASP`
- `CSO review`
- `see-so`
- `see so`
- `security review`
- `security check`
- `vulnerability scan`
- `run security`

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
20. User-invocable
21. Arguments
22. Mode Resolution
23. Important: Use the Grep tool for all code searches
24. Instructions
25. Prior Learnings
26. Confidence Calibration
27. Finding N: [Title] — [File:Line]
28. Capture Learnings
29. Important Rules
30. Disclaimer

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/cso`
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

- Claude — invoked via the `Skill` tool with `skill: "cso"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Cso/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/cso/WORKFLOW.md_
