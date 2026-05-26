# Supabase Postgres Best Practices — Workflow

## Overview

How the `supabase-postgres-best-practices` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# supabase-postgres-best-practices — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Postgres performance optimization and best practices from Supabase. Use this skill when writing, reviewing, or optimizing Postgres queries, schema designs, or database configurations.

## How it works

Workflow outline (sections of `SKILL.md`):

1. When to Apply
2. Rule Categories by Priority
3. How to Use
4. References

## Components

- `references/` (34): _contributing.md, _sections.md, _template.md, advanced-full-text-search.md, advanced-jsonb-indexing.md, conn-idle-timeout.md, conn-limits.md, conn-pooling.md, conn-prepared-statements.md, data-batch-inserts.md, data-n-plus-one.md, data-pagination.md, data-upsert.md, lock-advisory.md, lock-deadlock-prevention.md, lock-short-transactions.md, lock-skip-locked.md, monitor-explain-analyze.md, monitor-pg-stat-statements.md, monitor-vacuum-analyze.md, query-composite-indexes.md, query-covering-indexes.md, query-index-types.md, query-missing-indexes.md, query-partial-indexes.md, schema-constraints.md, schema-data-types.md, schema-foreign-key-indexes.md, schema-lowercase-identifiers.md, schema-partitioning.md, schema-primary-keys.md, security-privileges.md, security-rls-basics.md, security-rls-performance.md

## Invoke

- Slash: `/supabase-postgres-best-practices`
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

- Claude — invoked via the `Skill` tool with `skill: "supabase-postgres-best-practices"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Supabase Postgres Best Practices/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/supabase-postgres-best-practices/WORKFLOW.md_
