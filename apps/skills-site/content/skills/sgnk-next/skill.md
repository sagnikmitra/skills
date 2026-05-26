# Sgnk Next

## Purpose

Restructures, scaffolds, or ships a Next.js codebase into clean hexagonal modular-monolith architecture. Use for new Next projects, building features, SaaS, messy structure (src/server|lib god-folders, won't scale), or production/deploy readiness.

## Description

# sgnk-next — Next.js Analyze · Restructure · Productionize · Deploy

Takes a Next.js App Router codebase from tangled to clean hexagonal modular
monolith — gated in CI, production-hardened, deploy-ready. Consolidates the
`nextjs-monorepo` laws, a 3-phase migration, a 20-year scalability roadmap,
SaaS-commercialization, and production/deploy playbooks, with enforcement scripts
bundled.

## The lifecycle (this is the whole skill)

```
ANALYZE → RESTRUCTURE → SCALE → COMMERCIALIZE → PRODUCTION-HARDEN → DEPLOY
  │           │            │          │                │               │
analyze.mjs  Phase 1+2   Phase 3   saas-           production-      deployment-
+ playbook   (no-server  (S1–S10)  commercial-     readiness.md     readiness.md
+ scaffold    +conclusive)         ization.md
```

Run it end-to-end for a full transformation, or jump to the stage the analysis
says the repo needs. Each stage gates the next. **Code-quality standards
(`references/code-quality-standards.md`) apply to every line written in every
stage** — they are the bar for "industry-grade." Greenfield projects start with
`scripts/scaffold.mjs` to lay down the whole skeleton, then keep the gates green
from commit one.

**Not this skill** — defer to the better-fit tool for one-off Vercel deploys, Core
Web Vitals / LCP perf tuning, monitoring or Sentry setup, a single build error, a
SQL migration, PR code review, or an isolated UI / copy tweak. sgnk-next is for
structural, new-project, feature-build, SaaS, or ship-readiness work.

## The prime directive

**Structure changes; behavior does not** (through RESTRUCTURE). Every move keeps
routes, API responses, status codes, redirects, auth/session outcomes, DB schema,
env names, and UI **byte-identical** — so a green test suite + parity harness can
*prove* nothing changed. Behavior/perf work (caching, SEO, CSP-enforce, server
actions) waits for SCALE / HARDEN, each tagged. Never "fix it while you're here":
mixing refactor with behavior change destroys the one guarantee that makes a large
restructure safe.

## The target architecture in one breath

Hexagonal / ports-and-adapters inside a modular monolith. Four layers, strict
inward dependencies:

```
domain  ←  application  ←  infrastructure        (dependencies point inward)
                ↑                ↑
          presentation       container (wires infra into use-cases)
                ↑
              app (Next.js delivery: pages, route handlers, proxy.ts)
```

- **domain** — entities, value objects, pure policies. Imports nothing concrete.
- **application** — use-cases, ports (interfaces), DTOs. Depends on domain only.
- **infrastructure** — adapters that *implement* ports (DB, cache, queue, providers).
- **presentation** — React components, Zod schemas, server loaders, controllers.
- **container** — the composition root. The ONLY place wiring infra into use-cases.
- **app** — thin Next.js entrypoints; import the composition root or presentation, never infrastructure.

This is also Next's recommended **Data Access Layer** security model, formalized.

## STAGE 0 — ANALYZE (always first)

Never start blind. Run the one-shot analyzer + gates, then present an honest report
and agree the scope. Full method + report template: `references/analysis-playbook.md`.

```bash
node <skill>/scripts/analyze.mjs                      # JSON scorecard + recommendedEntryPhase
node <skill>/scripts/server-folder-blocklist.mjs      # god-folders present?
node <skill>/scripts/import-boundary-report.mjs        # @/server|lib|components refs
node <skill>/scripts/clean-architecture-report.mjs     # layer-direction violations
node -e "const p=require('./package.json');console.log('next',p.dependencies?.next)"
ls node_modules/next/dist/docs   # READ these before any Next.js claim — APIs differ by version
```

The analyzer's `recommendedEntryPhase` routes you:

| Finding | Enter at |
|---|---|
| god-folders / `@/server|lib|components` exist | **RESTRUCTURE · Phase 1** |
| structure clean, but app/app-layer import infra or specific container services | **RESTRUCTURE · Phase 2** |
| `clean-architecture-report` at 0 | **SCALE · Phase 3**, then COMMERCIALIZE + HARDEN + DEPLOY |
| greenfield / new project | run `scripts/scaffold.mjs`, then follow `references/project-starter.md` (bootstrap → connect → feature-build loop) with `references/code-patterns.md`; gates green from commit 1 |

The analyzer also emits a `saasReadiness` score (multi-tenancy, billing,
entitlements, GDPR, API product, …) — use it to scope the COMMERCIALIZE stage.

Present the report (strengths to keep + gaps with evidence) and confirm before editing.

## STAGE 1 — RESTRUCTURE (behavior-preserving)

- **Phase 1 — No-Server Migration** → `references/phase-1-no-server-migration.md`
  Delete `src/server` / `src/lib` / `src/components` by *moving* each file to its
  hexagonal home behind temporary wrappers, then deleting wrappers. Pure
  relocation. Ends when `server-folder-blocklist` is green.
- **Phase 2 — Conclusive Pass** → `references/phase-2-conclusive-pass.md`
  Remove remaining infra/container leaks; add `dependency-container.ts`; move
  inline route/page orchestration into `application/use-cases`; flip ESLint layer
  rules to `error`. Ends when `clean-architecture-report` is **0**.

Use `references/code-patterns.md` for the exact shape of every layer (entity, port,
use-case, DTO, Zod schema, mapper, adapter, container, route handler, page, server
action, proxy). Laws and the file-placement map: `references/architecture-rules.md`,
`references/target-structure.md`.

## STAGE 2 — SCALE

`references/phase-3-scalability-roadmap.md` — the 20-year roadmap (S1–S10:
rendering/caching/PPR, module encapsulation, stricter TS + formatter + version
pins, distributed adapters, CI gate enforcement, OTel, CSP, SEO/PWA, E2E,
multi-region). Each item tagged `[no-behavior-change]` or `[behavior/perf change]`
and sequenced. Safe items (S2/S3/S5) ride alongside Phase 2's ESLint/harness work.

## STAGE 3 — COMMERCIALIZE (SaaS)

`references/saas-commercialization.md` — what makes the product sellable and
multi-tenant: tenant isolation (the triple guard — RLS + scoped-db + use-case
authz), org/workspace/seat model + invitations, billing/subscriptions/
entitlements/quotas/usage-metering behind a provider port, plan gating via feature
flags, onboarding/activation, GDPR data-rights + audit + retention, and an optional
API product (hashed keys, OpenAPI, signed webhooks). Multi-tenancy is foundational
— if the product is multi-tenant, establish the triple guard early (it may precede
later stages). Scope from the analyzer's `saasReadiness` score.

## STAGE 4 — PRODUCTION-HARDEN

`references/production-readiness.md` — data-security/DAL, server-action security,
validation, error handling, observability, CWV/performance, reliability
(distributed cache/queue, idempotency, timeouts, circuit breakers), security
headers + CSP, a11y, SEO, and the Next.js security audit. Ends at the production
go/no-go gate.

## STAGE 5 — DEPLOY

`references/deployment-readiness.md` — target selection (Vercel / Node / Docker /
static), `vercel.ts` config, Fluid Compute realities, env management, the full CI
pipeline (with architecture gates wired in), preview/prod/rollback, domains/CDN/
caching, monitoring, and a go-live checklist.

## Operating rules (every stage)

- **Hold the code-quality bar on every line** (`references/code-quality-standards.md`):
  no `any`, no silent failures/masking fallbacks, typed errors, parse-don't-validate,
  DTOs across boundaries, small thin functions, unhappy paths tested. This is what
  "industry-grade" means in practice.
- **Ports before adapters.** Interface in `application/ports.ts` → implementation in
  `infrastructure` → wired in the container. Callers depend on the port.
- **The composition root is sacred.** `src/container/dependency-container.ts` is the
  one wiring module app/presentation may import. Per-concern container files stay
  internal. (Gate exempts `container → infrastructure` — wiring is its job.)
- **DTOs cross boundaries, records do not.** Map rows→entities→DTOs in
  infrastructure; no DB rows or query fragments (`select`, `where`, `filters`) in `app`.
- **Reuse the actor type that exists** (`TenantContext`/`ActorContext`); don't fork it.
- **Env is infrastructure.** `process.env` only in `src/config` + `*/infrastructure`.
- **Gate after every batch.** A red gate means stop and fix before the next batch —
  never let violations accumulate.
- **Read the installed Next docs.** This version may differ from training memory
  (`proxy.ts`, Cache Components, `'use cache'`). Verify before recommending.

## Gates & test plan (run after every batch)

Bundled, dependency-free, proven (`clean-architecture-report` runs 0 on a clean
repo). Copy `scripts/*.mjs` into the project's `specs/harness/` and **wire them into
CI** — a gate not in CI is not enforced.

```bash
npm run typecheck            # tsc --noEmit (add if missing)
npm run lint                 # eslint --max-warnings=0 (boundaries config in scripts/)
npm run test
npm run build
npm run budget               # bundle / CWV budget if present
node specs/harness/clean-architecture-report.mjs   # goal: total 0
node specs/harness/import-boundary-report.mjs
node specs/harness/server-folder-blocklist.mjs
node specs/harness/route-inventory.mjs             # route parity (author per project)
```

Parity: snapshot key API responses + health endpoints before/after; confirm
protected-route redirect and login/logout outcomes; browser-smoke the main pages;
confirm route count + public URLs unchanged. Phase 2 adds one mocked-port unit test
per extracted use-case.

## Reference index

| File | When to read |
|---|---|
| `references/project-starter.md` | CREATE mode — new project bootstrap + connect + feature-build loop |
| `references/analysis-playbook.md` | Stage 0 — how to analyze an existing repo + report template |
| `references/architecture-rules.md` | the laws — before judging or writing layer code |
| `references/code-quality-standards.md` | cross-cutting — the bar for every line written |
| `references/target-structure.md` | the canonical tree + legacy→hexagonal file map |
| `references/code-patterns.md` | exact code shape for every layer |
| `references/phase-1-no-server-migration.md` | Stage 1 — delete god-folders |
| `references/phase-2-conclusive-pass.md` | Stage 1 — boundary pass + composition root |
| `references/phase-3-scalability-roadmap.md` | Stage 2 — 20-year roadmap |
| `references/saas-commercialization.md` | Stage 3 — multi-tenancy, billing, entitlements, compliance |
| `references/production-readiness.md` | Stage 4 — harden for traffic |
| `references/deployment-readiness.md` | Stage 5 — ship + run |
| `references/portability.md` | wiring across Claude / Codex / Gemini / CI |

**Scripts** (`scripts/`): `analyze.mjs` (one-shot scorecard), `scaffold.mjs`
(greenfield skeleton), `clean-architecture-report.mjs` / `import-boundary-report.mjs`
/ `server-folder-blocklist.mjs` / `route-inventory.mjs` (gates), and
`eslint-boundaries.config.mjs` (layer rules).
**Assets** (`assets/`): turnkey `ci.yml`, `package-scripts.json`,
`tsconfig.strict.json`, `adr-template.md` — copy in to make a repo industry-grade fast.

## Definition of done

Gates (`server-folder-blocklist`, `import-boundary-report`,
`clean-architecture-report`) at 0 **and run in CI** as required checks; ESLint layer
rules at `error`; `typecheck`/`test`/`build`/`budget` green; app/presentation/
application import only ports, use-case DTOs, presentation controllers, or the
composition root; routes/API/public URLs verified unchanged (Stage 1); production
go/no-go gate passed; deployment go-live checklist complete. Zero deps — runs in
Claude Code, Codex, Gemini, and plain CI (`references/portability.md`).

## Source

Claude

## Capabilities

- See original source for capabilities.

## Inputs

Inputs depend on the skill's trigger and arguments. See the source SKILL.md.

## Outputs

Outputs depend on the skill. Typical: files written, reports generated, agent actions performed.

## When To Use

When the user invokes `/sgnk-next` or describes a task the skill's description matches.

## Dependencies

See the source skill's references and scripts folders.

## Related Systems

- Claude (if synced from `~/.claude/skills/sgnk-next`)
- HQ Project — landing page Skills section
- MD Project (md.sgnk.ai) — `Skills/Sgnk Next/`
- Obsidian Vault — `Skills/Sgnk Next/`

## Examples

See workflow.md.

---

_Source: ~/.claude/skills/sgnk-next/SKILL.md_
_Category: sgnk_
