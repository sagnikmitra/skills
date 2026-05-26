# Sgnk Next — Workflow

## Overview

How the `sgnk-next` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# sgnk-next — Complete Workflow

> Human-facing overview of what `sgnk-next` does end to end. The machine entry
> point is `SKILL.md`; depth lives in `references/`; enforcement in `scripts/`;
> turnkey config in `assets/`.

## Contents
1. What it is
2. Two entry modes
3. The lifecycle
4. Governing principles
5. Stage-by-stage workflow
6. The feature-build loop
7. Enforcement — the gates
8. Turnkey assets
9. End-to-end walkthroughs
10. Invocation
11. Definition of done
12. Component map

---

## 1. What it is

`sgnk-next` is a one-shot engine that takes **any Next.js (App Router) codebase**
from tangled to **clean hexagonal modular-monolith** architecture — gated in CI,
production-hardened, deploy-ready, and SaaS-commercializable. It consolidates the
`nextjs-monorepo` architecture laws, a 3-phase behavior-preserving migration, a
20-year scalability roadmap, SaaS-commercialization, and production/deployment
playbooks, with **proven enforcement scripts bundled** (zero runtime deps).

Runs in Claude Code, Codex, Gemini, or plain CI. Composes with `gvc`
(gvc = repo + Vercel + Cloudflare bootstrap; sgnk-next = architecture + features).

## 2. Two entry modes

```
┌─ CREATE ───────────► brand-new project from scratch
│   "create leadflow with X, Y, Z"
│
└─ TRANSFORM ────────► existing repo (any state of mess)
    "restructure / audit / clean up / make it scale / ready to ship"
```

The skill auto-detects which via Stage 0; if ambiguous it asks.

## 3. The lifecycle (the whole skill)

```
            ┌──────────────────────── TRANSFORM existing ────────────────────────┐
CREATE new  │                                                                     │
   │        ▼                                                                     ▼
SCAFFOLD → ANALYZE → RESTRUCTURE ─────► SCALE ──► COMMERCIALIZE ──► PRODUCTION-HARDEN ──► DEPLOY
            │        Phase 1 (no-server) Phase 3   saas-             production-           deployment-
         analyze.mjs Phase 2 (conclusive)(S1–S10)  commercializ.     readiness             readiness
         + gates                                    .md
```

Run end-to-end for a full transformation, or **jump to the stage the analysis
recommends**. Each stage gates the next. Every line, at every stage, holds the
code-quality bar (`references/code-quality-standards.md`).

## 4. Governing principles (apply throughout)

| Principle | Meaning |
|---|---|
| **Prime directive** | Structure changes; **behavior does not** through RESTRUCTURE. Routes, API responses, status codes, redirects, auth/session, DB schema, env names, UI stay **byte-identical** — provable via test suite + parity harness. Behavior/perf changes wait for SCALE/HARDEN. |
| **Target architecture** | Hexagonal ports-and-adapters in a modular monolith. Dependencies point inward: `app → presentation → application → domain`; `infrastructure` implements application ports; `container` wires them. (Next's recommended Data Access Layer, formalized.) |
| **Ports before adapters** | Interface in `application/ports.ts` → impl in `infrastructure` → wired in container. Callers depend on the port. |
| **Composition root is sacred** | `container/dependency-container.ts` is the ONLY wiring module app/presentation may import. |
| **DTOs cross boundaries, records don't** | Map rows→entities→DTOs in infra; no DB rows or query fragments in `app`. |
| **Env is infrastructure** | `process.env` only in `src/config` + `*/infrastructure`. |
| **Gate after every batch** | A red gate = stop and fix before continuing. Never accumulate violations. |

## 5. Stage-by-stage workflow

### STAGE 0 — ANALYZE (always first)
- **Run:** `analyze.mjs` (JSON scorecard + `recommendedEntryPhase` + `saasReadiness`), the three gates, and a Next-version/docs check.
- **Routing:**

  | Finding | Enter at |
  |---|---|
  | god-folders / `@/server\|lib\|components` exist | RESTRUCTURE · Phase 1 |
  | structure clean but app/app-layer import infra/container | RESTRUCTURE · Phase 2 |
  | `clean-architecture-report` = 0 | SCALE → COMMERCIALIZE → HARDEN → DEPLOY |
  | greenfield / new project | `scaffold.mjs` → `project-starter.md` |
- **Output:** honest report — strengths to keep + gaps with evidence — agreed **before any edit**.
- **Reference:** `references/analysis-playbook.md`.

### STAGE 1 — RESTRUCTURE (behavior-preserving)
- **Phase 1 — No-Server Migration** (`references/phase-1-no-server-migration.md`): delete `src/server` / `src/lib` / `src/components` by *moving* each file to its hexagonal home behind temporary re-export wrappers, then deleting the wrappers. Pure relocation. **Exit:** `server-folder-blocklist` green, 0 legacy-alias refs.
- **Phase 2 — Conclusive Pass** (`references/phase-2-conclusive-pass.md`): remove remaining infra/container leaks; add `dependency-container.ts`; move inline route/page orchestration into `application/use-cases`; flip ESLint layer rules to `error`. **Exit:** `clean-architecture-report` = **0**.
- **Supporting:** `references/architecture-rules.md` (laws), `references/target-structure.md` (folder tree + legacy→hexagonal file map), `references/code-patterns.md` (exact code per layer).

### STAGE 2 — SCALE
- **Reference:** `references/phase-3-scalability-roadmap.md` — S1–S10: rendering/caching (PPR/Cache Components), module encapsulation, stricter TS + formatter + Node pin, distributed cache/queue adapters, CI gate enforcement, OpenTelemetry, CSP, SEO/PWA, E2E, multi-region. Each item tagged `[no-behavior-change]` or `[behavior/perf change]`.

### STAGE 3 — COMMERCIALIZE (SaaS)
- **Reference:** `references/saas-commercialization.md` — multi-tenancy (**triple guard**: RLS + scoped-db + use-case authz), org/workspace/seat + invitations, billing/subscriptions/entitlements/quotas/usage-metering behind a provider port, plan gating via flags, onboarding/activation, GDPR data-rights + audit + retention, optional API product (hashed keys, OpenAPI, signed webhooks). Scoped by `saasReadiness`. Multi-tenancy is foundational — establish the triple guard early.

### STAGE 4 — PRODUCTION-HARDEN
- **Reference:** `references/production-readiness.md` — DAL/data-security, server-action security, validation, error handling, observability, CWV/performance, reliability (distributed cache/queue, idempotency, timeouts, circuit breakers), security headers + CSP, a11y, SEO, Next.js security audit. **Exit:** production go/no-go gate.

### STAGE 5 — DEPLOY
- **Reference:** `references/deployment-readiness.md` — target selection (Vercel / Node / Docker / static), `vercel.ts` config, Fluid Compute realities, env management, full CI pipeline (gates wired in), preview/prod/rollback, domains/CDN/caching, monitoring, go-live checklist.

## 6. The feature-build loop (build X / Y / Z)

Used in CREATE mode and whenever adding a requirement. Each feature is **one clean
vertical slice** through its module:

```
requirement → domain → port → use-case(+test) → infra adapter → mapper
            → Zod schema → route/page/server-action → UI → gate (npm run verify)
```

Reference: `references/project-starter.md` (worked example) + `references/code-patterns.md`.
Build in dependency order; re-verify after each slice.

## 7. Enforcement — the gates (run after every batch, wired into CI)

| Script | Checks | Pass |
|---|---|---|
| `analyze.mjs` | full scorecard + entry phase + SaaS readiness | (informational) |
| `clean-architecture-report.mjs` | app/presentation/application importing infra/container; `process.env`/framework/DB in domain/app | `total: 0` |
| `import-boundary-report.mjs` | `@/server` / `@/lib` / `@/components` refs | exit 0 |
| `server-folder-blocklist.mjs` | files left in god-folders | exit 0 |
| `route-inventory.mjs` | route list before/after parity | diff empty |
| `eslint-boundaries.config.mjs` | layer-direction + module entry-point | lint clean |

Plus the standard gate `typecheck → lint → test → build → budget`.
**A gate not in CI is not enforced** — `assets/ci.yml` wires them as required checks.

## 8. Turnkey assets (copy-in to industry-grade a repo fast)
- `assets/ci.yml` — 3 CI jobs (quality / architecture-gates / e2e).
- `assets/package-scripts.json` — scripts incl. `verify`, `arch`, `analyze`, `engines`.
- `assets/tsconfig.strict.json` — full strict flag set (`noUncheckedIndexedAccess`, …).
- `assets/adr-template.md` — decision-record template.
- `scripts/scaffold.mjs` — lays the canonical tree + per-layer READMEs + copies the gates into `specs/harness/`.

## 9. End-to-end walkthroughs

**A. New project**
```
/sgnk-next create leadflow with contacts, pipeline board, billing
```
1. `create-next-app` → `scaffold.mjs` (tree + gates) → apply assets (CI, tsconfig, scripts, eslint) → write spine (`config/env.ts`, `proxy.ts`, `dependency-container.ts`). First commit green.
2. Connect integrations behind ports (DB, auth, billing) via the container.
3. Feature-build loop for each: contacts → pipeline → billing (each a tested, gated vertical slice).
4. As it grows: SCALE → COMMERCIALIZE → HARDEN → DEPLOY.

**B. Existing messy repo**
```
/sgnk-next analyze
```
1. `analyze.mjs` + gates → report → agree entry phase.
2. Phase 1 (delete god-folders via wrappers) → `server-folder-blocklist` green.
3. Phase 2 (composition root + use-cases + ESLint error) → `clean-architecture-report` = 0.
4. SCALE / COMMERCIALIZE / HARDEN / DEPLOY as needed — each additive, never a rescue.

## 10. Invocation
- **Slash:** `/sgnk-next [analyze | create <name> with <features> | <task>]`
- **Natural language:** "restructure my next app", "sgnk.ai for next", "build me a SaaS in next", "is my next app ready to ship", "this won't scale".
- **Not this skill:** one-off Vercel deploys, LCP/perf tuning, monitoring/Sentry setup, a single build error, a SQL migration, PR code review, isolated UI tweak → defer to the better-fit tool.

## 11. Definition of done

Gates (`server-folder-blocklist`, `import-boundary-report`,
`clean-architecture-report`) at **0 and run in CI** as required checks; ESLint
layer rules at `error`; `typecheck`/`test`/`build`/`budget` green;
app/presentation/application import only ports, use-case DTOs, controllers, or the
composition root; routes/API/public URLs verified unchanged (Stage 1); production
go/no-go passed; deployment go-live checklist complete.

## 12. Component map

```
sgnk-next/
├── SKILL.md                       # machine entry point (lifecycle + routing + rules)
├── WORKFLOW.md                    # this document (human overview)
├── references/                    # depth, loaded on demand
│   ├── analysis-playbook.md          # Stage 0
│   ├── project-starter.md            # CREATE mode + feature-build loop
│   ├── architecture-rules.md         # the laws
│   ├── target-structure.md           # folder tree + file-placement map
│   ├── code-patterns.md              # exact code per layer
│   ├── code-quality-standards.md     # cross-cutting bar
│   ├── phase-1-no-server-migration.md
│   ├── phase-2-conclusive-pass.md
│   ├── phase-3-scalability-roadmap.md
│   ├── saas-commercialization.md
│   ├── production-readiness.md
│   ├── deployment-readiness.md
│   └── portability.md                # Claude / Codex / Gemini / CI wiring
├── scripts/                       # zero-dep enforcement + tooling
│   ├── analyze.mjs                   # one-shot scorecard
│   ├── scaffold.mjs                  # greenfield skeleton + gate copy
│   ├── clean-architecture-report.mjs # layer-direction gate
│   ├── import-boundary-report.mjs    # legacy-alias ban
│   ├── server-folder-blocklist.mjs   # god-folders-gone proof
│   ├── route-inventory.mjs           # route parity
│   └── eslint-boundaries.config.mjs  # layer rules
└── assets/                        # turnkey copy-in config
    ├── ci.yml
    ├── package-scripts.json
    ├── tsconfig.strict.json
    └── adr-template.md
```

## Execution Logic

The skill executes when its trigger fires (slash command, natural-language match, or direct invocation). It reads its references, applies its rules, and produces the documented outputs.

## Edge Cases

See the source skill's `references/` and `scripts/` folders for edge-case handling.

## Failure Handling

A skill failure surfaces as a tool error or a partial output; never a silent skip. Re-run with `--verbose` (where applicable) for diagnostics.

## Integration Notes

- Claude — invoked via the `Skill` tool with `skill: "sgnk-next"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Sgnk Next/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/sgnk-next/WORKFLOW.md_
