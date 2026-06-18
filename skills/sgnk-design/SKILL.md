---
name: sgnk-design
description: "The canonical design system for sgnk.ai and every sub-brand surface — a single electric blue accent (#1a5cff) on white, Google Sans + Google Sans Code typography, square corners by default, hairline borders, one elevation rule, and reading-scaffolding components (drop-cap lead, pull-quotes, walk-through readouts under flowcharts, paper deep-links, active-TOC, progress bar, back-to-top). Use whenever designing, building, polishing, reviewing, or extending any sgnk.ai surface: long-form pages, the writing index, the homepage, masthead, marketing, or any sub-brand inheriting the parent system (sgnk Advox, sgnk HQ, sgnk MD, sgnk CareerOS, sgnk Markex, sgnk Writes). The full token + component spec lives in references/sgnk-design-system.md (symlinked to the canonical doc in sagnikmitra.github.io/sgnk-design-system.md). Composes with sgnk-writer (voice for prose inside the system) and with sgnk-next / sgnk-react / gvc (scaffolds that this skill dresses). Trigger: /sgnk-design."
---

# /sgnk-design

The design system **for everything sgnk.ai touches**. One brand, one blue, two typefaces, square corners, hairline chrome, and reading-scaffolding instead of decoration. This skill operationalizes the [sgnk-design-system.md](references/sgnk-design-system.md) — pulling tokens, components, and rules into any task that builds, polishes, or extends an sgnk.ai surface.

## Usage

```
/sgnk-design                                    # load the full system into context
/sgnk-design <surface>                          # apply the system to building a new surface
/sgnk-design audit <file|url>                   # review an existing surface against the system
/sgnk-design extract <target>                   # extract tokens to Tailwind config or CSS vars (the two the spec operationalizes)
/sgnk-design extend <component>                 # design a new component that respects the system
```

**Voice triggers (no slash):** "use the sgnk design system", "make this on-brand", "review for brand consistency", "build the sgnk.ai homepage", "build a sgnk Writes page", "design the sgnk Advox masthead", "build me a sub-brand page that inherits sgnk.ai".

## What it does

1. **Loads `references/sgnk-design-system.md`** — the canonical spec with tokens, typography ladder, color roles, component definitions, do/don't, breakpoints, and the iteration guide. This is the source of truth.
2. **Applies tokens, never inline values.** Every new rule resolves to a token: `{colors.primary}`, `{typography.body}`, `{spacing.lg}`, `{rounded.md}`. Hex codes, raw pixel sizes, and ad-hoc shadows are anti-patterns.
3. **Audits against the system.** When reviewing an existing page, runs through the do/don't list and the principles, flags every drift (a second blue, decorative shadow, rounded button, a missing kicker on `h2`, missing walk-through under a flowchart, body at 17px instead of 16px).
4. **Extends responsibly.** When asked to add a new component (state chips, form inputs, comment threads, charts), drafts the spec following the iteration guide, documents it in the system MD, and reuses existing primitives wherever a role is already carried.
5. **Composes with `sgnk-writer`.** The design system hosts the voice; the voice fills the design system. When writing AND designing the same surface, load both — they are inseparable.

## The seven things to remember (the system in one breath)

1. **One blue** — `{colors.primary}` (#1a5cff) is the only accent. No second.
2. **Two typefaces** — Google Sans (text) + Google Sans Code (code, captions, kickers). Pixel art = logo image only.
3. **Square by default** — `{rounded.none}` everywhere except diagram nodes (8px), diagram figures (12px), the back-to-top button (pill).
4. **Hairline chrome** — `1px {colors.hairline}` carries every non-accent border. Shadows only for interactivity (hover-lift) or floating state.
5. **One reading column** — 760px max-width. Full-bleed only for topbar, lightrail hero, footer.
6. **Reading scaffolding instead of decoration** — progress bar, active TOC, drop-cap lead, back-to-top, topbar lift-on-scroll, paper deep-links, walk-through readouts under flowcharts.
7. **Voice + visual are inseparable** — restrained chrome + earnest plain-spoken prose form the brand together. Marketing-tone prose breaks the design; cutting zingers break the voice. See [[sgnk-writer]].

## Canonical reference implementation

[sgnk.ai/harness](https://sgnk.ai/harness) — source at `sagnikmitra.github.io/harness/index.html`. For new pieces, **use the starter shell** (`references/sgnk-article-shell.html`) — it is the harness page distilled to its scaffold, ready to fill: copy it, rename to your slug, replace `{{PLACEHOLDERS}}`, drop in the prose and flowcharts (with `HOW TO READ IT` readouts), the tables, and the cite block. The shell is faster than copying the harness file directly because it has no harness-specific content to strip first.

## When to use which sibling skill

| Task | Use |
|---|---|
| Designing or building any sgnk.ai surface | **sgnk-design** (this skill) |
| Writing or rewriting the prose inside an sgnk.ai surface | [[sgnk-writer]] |
| Scaffolding a fresh Next.js project for a sgnk.ai sub-brand | [[sgnk-next]] |
| Scaffolding a fresh React/Vite SPA for a sgnk.ai sub-brand | [[sgnk-react]] |
| Bootstrapping a new `*.sgnk.ai` subdomain (repo + Vercel + Cloudflare) | [[gvc]] |

These compose. A new `studio.sgnk.ai` post would typically go: **gvc** to bootstrap → **sgnk-next** to scaffold → **sgnk-design** for the visual language → **sgnk-writer** for the prose.

## References (load for depth)

- `references/sgnk-design-system.md` — **the canonical design system spec** (symlinked to the source-of-truth at `sagnikmitra.github.io/sgnk-design-system.md`). Tokens, typography ladder, components with markup snippets, do/don't, breakpoints, accessibility, SEO + OG, print, interactive states, IA, sub-brand variants, iteration guide, worked example. v1.1 is **operational** — every component carries paste-ready HTML.
- `references/sgnk-article-shell.html` — **the drop-in starter HTML for any new sgnk Writes piece** (symlinked to `sagnikmitra.github.io/sgnk-article-shell.html`). Carries the full CSS variables, topbar + lightrail hero + paper header + main column + TOC + footer + reading-progress / active-TOC / back-to-top JS + skip-link + `@media print`. Copy → rename → replace `{{PLACEHOLDERS}}` → ship. The fastest path from "blank file" to "publishable sgnk piece."

## Maintaining the system

- **Source of truth:** `/Users/sagnikmitra/Desktop/GitHub/sagnikmitra.github.io/sgnk-design-system.md`. This skill references it via symlink — edit either; both update.
- **Add a new component:** append to the `components:` YAML block in the canonical doc, then write a section under "Components" describing role, fill, border, padding, type, motion. Update the "Do" list if the new component carries a previously-unowned role.
- **Resolve a drift:** if a new design instinct fights the system (a second blue, a rounded button, a decorative shadow), the system wins until the spec is formally amended. Brand consistency compounds; ad-hoc beauty does not.
- **Version bump:** the YAML `version` field tracks material change. Bump on every new component, deprecated token, or breakpoint change.

## Voice pairing

The design system **hosts** the voice. When deploying a page on the chassis, the prose must come through [[sgnk-writer]] — earnest, plain, "in my usage" first-person, with the word-level texture (`pretty`, `to be honest`, So/Now/Though sentence-openers, ASCII emoticons). Polished design + marketing-tone prose breaks the brand because they fight each other. The two skills compose; never use one without considering the other.
