# Nextjs Monorepo

## Purpose

Enterprise-grade Next.js monorepo clean architecture guide for full-stack templates using App Router, TypeScript, Prisma, Supabase, modular monolith structure, internal auth/RBAC, and strict layer separation.

## Description

# Next.js Clean Architecture Full-Stack Template Agent Guide

## 0. Purpose

This repository is a reusable, enterprise-grade full-stack template built with:

- Next.js App Router
- React
- TypeScript
- Prisma ORM
- Supabase Postgres as the first database
- Future MongoDB support through repository adapters
- Internal authentication module
- Internal RBAC authorization module
- Clean Architecture
- Ports and Adapters / Hexagonal Architecture
- Modular Monolith structure

The goal is not to build a quick CRUD app. The goal is to create a robust foundation that can be reused across serious SaaS, admin, enterprise, dashboard, and internal-tool projects.

The most important architectural rule:

> Prisma, Supabase, MongoDB, and any concrete database technology are infrastructure details. They must not leak into the domain or application layers.

---

## 1. Non-Negotiable Architectural Principles

### 1.1 Core Rules

1. Do not import Prisma Client outside infrastructure.
2. Do not expose Prisma models directly to UI, server actions, route handlers, or API responses.
3. Do not place business logic inside React components.
4. Do not place business logic directly inside server actions.
5. Do not place business logic directly inside route handlers.
6. Server actions and route handlers must delegate to use cases.
7. All user input must be validated before entering use cases.
8. All mutation use cases must receive an authenticated `ActorContext`.
9. All protected use cases must perform authorization checks.
10. All authorization checks must go through the internal authorization module.
11. Do not rely on client-side route hiding or hidden buttons as security.
12. Do not hardcode role checks everywhere.
13. Use permission-based checks, not role-only checks.
14. All repository interfaces must live in domain or application layer.
15. All repository implementations must live in infrastructure.
16. Database-specific mapping must live inside infrastructure.
17. Domain entities must not depend on Prisma, Supabase, MongoDB, Next.js, React, or HTTP.
18. Use DTOs for input and output boundaries.
19. Use mappers between persistence records, domain entities, and response DTOs.
20. Every role or permission change must create an audit log.
21. Use soft delete by default for user-facing/business data.
22. Use hard delete only when explicitly required.
23. Secrets must never be exposed to the browser.
24. Passwords must never be stored in plain text.
25. Refresh tokens must be stored hashed, not raw.
26. Session cookies must be `httpOnly`, `secure`, and `sameSite`.
27. All server-only modules must be marked with `import "server-only"` where appropriate.
28. Never directly couple authorization to Supabase RLS.
29. Never assume Prisma makes PostgreSQL and MongoDB automatically interchangeable.
30. Build database portability through ports, repository interfaces, DTOs, and mappers.

---

## 2. Recommended Architecture

Use a modular monolith with clean boundaries.

```txt
src/
  app/
  modules/
  shared/
  container/
  config/
  tests/
```

The application is organized by business modules, not by technical layers alone.

Preferred structure:

```txt
src/
  app/
    (public)/
    (protected)/
    api/

  modules/
    auth/
    authorization/
    users/

  shared/
    domain/
    application/
    infrastructure/
    presentation/

  container/
    dependency-container.ts
    repository-provider.ts

  config/
    env.ts
```

---

## 3. Architectural Layers

### 3.1 Presentation Layer

Includes: Next.js pages, Next.js layouts, React Server Components, Client Components, Server Actions, Route Handlers.

Responsibilities: Accept user input; validate request payloads at boundary; resolve current actor/session; call application use cases; return safe DTOs; render UI.

Must not: import Prisma; contain business logic; contain raw authorization logic; directly query the database; return persistence models.

---

### 3.2 Application Layer

Includes: use cases, commands, queries, DTOs, application services, ports, authorization calls, transaction orchestration.

Responsibilities: Execute business workflows; coordinate repositories; call authorization service; validate application invariants; manage transactional use cases through a transaction manager; return safe application DTOs.

Must not: import Prisma; import React; import Next.js request/response APIs; depend on Supabase or MongoDB clients; know concrete database implementation details.

---

### 3.3 Domain Layer

Includes: entities, value objects, domain errors, domain services, repository interfaces, domain policies.

Responsibilities: Represent business rules; protect invariants; define repository contracts; define domain-level behavior.

Must not: know HTTP; know Next.js; know Prisma; know Supabase; know MongoDB; know UI.

---

### 3.4 Infrastructure Layer

Includes: Prisma repositories, Mongo repositories later, database clients, transaction manager implementations, password hasher implementations, token service implementations, email service implementations, external provider adapters, logging adapters.

Responsibilities: Implement application/domain ports; translate database records to domain entities; translate domain entities to database records; handle database-specific queries; handle provider-specific integration.

---

## 4. Final Folder Structure

Use this as the target structure.

```txt
src/
  app/
    layout.tsx
    page.tsx
    (public)/
      login/page.tsx
      register/page.tsx
      forgot-password/page.tsx
    (protected)/
      layout.tsx
      dashboard/page.tsx
      users/
        page.tsx
        new/page.tsx
        [id]/
          page.tsx
          edit/page.tsx
          roles/page.tsx
      roles/
        page.tsx
        new/page.tsx
        [id]/page.tsx
      permissions/page.tsx
      settings/page.tsx
    api/
      auth/login/route.ts
      auth/logout/route.ts
      auth/refresh/route.ts
      users/route.ts
      users/[id]/route.ts
      users/[id]/roles/route.ts
      roles/route.ts
      permissions/route.ts

  modules/
    auth/
      domain/{entities,value-objects,repositories,errors}
      application/{dto,use-cases,ports}
      infrastructure/{prisma,mongo,crypto}
      presentation/{actions,schemas,components}
    authorization/
      domain/{entities,value-objects,repositories,policies,errors}
      application/{dto,use-cases,services,guards}
      infrastructure/{prisma,mongo}
      presentation/{actions,schemas,components}
    users/
      domain/{entities,value-objects,repositories,errors}
      application/{dto,use-cases,services}
      infrastructure/{prisma,mongo}
      presentation/{actions,schemas,components}

  shared/
    domain/{entity,value-object,domain-error,result,unique-entity-id}
    application/{actor-context,use-case,command,query,pagination,paginated-result}
    infrastructure/
      database/{prisma,mongo}
      audit/
      logger/
      config/env.ts
    presentation/{components/ui,lib}

  container/
    dependency-container.ts
    repository-provider.ts

  tests/{unit,integration/e2e}
```

## 8. Prisma Setup

### 8.1 Prisma Rules

1. Prisma Client must be created in one place only.
2. Prisma Client must not be imported into use cases.
3. Prisma Client must not be imported into React components.
4. Prisma records must be mapped to domain entities.
5. Domain entities must be mapped to persistence input objects.
6. Use `DATABASE_URL` for pooled runtime connections.
7. Use `DIRECT_URL` for migrations and schema operations.
8. Avoid raw SQL unless absolutely necessary.
9. If raw SQL is required, isolate it in infrastructure.
10. Never let Prisma `where` objects become API input contracts.


---


## 14. Actor Context

Create:

```txt
src/shared/application/actor-context.ts
```

```ts
export type ActorContext = {
  userId: string;
  email: string;
  sessionId: string;
  roles: string[];
  permissions?: string[];
  ipAddress?: string;
  userAgent?: string;
};
```

Rules:

- Every protected use case must receive `ActorContext`.
- Never trust actor data from the browser.
- Actor context must be resolved server-side from the session.

---

## 15. Authorization Model

Use RBAC plus ownership policies.

### 15.1 Permission Format

Permission code format:

```txt
resource.action.scope
```

Examples:

```txt
users.create.any
users.read.any
users.read.own
users.update.any
users.update.own
users.delete.any

roles.create.any
roles.read.any
roles.update.any
roles.delete.any
roles.assign.any
roles.revoke.any

permissions.read.any
permissions.create.any

audit_logs.read.any
settings.manage.any
```

Use `*` only for `SUPER_ADMIN`.

---

### 15.2 Default Roles

| Role        | Purpose                                                 |
| ----------- | ------------------------------------------------------- |
| SUPER_ADMIN | Full system control                                     |
| ADMIN       | User and role management, no destructive system control |
| MANAGER     | Can read users and update limited profile fields        |
| USER        | Can access own profile only                             |

---

### 15.3 Default RBAC Matrix

| Permission             | SUPER_ADMIN | ADMIN | MANAGER | USER |
| ---------------------- | ----------: | ----: | ------: | ---: |
| `*`                    |         Yes |    No |      No |   No |
| `users.create.any`     |         Yes |   Yes |      No |   No |
| `users.read.any`       |         Yes |   Yes |     Yes |   No |
| `users.read.own`       |         Yes |   Yes |     Yes |  Yes |
| `users.update.any`     |         Yes |   Yes |      No |   No |
| `users.update.own`     |         Yes |   Yes |     Yes |  Yes |
| `users.delete.any`     |         Yes |   Yes |      No |   No |
| `roles.create.any`     |         Yes |    No |      No |   No |
| `roles.read.any`       |         Yes |   Yes |      No |   No |
| `roles.update.any`     |         Yes |    No |      No |   No |
| `roles.delete.any`     |         Yes |    No |      No |   No |
| `roles.assign.any`     |         Yes |   Yes |      No |   No |
| `roles.revoke.any`     |         Yes |   Yes |      No |   No |
| `permissions.read.any` |         Yes |   Yes |      No |   No |
| `audit_logs.read.any`  |         Yes |   Yes |      No |   No |
| `settings.manage.any`  |         Yes |    No |      No |   No |

---


## 19. Authentication Design

This template uses an internal auth module by default.

Authentication answers “Who is this user?”
Authorization answers “What is this user allowed to do?”

Do not mix them.

---

### 19.1 Token Strategy

Use short-lived access tokens plus long-lived refresh tokens with rotation, hashed refresh token storage, HTTP-only secure cookies, and server-side session records.

Recommended defaults: Access token 15 minutes, Refresh token 30 days.

Access tokens should contain `userId`, `sessionId`, `issuedAt`, and `expiresAt`.

Do not store full permissions in long-lived tokens; permissions can change and stale authorization is dangerous.

---

### 19.2 Password Hashing

Use Argon2id. Password handling rules: never store plaintext passwords; never log passwords; never return password hashes; use a strong hash; use a server-side pepper; normalize email before lookup; use timing-safe comparisons; rate-limit login attempts.

---

## 21. Server Action Pattern

Server actions are entrypoints only. They must validate input, call a use case, manage cookies/redirects, and return safe results. Do not put business rules in actions or import repositories directly.

---

## 22. Route Handler Pattern

Route handlers must call use cases, not query Prisma directly, return safe DTOs, and handle expected errors centrally.

---

## 23. Use Case Pattern

Use a transaction manager for critical workflows such as: create user + credential + default role + audit log; assign/revoke role + audit log; change password + revoke sessions; delete role + detach permissions + audit log.

---

## 27. Zod Validation

Every presentation boundary must use Zod. Validate at server action and route handler boundaries, do not trust client validation, do not pass raw `FormData` into use cases, and convert raw input to command DTOs.

---

## 28. Error Handling

Expected errors: ForbiddenError, UnauthorizedError, ValidationError, NotFoundError, ConflictError, InvalidCredentialsError, AccountLockedError.

Map errors to HTTP status: 400 validation, 401 unauthorized, 403 forbidden, 404 not found, 409 conflict, 500 unknown.

Do not leak stack traces to users. Log unexpected errors server-side, do not log passwords/tokens/sensitive payloads, and use stable error codes for frontend handling.

---

## 29. Audit Logging

Every critical action must create an audit log. Required actions include: auth.login.success, auth.login.failed, auth.logout, auth.password.changed, users.created, users.updated, users.deactivated, users.deleted, roles.created, roles.updated, roles.deleted, roles.assigned, roles.revoked, permissions.created, settings.updated.

Audit metadata must never contain raw password, raw token, full secret, or sensitive financial data unless explicitly required and masked.

---

## 30. Seed Data

Seed permissions, roles, and an initial super-admin from environment variables.

Required permissions: `users.create.any`, `users.read.any`, `users.read.own`, `users.update.any`, `users.update.own`, `users.delete.any`, `roles.create.any`, `roles.read.any`, `roles.update.any`, `roles.delete.any`, `roles.assign.any`, `roles.revoke.any`, `permissions.read.any`, `permissions.create.any`, `audit_logs.read.any`, `settings.manage.any`.

Roles: `SUPER_ADMIN`, `ADMIN`, `MANAGER`, `USER`.

Assign role permissions according to the RBAC matrix.

Initial super admin environment secrets:

```env
SEED_SUPER_ADMIN_EMAIL="admin@example.com"
SEED_SUPER_ADMIN_PASSWORD="ChangeMeStrongPassword123!"
```

Rules: do not seed weak production passwords, fail loudly if production seed password is weak, and require an explicit seed command.

---

## 31. UI Guidelines

Use a clean enterprise dashboard UI with a shell/sidebar, top bar, role-aware navigation, breadcrumbs, data tables, filters, pagination, and robust empty/error/loading states. Include confirmation dialogs, toasts, and light/dark mode.

UI security rule: UI visibility is UX only; server-side authorization is mandatory.

---

## 32. Frontend Component Rules

Server Components: initial data, page rendering, actor resolution, safe DTOs.

Client Components: forms, modals, interactive tables, dropdowns, filtering, confirmation dialogs.

Rules: keep Client Components small, do not fetch secrets or import server-only modules or Prisma in components, use server actions for form mutations, and use route handlers for API-style interactions.

---

## 33. Testing Strategy

Unit tests: domain entities, value objects, use cases, authorization service, password hasher/token service behavior, and mappers.

Integration tests: Prisma repositories, transaction manager, auth flows, RBAC resolution, and user CRUD.

E2E tests: login/logout, user list access, unauthorized access, create/update, assign/revoke role, deactivate user.

Recommended tools: Vitest, Testing Library, Playwright.

---

## 34. Test Matrix

Key cases:

- Anonymous user opens protected page → redirect to login
- USER opens `/users` → forbidden
- ADMIN opens `/users` → allowed
- USER updates own profile → allowed
- USER updates another user → forbidden
- ADMIN updates another user → allowed
- ADMIN deletes SUPER_ADMIN → forbidden unless explicitly allowed
- SUPER_ADMIN assigns role → allowed
- MANAGER assigns role → forbidden
- Invalid login → generic invalid credentials error
- Disabled user logs in → blocked
- Expired session calls API → 401
- Missing permission calls API → 403

---

## 35. CI/CD Requirements

Minimum CI pipeline:

```txt
install dependencies
typecheck
lint
unit tests
build
prisma validate
prisma generate
```

Recommended GitHub Actions steps:

```bash
pnpm install --frozen-lockfile
pnpm prisma validate
pnpm prisma generate
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

---

## 36. Recommended Scripts

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "typecheck": "tsc --noEmit",
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:e2e": "playwright test",
    "db:generate": "prisma generate",
    "db:validate": "prisma validate",
    "db:migrate": "prisma migrate dev",
    "db:deploy": "prisma migrate deploy",
    "db:studio": "prisma studio",
    "db:seed": "tsx prisma/seed.ts"
  }
}
```

---

## 37. Database Portability Rules

The template must support future MongoDB through a real adapter, not wishful thinking.

Portable:
- Domain entities
- Use cases
- DTOs
- Repository interfaces
- Authorization service
- UI components
- Server actions
- Route handlers
- Application services

Not automatically portable:
- Prisma schema
- Prisma migrations
- Relational joins
- Foreign keys
- Postgres constraints
- Raw SQL
- Transaction behavior
- Mongo document design

Rule: do not expose relational assumptions in use cases.

Bad:

```ts
await prisma.user.findMany({
  include: { roles: { include: { role: true } } },
});
```

Good:

```ts
await authorizationRepository.getUserRoleCodes(userId);
```

---

## 38. Mongo Adapter Preparation

Do not implement Mongo until required.

Prepare only:

```txt
src/modules/*/infrastructure/mongo/
```

When ready, add Mongo client adapter, repository implementations, mappers, and revisit transactions, indexes, many-to-many mapping, and embedded vs referenced document design. Do not copy relational schema blindly.

---

## 39. Supabase Positioning

Use Supabase only as managed Postgres hosting.

Do not use Supabase Auth in the core template.
Do not use Supabase client in domain/application.
Do not rely on Supabase RLS as the primary authorization mechanism for server-side Prisma flows.
RLS may be defense-in-depth for Supabase-facing tables, but server-side Prisma authorization is mandatory.

---

## 40. Security Checklist

### Authentication
- Hash passwords with Argon2id
- Rotate refresh tokens
- Store refresh tokens hashed
- Use secure cookies
- Use generic login errors
- Rate-limit and throttle suspicious logins
- Add email verification
- Add expiring password reset tokens
- Revoke sessions on password change

### Authorization
- Centralize authorization service
- Use permission checks
- Use ownership checks for self-service updates
- Re-check permissions on every mutation
- Do not rely on frontend role checks
- Audit role changes

### Data Security
- Validate input with Zod
- Sanitize or escape user content
- Avoid raw SQL
- Use least-privilege DB users
- Do not log sensitive data
- Mask secrets in logs

### Session Security
- `httpOnly` cookies
- `secure` cookies in production
- `sameSite=lax` or stricter
- Short-lived access tokens
- Server-side session revocation
- Refresh token rotation

---

## 41. Implementation Phases

### Phase 1: Project Foundation

Create the project, set up TypeScript, ESLint/Prettier, absolute imports, Prisma, Supabase Postgres connection, `.env.example`, env validation, and base structure.

Done when the app builds, env validation works, Prisma validates, and the folder structure exists.

---

### Phase 2: Database and Prisma

Build the Prisma schema, migration, client singleton, seed file, and initial RBAC/ admin seed data.

Done when `pnpm db:migrate` and `pnpm db:seed` work and an initial admin exists.

---

### Phase 3: Shared Kernel

Implement shared primitives: `DomainError`, result types, `ActorContext`, pagination utilities, transaction manager interface, and logger port.

Done when shared primitives exist and are covered by tests.

---

### Phase 4: Auth Module

Build auth entities, ports, Argon2 hasher, token service, session repository, login/register/refresh/logout use cases, server actions, and auth pages.

Done when users can register, login, logout, session cookies work, and refresh flow works.

---

### Phase 5: Authorization Module

Build role/permission entities, authorization repository interface, Prisma repository, auth service, guards, RBAC seed data, and permission-resolution tests.

Done when `SUPER_ADMIN` has `*`, `ADMIN` has management permissions, `USER` only accesses own profile, and forbidden requests return 403.

---

### Phase 7: Role and Permission Admin

Add role CRUD, permission listing, assign/revoke role use cases, role UI, permission matrix UI, and audit logging.

Done when admins can assign/revoke roles, changes are audited, and unauthorized users cannot mutate roles.

---

### Phase 8: Hardening

Add rate limiting, CSRF protections, centralized error mapping, audit log viewer, session management UI, revoke-all-sessions, password reset, email verification, and E2E tests.

Done when auth is production-ready, core security checks pass, and E2E covers critical paths.

---

## 42. Claude/Codex Working Rules

Respect module boundaries, add interfaces before implementations, keep infrastructure out of application/domain, test every use case, add mappers for persistence models, use Zod at presentation boundaries, return safe DTOs only, preserve strict TypeScript, avoid `any` except when isolated, and never duplicate business logic between server actions and route handlers.

Feature order:
- Domain
- Repository interface
- Use case
- Infrastructure repository
- Mapper
- Validation schema
- Server action / route handler
- UI
- Tests

---

## 43. Definition of Done

A feature is done only when domain model, use case, repository interface, infrastructure implementation, input schema, authorization check, audit log for critical mutations, tests, loading/empty/success/error UI handling, and safe DTO responses all exist; no Prisma import exists outside infrastructure; no secret is exposed client-side; and `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build` all pass.

---

## 44. Anti-Patterns to Reject

Reject:
- components importing Prisma
- server actions with all business logic
- route handlers duplicating server action logic
- scattered role checks in UI
- Prisma models returned directly to frontend
- authorization only in middleware
- weak password storage
- raw refresh tokens
- Supabase client in app core
- domain entities importing DB types
- Prisma where clauses accepted from API input
- Mongo adapter built before needed
- microservices before modular monolith is proven

---

## 45. Initial Build Target

The first complete template release should include authentication (register, login, logout, refresh, password hashing, cookie session), authorization (roles, permissions, user-role mapping, permission checking, ownership checking), and infrastructure (Prisma Postgres adapter, seed data, audit logs, environment validation, test setup).

---

## 46. Final Architectural Position

This template must remain database-switchable by architecture, not by pretending databases are interchangeable.

The right abstraction is:
- Use Cases depend on Repository Interfaces.
- Repository Interfaces return Domain Entities.
- Infrastructure adapts Prisma/Postgres today.
- Infrastructure can adapt Mongo tomorrow.
- Authorization stays internal.
- Authentication stays modular.
- Next.js remains the delivery mechanism, not the architecture.

Future migrations from Supabase Postgres to MongoDB should primarily affect infrastructure adapters and schema/migration strategy, not use cases, UI, RBAC engine, or domain model.

That is the standard this codebase must maintain.

## Source

Claude

## Capabilities

- See original source for capabilities.

## Inputs

Inputs depend on the skill's trigger and arguments. See the source SKILL.md.

## Outputs

Outputs depend on the skill. Typical: files written, reports generated, agent actions performed.

## When To Use

When the user invokes `/nextjs-monorepo` or describes a task the skill's description matches.

## Dependencies

See the source skill's references and scripts folders.

## Related Systems

- Claude (if synced from `~/.claude/skills/nextjs-monorepo`)
- HQ Project — landing page Skills section
- MD Project (md.sgnk.ai) — `Skills/Nextjs Monorepo/`
- Obsidian Vault — `Skills/Nextjs Monorepo/`

## Examples

See workflow.md.

---

_Source: ~/.claude/skills/nextjs-monorepo/SKILL.md_
_Category: General_
