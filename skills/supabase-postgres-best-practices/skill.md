# Supabase Postgres Best Practices

## Purpose

Postgres performance optimization and best practices from Supabase. Use this skill when writing, reviewing, or optimizing Postgres queries, schema designs, or database configurations.

## Description

# Supabase Postgres Best Practices

Comprehensive performance optimization guide for Postgres, maintained by Supabase. Contains rules across 8 categories, prioritized by impact to guide automated query optimization and schema design.

## When to Apply

Reference these guidelines when:
- Writing SQL queries or designing schemas
- Implementing indexes or query optimization
- Reviewing database performance issues
- Configuring connection pooling or scaling
- Optimizing for Postgres-specific features
- Working with Row-Level Security (RLS)

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Query Performance | CRITICAL | `query-` |
| 2 | Connection Management | CRITICAL | `conn-` |
| 3 | Security & RLS | CRITICAL | `security-` |
| 4 | Schema Design | HIGH | `schema-` |
| 5 | Concurrency & Locking | MEDIUM-HIGH | `lock-` |
| 6 | Data Access Patterns | MEDIUM | `data-` |
| 7 | Monitoring & Diagnostics | LOW-MEDIUM | `monitor-` |
| 8 | Advanced Features | LOW | `advanced-` |

## How to Use

Read individual rule files for detailed explanations and SQL examples:

```
references/query-missing-indexes.md
references/query-partial-indexes.md
references/_sections.md
```

Each rule file contains:
- Brief explanation of why it matters
- Incorrect SQL example with explanation
- Correct SQL example with explanation
- Optional EXPLAIN output or metrics
- Additional context and references
- Supabase-specific notes (when applicable)

## References

- https://www.postgresql.org/docs/current/
- https://supabase.com/docs
- https://wiki.postgresql.org/wiki/Performance_Optimization
- https://supabase.com/docs/guides/database/overview
- https://supabase.com/docs/guides/auth/row-level-security

## Source

Claude

## Capabilities

- See original source for capabilities.

## Inputs

Inputs depend on the skill's trigger and arguments. See the source SKILL.md.

## Outputs

Outputs depend on the skill. Typical: files written, reports generated, agent actions performed.

## When To Use

When the user invokes `/supabase-postgres-best-practices` or describes a task the skill's description matches.

## Dependencies

See the source skill's references and scripts folders.

## Related Systems

- Claude (if synced from `~/.claude/skills/supabase-postgres-best-practices`)
- HQ Project — landing page Skills section
- MD Project (md.sgnk.ai) — `Skills/Supabase Postgres Best Practices/`
- Obsidian Vault — `Skills/Supabase Postgres Best Practices/`

## Examples

See workflow.md.

---

_Source: ~/.claude/skills/supabase-postgres-best-practices/SKILL.md_
_Category: General_
