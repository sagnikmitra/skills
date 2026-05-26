# Skills Registry — the unified Skills Sync System

> One canonical registry. Many destinations. Every skill exists in exactly one
> normalized shape — `skill.md` + `workflow.md` — and shows up everywhere it
> needs to without manual copy-paste.

```
   Claude / Codex / Antigravity            (sources)
                  │
                  ▼
     scripts/sync.mjs  (scan + normalize)
                  │
                  ▼
        skills.registry.json
        skills/<slug>/skill.md
        skills/<slug>/workflow.md          (canonical)
                  │
        ┌─────────┼─────────┬──────────┬─────────────────────┐
        ▼         ▼         ▼          ▼                     ▼
     HQ        md.sgnk.ai Obsidian  HQ post-login         skills.sgnk.ai
   landing    Skills/    Skills/   sidebar              (public catalog)
   (Skills    (vault     (vault                          apps/skills-site
    top nav)   editor)    editor)
```

## What this repo holds

```
skills-registry/
├── skills-sync.config.json     # paths + rules (edit me)
├── skills.registry.json        # GENERATED. The canonical source of truth.
├── skills/                     # GENERATED. Canonical normalized skill.md + workflow.md.
├── scripts/
│   ├── sync.mjs                # scan + normalize + write to destinations
│   └── generate-hq-index.mjs   # writes Index.md MOCs into HQ + vault
├── reports/conflicts/          # GENERATED on conflict
├── apps/skills-site/           # skills.sgnk.ai — public catalog (Next.js)
└── package.json                # `npm run sync`
```

## Quickstart

```bash
# 1. Adjust source / destination paths in skills-sync.config.json.
# 2. Run a dry run.
npm run sync:dry
# 3. Run the real sync.
npm run sync
# 4. Inspect the registry.
npm run registry:show
```

## What gets written, where

| Destination | Path | Trigger | Purpose |
|---|---|---|---|
| **Canonical registry** | `./skills.registry.json` | every sync | machine-readable index every consumer reads |
| **Canonical normalized files** | `./skills/<slug>/{skill,workflow}.md` | every sync | raw normalized markdown |
| **Obsidian vault** | `~/Desktop/GitHub/md/Skills/<Name>/{skill,workflow}.md` | every sync | with YAML frontmatter + tags + backlinks |
| **MD Project (md.sgnk.ai)** | same as Obsidian | every sync | the md app reads from `Skills/` in the same repo |
| **HQ Skills (project scope)** | `~/Desktop/GitHub/md/Projects/HQ/Skills/<Name>/{skill,workflow}.md` | every sync | scoped mirror under the HQ project |
| **HQ + vault index MOCs** | `<dest>/Index.md` | every sync | grouped-by-category MOC, link to every skill |
| **skills.sgnk.ai content** | `./apps/skills-site/content/skills/<slug>/...` | every sync | feeds the public Next.js app |

## Sync rules (per the PRD)

| Operation | Behavior |
|---|---|
| **Add** | New skill detected → normalize → write everywhere → append to registry |
| **Update** | Existing skill changed → re-write content, bump `lastUpdated` |
| **Delete (in source)** | Move destination files to `_Archived/<Name>/` — never hard-delete |
| **Conflict** | Destination file diverges from prior registry hash → write a conflict report to `reports/conflicts/`, exit 2; do NOT overwrite |

Conflict detection: the live destination file's content hash (with frontmatter
stripped) is compared to the hash recorded in the *prior* run's registry. If
they differ, someone edited the destination outside the sync — that change is
real and is reported, not clobbered.

## HQ landing page top nav

The HQ project page (`Projects/HQ/HQ.md`) ships with a `nav` frontmatter
array — `Home · Notes · Skills · Architecture · PRD`. When HQ becomes a
Next.js landing page, that array drives the top navigation. The `Skills`
entry resolves to:

- **In-vault index:** `Projects/HQ/Skills/Index.md` (auto-generated MOC).
- **Public site:** [skills.sgnk.ai](https://skills.sgnk.ai).

## HQ post-login sidebar

When HQ ships as a Next.js app, its sidebar component reads
`skills.registry.json` (this repo) via build-time import or git-submodule.
Each entry links to a detail view that renders that skill's `skill.md` and
`workflow.md`. **No manual list.**

## skills.sgnk.ai (the public site)

`apps/skills-site/` is a minimal Next 15 / React 19 app. It reads the same
registry + normalized files. Routes:

- `/`                  — catalog grouped by category + source filter
- `/s/[slug]`          — skill detail with `skill.md` / `workflow.md` tabs
- `/about`             — the pipeline + the rules

```bash
cd apps/skills-site
npm install
npm run dev
```

Deploy: Vercel new project pointing at this folder, set the build command
to read the parent registry at build (already wired — `process.cwd()` →
`../..`).

## Source configuration

`skills-sync.config.json` is the single config. Edit `sources.codex[].path`
or `sources.antigravity[].path` to point at your machine's actual folders.
Mark missing sources `"optional": true` so a missing folder is a log line,
not an error.

## Composing with `sgnk-next`

If HQ is later built as a Next.js app via `sgnk-next`, this registry
becomes a `modules/skills/infrastructure/registry-loader.ts` adapter behind
a `SkillsRegistry` port — already aligned with the layering.

## Adding a brand-new skill

1. Author it in `~/.claude/skills/<slug>/` (or your Codex/Antigravity equivalent).
2. From this repo: `npm run sync`.
3. Verify: refresh `skills.sgnk.ai` (or `npm run dev`), open the vault, check `Projects/HQ/Skills/Index.md`.

## Editing a skill

Edit at the source (Claude/Codex/Antigravity). Run `npm run sync`. The
canonical registry + every destination updates.

> Editing a destination directly is allowed — but the next sync will detect
> the divergence as a **conflict** and write a report rather than overwrite
> you. Either backport the edit into the source, or set the destination as
> a new source in `skills-sync.config.json`.

## Going further

- Wire `npm run sync` into a git hook of the `md` repo so a vault edit
  triggers a re-sync.
- Wire a GitHub Action on this repo to redeploy `skills.sgnk.ai` on every
  push to `main`.
- Add `manual-skills/<slug>/{skill,workflow}.md` for skills you want in
  the registry but not in Claude/Codex/Antigravity.

## Non-negotiable rules (from the PRD)

- Do not maintain a separate skill list anywhere. Read the registry.
- Do not silently overwrite destination edits. Conflict-report them.
- Do not hard-delete on removal. Archive under `_Archived/`.
- Every skill must have both `skill.md` and `workflow.md`.
- One canonical source of truth: `skills.registry.json`.
