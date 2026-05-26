# Sgnk React — Workflow

## Overview

How the `sgnk-react` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# sgnk-react — Complete Workflow

> Human-facing overview of what `sgnk-react` does end to end. The machine entry
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

`sgnk-react` is a one-shot engine that takes **any React (Vite/SPA) codebase**
from tangled to **clean hexagonal modular-monolith** architecture — gated in CI,
production-hardened, deploy-ready, and SaaS-commercializable. It is the React
companion of `sgnk-next`: same laws, same lifecycle, same gates, adapted to a
client-rendered app. Consolidates frontend clean-architecture rules, a 3-phase
behavior-preserving migration, a 20-year scalability roadmap,
SaaS-commercialization, and production/deployment playbooks, with **proven
enforcement scripts bundled** (zero runtime deps).

Runs in Claude Code, Codex, Gemini, or plain CI. Composes with `gvc`
(gvc = repo + Vercel + Cloudflare bootstrap; sgnk-react = architecture + features).

## 2. Two entry modes

```
┌─ CREATE ───────────► brand-new project from scratch
│   "create dashboardx with auth, billing, reporting"
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
            │        Phase 1 (god-folder Phase 3   saas-             production-           deployment-
         analyze.mjs Phase 2 (conclusive)(S1–S10)  commercializ.     readiness             readiness
         + gates                                    .md
```

Run end-to-end for a full transformation, or **jump to the stage the analysis
recommends**. Each stage gates the next. Every line, at every stage, holds the
code-quality bar (`references/code-quality-standards.md`).

## 4. Governing principles (apply throughout)

| Principle | Meaning |
|---|---|
| **Prime directive** | Structure changes; **behavior does not** through RESTRUCTURE. Routes, URLs, query keys, network calls, redirects, auth outcomes, UI stay **byte-identical** — provable via tests + parity harness (route inventory + visual snapshots + recorded network). Behavior/perf changes wait for SCALE/HARDEN. |
| **Target architecture** | Hexagonal ports-and-adapters in a modular monolith. Dependencies point inward: `app → presentation → application → domain`; `infrastructure` implements application ports; `container` wires them. |
| **Ports before adapters** | Interface in `application/ports.ts` → impl in `infrastructure` → wired in container. Callers depend on the port. |
| **Composition root is sacred** | `container/dependency-container.ts` is the ONLY wiring module app/presentation may import. |
| **DTOs cross boundaries, HTTP shapes don't** | Map JSON→entity→DTO in infra; no `fetch`/SDK in components or use-cases. |
| **Env is infrastructure** | `import.meta.env` only in `src/config` + `*/infrastructure`. Anything not `VITE_*` is a build error — public env is deliberate. |
| **No business logic in components** | A component renders props, calls a presentation hook, which calls a use-case via the container. That's the only path. |
| **Gate after every batch** | A red gate = stop and fix before continuing. Never accumulate violations. |

## 5. Stage-by-stage workflow

### STAGE 0 — ANALYZE (always first)
- **Run:** `analyze.mjs` (JSON scorecard + `recommendedEntryPhase` + `saasReadiness`), the three gates, and a React/Router/Query version + docs check.
- **Routing:**

  | Finding | Enter at |
  |---|---|
  | god-folders / legacy aliases exist | RESTRUCTURE · Phase 1 |
  | structure clean but app/app-layer import infra/container | RESTRUCTURE · Phase 2 |
  | `clean-architecture-report` = 0 | SCALE → COMMERCIALIZE → HARDEN → DEPLOY |
  | greenfield / new project | `scaffold.mjs` → `project-starter.md` |
- **Output:** honest report — strengths to keep + gaps with evidence — agreed **before any edit**.
- **Reference:** `references/analysis-playbook.md`.

### STAGE 1 — RESTRUCTURE (behavior-preserving)
- **Phase 1 — No-God-Folder Migration** (`references/phase-1-no-godfolder-migration.md`): delete `src/components` / `src/services` / `src/api` / `src/utils` / `src/helpers` / `src/hooks` (flat bucket) by *moving* each file to its hexagonal home behind temporary re-export wrappers, then deleting wrappers. Pure relocation. **Exit:** `godfolder-blocklist` green, 0 legacy-alias refs.
- **Phase 2 — Conclusive Pass** (`references/phase-2-conclusive-pass.md`): pull `fetch`/SDK calls out of components into infra adapters; lift orchestration into `application/use-cases`; add `dependency-container.ts`; flip ESLint layer rules to `error`. **Exit:** `clean-architecture-report` = **0**.
- **Supporting:** `references/architecture-rules.md` (laws), `references/target-structure.md` (folder tree + legacy→hexagonal file map), `references/code-patterns.md` (exact code per layer).

### STAGE 2 — SCALE
- **Reference:** `references/phase-3-scalability-roadmap.md` — S1–S10: data-fetching cache + invalidation (Query / RTK Query), route-level code-splitting + `<Suspense>`, module encapsulation, stricter TS + formatter + Node pin, distributed concerns to backend, CI gate enforcement, OTel + web-vitals + RUM, CSP, SEO/PWA/meta, E2E coverage, SSR/SSG/RSC adoption ADR.

### STAGE 3 — COMMERCIALIZE (SaaS)
- **Reference:** `references/saas-commercialization.md` — tenant resolver + scoped query-key factory, workspace/seat/invite UI, billing via `BillingPort` (Stripe checkout/portal), entitlement & quota gating, plan-feature flags, onboarding/activation, GDPR self-serve, optional API console. Scoped by `saasReadiness`. Tenant context is foundational — establish it early.

### STAGE 4 — PRODUCTION-HARDEN
- **Reference:** `references/production-readiness.md` — auth storage, CSRF/SameSite, XSS, Zod validation, error boundaries + typed errors, observability, retry/timeout/AbortController, CSP, a11y, SEO/meta, bundle/CWV budget. **Exit:** production go/no-go gate.

### STAGE 5 — DEPLOY
- **Reference:** `references/deployment-readiness.md` — target (Vercel / Cloudflare Pages / Netlify / S3+CDN / nginx), env management, SPA fallback, asset hashing + cache headers, full CI (gates wired in), preview/prod/rollback, domains/CDN, monitoring, go-live checklist.

## 6. The feature-build loop (build X / Y / Z)

Used in CREATE mode and whenever adding a requirement. Each feature is **one clean
vertical slice** through its module:

```
requirement → domain → port → use-case (+test) → infra adapter → mapper
            → Zod schema → presentation hook → route element → UI → gate (npm run verify)
```

Reference: `references/project-starter.md` (worked example) + `references/code-patterns.md`.
Build in dependency order; re-verify after each slice.

## 7. Enforcement — the gates (run after every batch, wired into CI)

| Script | Checks | Pass |
|---|---|---|
| `analyze.mjs` | full scorecard + entry phase + SaaS readiness | (informational) |
| `clean-architecture-report.mjs` | app/presentation/application importing infra/container; `import.meta.env`/`fetch`/SDK in domain/application; HTTP-client construction in domain/application | `total: 0` |
| `import-boundary-report.mjs` | `@/components` / `@/services` / `@/api` / `@/utils` / `@/helpers` refs | exit 0 |
| `godfolder-blocklist.mjs` | files left in god-folders | exit 0 |
| `route-inventory.mjs` | route list before/after parity | diff empty |
| `eslint-boundaries.config.mjs` | layer-direction + module entry-point | lint clean |

Plus the standard gate `typecheck → lint → test → build → budget`.
**A gate not in CI is not enforced** — `assets/ci.yml` wires them as required checks.

## 8. Turnkey assets (copy-in to industry-grade a repo fast)
- `assets/ci.yml` — 3 CI jobs (quality / architecture-gates / e2e).
- `assets/package-scripts.json` — scripts incl. `verify`, `arch`, `analyze`, `engines`, `budget`.
- `assets/tsconfig.strict.json` — full strict flag set (`noUncheckedIndexedAccess`, …).
- `assets/adr-template.md` — decision-record template.
- `scripts/scaffold.mjs` — lays the canonical tree + per-layer READMEs + copies the gates into `specs/harness/`.

## 9. End-to-end walkthroughs

**A. New project**
```
/sgnk-react create dashx with auth, dashboard, billing
```
1. `npm create vite@latest dashx -- --template react-ts` → `scaffold.mjs` (tree + gates) → apply assets (CI, tsconfig, scripts, eslint) → write spine (`config/env.ts`, `app/router.tsx`, `dependency-container.ts`, providers). First commit green.
2. Connect integrations behind ports (HTTP API, auth, billing, telemetry) via the container.
3. Feature-build loop for each: auth → dashboard → billing (each a tested, gated vertical slice).
4. As it grows: SCALE → COMMERCIALIZE → HARDEN → DEPLOY.

**B. Existing messy repo**
```
/sgnk-react analyze
```
1. `analyze.mjs` + gates → report → agree entry phase.
2. Phase 1 (delete god-folders via wrappers) → `godfolder-blocklist` green.
3. Phase 2 (composition root + use-cases + ESLint error) → `clean-architecture-report` = 0.
4. SCALE / COMMERCIALIZE / HARDEN / DEPLOY as needed — each additive, never a rescue.

## 10. Invocation
- **Slash:** `/sgnk-react [analyze | create <name> with <features> | <task>]`
- **Natural language:** "restructure my react app", "sgnk.ai for react", "build me a SaaS dashboard in react", "is my react app ready to ship", "this won't scale", "audit my CRA codebase".
- **Not this skill:** one-off deploys, a single build error, isolated UI tweak, pure backend change → defer to the better-fit tool.

## 11. Definition of done

Gates (`godfolder-blocklist`, `import-boundary-report`,
`clean-architecture-report`) at **0 and run in CI** as required checks; ESLint
layer rules at `error`; `typecheck`/`test`/`build`/`budget` green;
app/presentation/application import only ports, use-case DTOs, controllers, or the
composition root; routes/URLs/network shape verified unchanged (Stage 1); production
go/no-go passed; deployment go-live checklist complete.

## 12. Component map

```
sgnk-react/
├── SKILL.md                       # machine entry point (lifecycle + routing + rules)
├── WORKFLOW.md                    # this document (human overview)
├── references/                    # depth, loaded on demand
│   ├── analysis-playbook.md          # Stage 0
│   ├── project-starter.md            # CREATE mode + feature-build loop
│   ├── architecture-rules.md         # the laws
│   ├── target-structure.md           # folder tree + file-placement map
│   ├── code-patterns.md              # exact code per layer
│   ├── code-quality-standards.md     # cross-cutting bar
│   ├── phase-1-no-godfolder-migration.md
│   ├── phase-2-conclusive-pass.md
│   ├── phase-3-scalability-roadmap.md
│   ├── saas-commercialization.md
│   ├── production-readiness.md
│   ├── deployment-readiness.md
│   └── portability.md
├── scripts/                       # zero-dep enforcement + tooling
│   ├── analyze.mjs
│   ├── scaffold.mjs
│   ├── clean-architecture-report.mjs
│   ├── import-boundary-report.mjs
│   ├── godfolder-blocklist.mjs
│   ├── route-inventory.mjs
│   └── eslint-boundaries.config.mjs
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

- Claude — invoked via the `Skill` tool with `skill: "sgnk-react"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Sgnk React/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/sgnk-react/WORKFLOW.md_
