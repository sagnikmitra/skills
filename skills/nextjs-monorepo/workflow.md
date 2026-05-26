# Nextjs Monorepo — Workflow

## Overview

How the `nextjs-monorepo` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# nextjs-monorepo — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Enterprise-grade Next.js monorepo clean architecture guide for full-stack templates using App Router, TypeScript, Prisma, Supabase, modular monolith structure, internal auth/RBAC, and strict layer separation.

## How it works

Workflow outline (sections of `SKILL.md`):

1. 0. Purpose
2. 1. Non-Negotiable Architectural Principles
3. 2. Recommended Architecture
4. 3. Architectural Layers
5. 4. Final Folder Structure
6. 8. Prisma Setup
7. 14. Actor Context
8. 15. Authorization Model
9. 19. Authentication Design
10. 21. Server Action Pattern
11. 22. Route Handler Pattern
12. 23. Use Case Pattern
13. 27. Zod Validation
14. 28. Error Handling
15. 29. Audit Logging
16. 30. Seed Data
17. 31. UI Guidelines
18. 32. Frontend Component Rules
19. 33. Testing Strategy
20. 34. Test Matrix
21. 35. CI/CD Requirements
22. 36. Recommended Scripts
23. 37. Database Portability Rules
24. 38. Mongo Adapter Preparation
25. 39. Supabase Positioning
26. 40. Security Checklist
27. 41. Implementation Phases
28. 42. Claude/Codex Working Rules
29. 43. Definition of Done
30. 44. Anti-Patterns to Reject
31. 45. Initial Build Target
32. 46. Final Architectural Position

## Components

Single-file skill — all instructions live in `SKILL.md`.

## Invoke

- Slash: `/nextjs-monorepo`
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

- Claude — invoked via the `Skill` tool with `skill: "nextjs-monorepo"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Nextjs Monorepo/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/nextjs-monorepo/WORKFLOW.md_
