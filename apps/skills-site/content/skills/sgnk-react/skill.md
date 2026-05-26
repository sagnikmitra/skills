# Sgnk React

## Purpose

Restructures, scaffolds, or ships a React (Vite/SPA) codebase into clean hexagonal modular-monolith architecture. Use for new React projects, building features, SaaS dashboards, messy structure (src/components|services|utils|api god-folders, won't scale), or production/deploy readiness.

## Description

# sgnk-react — React Analyze · Restructure · Productionize · Deploy

Takes a React SPA (Vite-first, also works for CRA/Rsbuild/Parcel) from tangled to
clean hexagonal modular monolith — gated in CI, production-hardened, deploy-ready.
Consolidates frontend clean-architecture laws, a 3-phase migration, a 20-year
scalability roadmap, SaaS-commercialization, and production/deploy playbooks, with
enforcement scripts bundled.

> **Companion of `sgnk-next`.** Same lifecycle, same gates, same rules — adapted
> to a client-rendered React app: routing via React Router (or TanStack Router),
> data fetching via TanStack Query / RTK Query, env via `import.meta.env`,
> bundling via Vite, no server actions/route handlers (the React app talks to a
> backend behind an HTTP port). Pairs with any backend.

## The lifecycle (this is the whole skill)

```
ANALYZE → RESTRUCTURE → SCALE → COMMERCIALIZE → PRODUCTION-HARDEN → DEPLOY
  │           │            │          │                │               │
analyze.mjs  Phase 1+2   Phase 3   saas-           production-      deployment-
+ playbook   (no-god-    (S1–S10)  commercial-     readiness.md     readiness.md
+ scaffold    folder +              ization.md
              conclusive)
```

Run it end-to-end for a full transformation, or jump to the stage the analysis
says the repo needs. Each stage gates the next. **Code-quality standards
(`references/code-quality-standards.md`) apply to every line written in every
stage** — that is the bar for "industry-grade." Greenfield projects start with
`scripts/scaffold.mjs` to lay down the whole skeleton, then keep the gates green
from commit one.

**Not this skill** — defer to the better-fit tool for one-off deploys, a single
build error, an isolated UI/copy tweak, a backend-only API change, or pure
design work. sgnk-react is for structural, new-project, feature-build, SaaS,
or ship-readiness work in a React frontend.

## The prime directive

**Structure changes; behavior does not** (through RESTRUCTURE). Every move keeps
routes, URLs, query keys, network calls, redirects, auth/session outcomes,
public env names, and UI **byte-identical** — so a green test suite + parity
harness (route inventory + visual snapshots) can *prove* nothing changed.
Behavior/perf work (code-splitting strategy, suspense boundaries, CSP-enforce,
SSR conversion) waits for SCALE / HARDEN, each tagged. Never "fix it while
you're here": mixing refactor with behavior change destroys the one guarantee
that makes a large restructure safe.

## The target architecture in one breath

Hexagonal / ports-and-adapters inside a modular monolith. Four layers, strict
inward dependencies:

```
domain  ←  application  ←  infrastructure        (dependencies point inward)
                ↑                ↑
          presentation       container (wires infra into use-cases / query-fns)
                ↑
              app (router, providers, route definitions, root)
```

- **domain** — entities, value objects, pure policies, branded ids. Imports nothing concrete.
- **application** — use-cases, ports (interfaces), DTOs, query keys. Depends on domain only.
- **infrastructure** — adapters that *implement* ports: HTTP API client, auth/token storage, websocket, telemetry, feature flag SDK, billing SDK, storage.
- **presentation** — React components, hooks (useQuery/useMutation wrappers), Zod schemas, view controllers, route loaders.
- **container** — composition root. The ONLY place wiring infra into use-cases.
- **app** — thin React entrypoints: router config, providers, route element trees, `main.tsx`. Imports the composition root or presentation, never infrastructure directly.

This is the React parallel of Next's Data Access Layer: a server-validated
backend is still the source of truth for security, but the *client* enforces
the same layering so business logic never leaks into a `<Button>`.

## STAGE 0 — ANALYZE (always first)

Never start blind. Run the one-shot analyzer + gates, then present an honest report
and agree the scope. Full method + report template: `references/analysis-playbook.md`.

```bash
node <skill>/scripts/analyze.mjs                       # JSON scorecard + recommendedEntryPhase
node <skill>/scripts/godfolder-blocklist.mjs           # god-folders present?
node <skill>/scripts/import-boundary-report.mjs        # @/components|services|utils|api|helpers refs
node <skill>/scripts/clean-architecture-report.mjs     # layer-direction violations
node -e "const p=require('./package.json');console.log('react',p.dependencies?.react,'router',p.dependencies?.['react-router-dom']||p.dependencies?.['@tanstack/react-router'])"
ls node_modules/react/README.md node_modules/vite/README.md 2>/dev/null
```

The analyzer's `recommendedEntryPhase` routes you:

| Finding | Enter at |
|---|---|
| god-folders / `@/components|services|utils|api|helpers` exist | **RESTRUCTURE · Phase 1** |
| structure clean, but app/app-layer import infra or specific container services | **RESTRUCTURE · Phase 2** |
| `clean-architecture-report` at 0 | **SCALE · Phase 3**, then COMMERCIALIZE + HARDEN + DEPLOY |
| greenfield / new project | run `scripts/scaffold.mjs`, then follow `references/project-starter.md` (bootstrap → connect → feature-build loop) with `references/code-patterns.md`; gates green from commit 1 |

The analyzer also emits a `saasReadiness` score (multi-tenancy at the client,
billing/seat UI, entitlements gating, GDPR self-serve, public API console, …) —
use it to scope the COMMERCIALIZE stage.

Present the report (strengths to keep + gaps with evidence) and confirm before editing.

## STAGE 1 — RESTRUCTURE (behavior-preserving)

- **Phase 1 — No-God-Folder Migration** → `references/phase-1-no-godfolder-migration.md`
  Delete `src/components` / `src/services` / `src/api` / `src/utils` /
  `src/helpers` / `src/hooks` (as a flat bucket) by *moving* each file to its
  hexagonal home behind temporary re-export wrappers, then deleting wrappers.
  Pure relocation. Ends when `godfolder-blocklist` is green.
- **Phase 2 — Conclusive Pass** → `references/phase-2-conclusive-pass.md`
  Remove remaining infra/container leaks; add `dependency-container.ts`; pull
  inline `fetch`/SDK calls out of components into `application/use-cases` and
  `infrastructure` adapters; flip ESLint layer rules to `error`. Ends when
  `clean-architecture-report` is **0**.

Use `references/code-patterns.md` for the exact shape of every layer (entity,
port, use-case, DTO, Zod schema, mapper, HTTP adapter, container, route element,
hook, component). Laws and the file-placement map:
`references/architecture-rules.md`, `references/target-structure.md`.

## STAGE 2 — SCALE

`references/phase-3-scalability-roadmap.md` — the 20-year roadmap (S1–S10:
data-fetching cache + invalidation, route-level code-splitting + suspense,
module encapsulation (barrels + entry-point lint), stricter TS + formatter +
version pins, distributed concerns moved server-side, CI gate enforcement,
OTel/web-vitals/RUM, CSP, SEO/PWA + meta, E2E coverage, SSR/SSG/RSC adoption
decision). Each item tagged `[no-behavior-change]` or `[behavior/perf change]`
and sequenced. Safe items (S2/S3/S5) ride alongside Phase 2's ESLint/harness work.

## STAGE 3 — COMMERCIALIZE (SaaS)

`references/saas-commercialization.md` — what makes the product sellable and
multi-tenant from the client side: tenant context resolution (subdomain / path /
header), tenant-scoped query keys + cache, workspace/seat/invite UI, billing
checkout & customer-portal redirects behind a `BillingPort`, entitlement &
quota gating (UI hides but server enforces), plan-feature flags, in-product
onboarding/activation, GDPR self-serve (export/delete) requests, and an
optional API/console product. Multi-tenancy is foundational — establish the
tenant-context resolver and scoped query-key factory early. Scope from the
analyzer's `saasReadiness` score.

## STAGE 4 — PRODUCTION-HARDEN

`references/production-readiness.md` — auth-token storage (httpOnly cookie via
backend > localStorage), CSRF/SameSite, XSS via sanitization + safe rendering,
input validation at the boundary (Zod), error boundaries + typed domain
errors, observability (Sentry/OTel + web-vitals), reliability (retry/backoff,
timeouts, AbortController, suspense + skeletons), security headers + CSP
(static-host-side), a11y, SEO/meta, bundle/CWV budget. Ends at the production
go/no-go gate.

## STAGE 5 — DEPLOY

`references/deployment-readiness.md` — target selection (Vercel static, Cloudflare
Pages, Netlify, S3+CloudFront, self-host nginx), env management (`VITE_*`
public env, secrets stay on the backend), SPA fallback (`/* → index.html`),
asset hashing + immutable cache headers, full CI pipeline (with architecture
gates wired in), preview/prod/rollback, domains/CDN/caching, monitoring, and a
go-live checklist.

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
- **DTOs cross boundaries, raw HTTP shapes do not.** Map JSON responses →
  entities → view DTOs in infrastructure; no `fetch`/SDK calls in components or
  use-cases.
- **Reuse the actor/tenant type that exists.** Don't fork `TenantContext` /
  `Viewer`.
- **Env is infrastructure.** `import.meta.env` only in `src/config` +
  `*/infrastructure`. Anything not prefixed `VITE_` is a build error — public
  env is a deliberate decision, never accidental.
- **No business logic in components.** A component renders props, handles input,
  calls a hook from `presentation/hooks/*` which delegates to a use-case from
  the container. That's the only pattern.
- **Gate after every batch.** A red gate means stop and fix before the next batch —
  never let violations accumulate.
- **Read the installed React/Router/Query docs.** Versions matter
  (`react@19` Actions / `use`, React Router v7 framework mode, TanStack Query
  v5). Verify before recommending.

## Gates & test plan (run after every batch)

Bundled, dependency-free. Copy `scripts/*.mjs` into the project's
`specs/harness/` and **wire them into CI** — a gate not in CI is not enforced.

```bash
npm run typecheck            # tsc --noEmit (add if missing)
npm run lint                 # eslint --max-warnings=0 (boundaries config in scripts/)
npm run test                 # vitest run
npm run build                # vite build
npm run budget               # bundle-size + CWV budget (size-limit / lighthouse-ci)
node specs/harness/clean-architecture-report.mjs   # goal: total 0
node specs/harness/import-boundary-report.mjs
node specs/harness/godfolder-blocklist.mjs
node specs/harness/route-inventory.mjs             # route parity (router-aware)
```

Parity: snapshot key network requests (MSW recordings) + visual snapshots
before/after; confirm protected-route redirects, login/logout outcomes, and
deep-link behavior; browser-smoke the main flows; confirm route count + public
URLs unchanged. Phase 2 adds one mocked-port unit test per extracted use-case.

## Reference index

| File | When to read |
|---|---|
| `references/project-starter.md` | CREATE mode — new project bootstrap + connect + feature-build loop |
| `references/analysis-playbook.md` | Stage 0 — how to analyze an existing repo + report template |
| `references/architecture-rules.md` | the laws — before judging or writing layer code |
| `references/code-quality-standards.md` | cross-cutting — the bar for every line written |
| `references/target-structure.md` | the canonical tree + legacy→hexagonal file map |
| `references/code-patterns.md` | exact code shape for every layer |
| `references/phase-1-no-godfolder-migration.md` | Stage 1 — delete god-folders |
| `references/phase-2-conclusive-pass.md` | Stage 1 — boundary pass + composition root |
| `references/phase-3-scalability-roadmap.md` | Stage 2 — 20-year roadmap |
| `references/saas-commercialization.md` | Stage 3 — multi-tenancy, billing, entitlements, compliance (client side) |
| `references/production-readiness.md` | Stage 4 — harden for traffic |
| `references/deployment-readiness.md` | Stage 5 — ship + run |
| `references/portability.md` | wiring across Claude / Codex / Gemini / CI |

**Scripts** (`scripts/`): `analyze.mjs` (one-shot scorecard), `scaffold.mjs`
(greenfield skeleton), `clean-architecture-report.mjs` /
`import-boundary-report.mjs` / `godfolder-blocklist.mjs` / `route-inventory.mjs`
(gates), and `eslint-boundaries.config.mjs` (layer rules).
**Assets** (`assets/`): turnkey `ci.yml`, `package-scripts.json`,
`tsconfig.strict.json`, `adr-template.md` — copy in to make a repo
industry-grade fast.

## Definition of done

Gates (`godfolder-blocklist`, `import-boundary-report`,
`clean-architecture-report`) at 0 **and run in CI** as required checks; ESLint
layer rules at `error`; `typecheck`/`test`/`build`/`budget` green; ESLint +
formatter clean; app/presentation/application import only ports, use-case DTOs,
presentation controllers, or the composition root; routes/URLs/network shape
verified unchanged (Stage 1); production go/no-go gate passed; deployment
go-live checklist complete. Zero deps — runs in Claude Code, Codex, Gemini, and
plain CI (`references/portability.md`).

## Source

Claude

## Capabilities

- See original source for capabilities.

## Inputs

Inputs depend on the skill's trigger and arguments. See the source SKILL.md.

## Outputs

Outputs depend on the skill. Typical: files written, reports generated, agent actions performed.

## When To Use

When the user invokes `/sgnk-react` or describes a task the skill's description matches.

## Dependencies

See the source skill's references and scripts folders.

## Related Systems

- Claude (if synced from `~/.claude/skills/sgnk-react`)
- HQ Project — landing page Skills section
- MD Project (md.sgnk.ai) — `Skills/Sgnk React/`
- Obsidian Vault — `Skills/Sgnk React/`

## Examples

See workflow.md.

---

_Source: ~/.claude/skills/sgnk-react/SKILL.md_
_Category: sgnk_
