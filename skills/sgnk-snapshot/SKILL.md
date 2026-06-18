---
name: sgnk-snapshot
argument-hint: "[quick|full|all] [<repo-name>...]  (default: full on current dir)"
description: Capture a schema-versioned, secret-safe v3 JSON snapshot of one or more production codebases — manifest + resume cards — so handing the work off to another AI account, tool, agent, or platform is seamless. Argument forms — `/sgnk-snapshot` (current dir), `/sgnk-snapshot quick` (fast pre-limit save), `/sgnk-snapshot hq` (named repo), `/sgnk-snapshot hq trade inw-api` (multi-repo), `/sgnk-snapshot all` (every registered repo). Use when the user says snapshot, sgnk, "switching accounts", "I'm leaving", "my limit is near", "save my context", "before I switch tools/models", or names specific repos to capture.
allowed-tools: Bash(git:*), Bash(bash:*), Bash(jq:*), Bash(find:*), Bash(ls:*), Bash(cat:*), Bash(mv:*), Bash(mkdir:*), Bash(shasum:*), Bash(wc:*), Bash(lsof:*), Bash(ps:*), Bash(docker:*), Bash(gh:*), Bash(timeout:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(date:*), Bash(uname:*), Bash(whoami:*), Bash(hostname:*), Bash(od:*), Read, Write, Glob, Grep
---

# sgnk-snapshot — durable working-memory handoff

Capture everything an agent needs to resume this codebase from another account/tool/
platform. The **scripts produce a complete mechanical floor** (manifest + five
narrative cards); **you enrich** the cards that need judgment. The repo stays on
disk — only the *working memory* travels.

## The split (do not blur it)

- `scripts/sgnk-collect.sh` produces a deterministic, secret-safe **`manifest.json`**
  (git/runtime/toolchain/codebase/remote) and then automatically invokes
  `scripts/sgnk-derive.sh` (commits/churn/clusters/TODOs) and
  `scripts/sgnk-write-cards.sh`, which emit cards `01-context.md`, `02-tasks.md`,
  `03-runtime.md` (if services exist), `04-codebase.md`, and
  `05-features-and-issues.md`. Trust them — they are deterministic, bounded, and
  secret-safe (they never read `.env*`). Hand-deriving git facts or re-emitting
  these cards from scratch only invites drift and risks leaking values the scripts
  deliberately exclude, so don't: the cards will already exist on disk by the time
  the collector returns.
- Your job is to **author/enrich** the cards that benefit from judgment — primarily
  `00-KEY.md` (the resume card) and optionally `02-tasks.md` (transcript summary
  on top of the mechanical user-prompt floor). `sgnk-write-cards.sh` is idempotent:
  if you write a richer `02-tasks.md` first, the script will skip it.

## Argument grammar (`$ARGUMENTS`)

The args are an unordered mix of an optional **mode** + zero-or-more **targets**.

**Mode** (first matching token wins, default `full`):
- `quick` — KEY card + manifest only (the script still writes the mechanical
  01–05 cards; quick just skips the slow remote/graphify phases). Fast pre-limit save.
- `full`  — all five mechanical cards (01–05) + manifest + remote + graphify.
- `all`   — iterate every repo in `~/.sgnk/GLOBAL-REGISTRY.md` (multi-repo);
  each repo gets the full per-repo flow.

**Targets** (any remaining tokens):
- *(none)* → current `git rev-parse --show-toplevel`.
- Bare names like `hq`, `trade`, `inw-api` → resolved via
  `"${GVC_BASE_DIR:-$HOME/Desktop/GitHub}/<name>"`. If that's not a git repo, fall
  back to grepping `~/.sgnk/GLOBAL-REGISTRY.md` for any registered path whose
  basename matches. If still no match, *ask* the user — don't silently pick.
- Absolute paths are accepted as-is.

Examples:
- `/sgnk-snapshot`               → full on current dir
- `/sgnk-snapshot quick`         → quick on current dir
- `/sgnk-snapshot hq`            → full on `~/Desktop/GitHub/hq`
- `/sgnk-snapshot quick hq trade` → quick on both `hq` and `trade`
- `/sgnk-snapshot all`           → full on every registered repo

When multiple targets are given (or `all`), run the full per-repo flow for each
in sequence. **`00-KEY.md` is still written by you, the model** (cards 01–05 are
written mechanically by the scripts) — for multi-repo runs that means you author
one KEY card per repo.
If the user fired off a multi-repo snapshot without prose context, fall back to
mechanical-mode cards (short KEY only; mode tag `auto`) and tell the user.

## Procedure

1. **Pick an ID:** `ID=<UTCstamp>_<topic-slug>_<rand>` e.g. `20260608T120000Z_auth-rls_4f2a`.
   Use a short kebab slug describing the work in flight.

2. **Collect** (the script writes `manifest.json`; `SGNK_ID` pins the id to the dir):
   ```bash
   REPO="$(git rev-parse --show-toplevel)"
   OUT="$REPO/.sgnk/snapshots/$ID"
   SGNK_ID="$ID" bash ${CLAUDE_SKILL_DIR}/scripts/sgnk-collect.sh "$REPO" "$OUT" <mode>
   ```
   Read the manifest back (`jq . "$OUT/manifest.json"`) to ground your narrative in
   real numbers — branch, drift, dirty paths, running services, open PRs.

2b. **Mechanical cards 01–05 are already on disk.** `sgnk-collect.sh` invokes
   `sgnk-derive.sh` (writes `derived.json`) and `sgnk-write-cards.sh` (writes
   the five cards) automatically. By the time step 2 returns you have:
   - `01-context.md`  — frameworks, key concepts, README head, convention docs
   - `02-tasks.md`    — verbatim user prompts (extracted via `jq` from the
                         Claude Code transcript jsonl) + recent commits +
                         branches/peers + TODOs
   - `03-runtime.md`  — services, ports, required env names, restart commands
                         (emitted only if `manifest.runtime.services` or
                         `manifest.runtime.required_env` is non-empty)
   - `04-codebase.md` — what-app-does + frameworks + modules + tree + deps +
                         entry points + routes + db schema + env groups + ADRs
   - `05-features-and-issues.md` — feature thrust + branches in flight + CI +
                                    open PRs/issues + TODOs + recent diffs

   This is the **mechanical floor** — every snapshot has these, including
   SessionEnd auto-captures, multi-repo runs, and EOD milestones. The writer
   is idempotent: if you have rich live context, write your card first and the
   script will skip it. If your card is missing or thinner than the
   mechanical scaffold, the writer fills it in.

3. **Knowledge graph (graphify)** — *auto-built by the collector* in `full`/`all`
   mode when `kg_cli && (kg_stale || !kg_present)`. macOS-safe (background + poll,
   default 30s refresh / 60s first-build cap; override via `SGNK_GRAPHIFY_TIMEOUT`;
   skip via `SGNK_NO_GRAPHIFY=1`). After collect runs, `manifest.knowledge_graph`
   reflects the fresh state — you don't need to invoke `graphify` yourself. Just
   reference the outputs in the KEY card.

   `graphify-out/` is large and gitignored — it stays local (the resuming machine
   rebuilds it if absent). CLI verbs: `query "<q>" | explain "X" | path "A" "B" |
   update <path> | watch <path> | install` — `graphify --help` for the full list.
   `query` is the one the resume cards point the next agent at. **No bare
   `graphify .` form.**

4. **Enrich the cards** (mechanical scaffold is already on disk — your job is to
   add judgment where it matters). Always author `00-KEY.md` from scratch.
   For live sessions, optionally rewrite `02-tasks.md` with a richer
   transcript summary that goes beyond verbatim user prompts (decisions, errors,
   pending tasks, blockers). Cards modelled on Claude Code's own auto-compaction
   format — KEY ≤ 1 page; cards may be longer but stay tight — *never* paste
   large code bodies or full diffs.

   To rewrite a card the writer already populated, just `Write` your richer
   version — your file overwrites the mechanical scaffold. To force the writer
   to rebuild from manifest (e.g. after `Write`ing a card you want to discard):
   ```bash
   bash ${CLAUDE_SKILL_DIR}/scripts/sgnk-write-cards.sh "$OUT" "$REPO" --force
   ```

   - **`00-KEY.md`** — the **resume card**. Fenced yaml header
     `{id, head_sha, branch, utc}`, then:
     - **Session arc** (1 paragraph) — the LONGER project context: what the user
       has been refining across sessions, not just this WIP. (Claude compaction §1.)
     - **change_intent** — what the in-flight WIP accomplishes.
     - **Why switching** (account/limit) + time spent + est. remaining.
     - **THE single next action** — one concrete step. (Claude §9.)
     - A fenced ` ```bash ` **REPLAY** block: `git checkout` the branch + restart
       runtime (from `manifest.runtime`) + the focused verify command.
     - **OPEN:** `file:line` anchors of the active edit points.
     - **Knowledge graph:** if `manifest.knowledge_graph.present`, point to
       `graphify-out/GRAPH_REPORT.md` + a sample `graphify query "<q>"`.
     - **Full transcript:** if `manifest.refs.transcript_path` is set, footer line:
       `Verbatim session at: <path> (<transcript_lines> lines). Grep it for any
       detail not captured here.` (Claude compaction puts this exact footer.)

   - **`01-context.md`** *(full only)* — **Key Technical Concepts** (frameworks /
     patterns this session leaned on, bulleted), then decisions & WHY,
     architecture/contracts/migrations in flight, gotchas, risks, deploy narrative,
     glossary, navigation. (Claude §2.)

   - **`02-tasks.md`** *(full only)* — the **session log**, in the order Claude's
     compactor uses (this is the highest-signal card):
     1. **Primary Request & Intent** — the user's overarching request + bullet
        list of what *this* session covered.
     2. **All User Messages** — *verbatim* chronological list of every user
        prompt this session (1-line each; full text for short ones, head + tail
        for long ones). This is the single highest-leverage section — it lets
        the next agent reconstruct intent from the user's own words. (Claude §6.)
     3. **Files & Code Sections** — for every file actively modified, one block:
        - **`path/to/file`** (one-line description of what it is)
        - **Changes:** specific before→after values, line numbers, and any
          embedded code snippet that captures the *exact* edit. E.g.
          "`logoWrap.minHeight: 52 → 34`", or "swapped strict anti-relay check
          for email-format validation (lines 163-172)". (Claude §3.)
     4. **Errors & Fixes** — table/list: what broke → root cause → fix that
        worked. (Claude §4.)
     5. **Problem Solving** — clever moves that worked (multi-branch
        consolidation, constraint workarounds). (Claude §5.)
     6. **Current Work** — literally what you were doing at switch time
        (mid-refactor of X, paused on Y). (Claude §8.)
     7. **Pending Tasks** — explicit asks not yet started. (Claude §7.)
     8. **Optional Next Step** — concrete continuation, possibly more than the
        single next action in KEY. (Claude §9.)
     9. **DEAD-ENDS already ruled out** — what NOT to try and why.
     10. **Blockers** — what's stuck and on whom: each as
         `<thing> — waiting on <who/what> — since <when>`.
     11. **Things to remove** — dead code, deprecated flags, stale TODOs, files
         flagged for deletion. Explicit so the next agent doesn't preserve them.
     12. **Good-to-have / Wishlist** — desirable but not blocking work: nice
         refactors, polish ideas, follow-up enhancements.
     13. **Branches & peers** — point to `manifest.vcs.branches_detail` (per-branch
         last commit + author) and `manifest.peers` (top committers + Co-Authored-By).
         You don't need to retype them — just call out the active branches the
         resuming agent should know about and any collaborators currently involved.

   - **`03-runtime.md`** *(full only, if `manifest.runtime.services` is non-empty)*
     — exact steps to rebuild the running environment: servers, ports, db,
     migrations, seed, feature flags.

   - **`04-codebase.md`** *(always written, mechanical — from `manifest.codebase`)*
     — **the codebase you're inheriting**. This card closes the
     "never read src/" gap so a resuming agent doesn't have to traverse the tree
     from scratch. Sections, in order:
     1. **What this app does** — one paragraph, from `manifest.codebase.description`.
     2. **Frameworks & stack** — `manifest.codebase.frameworks` + `toolchain.languages` +
        `toolchain.package_manager` + `toolchain.runtime_versions`.
     3. **Top modules** — bulleted list of `codebase.top_modules` with `files` AND
        `tests` count per path (so the agent sees which modules have test coverage).
     4. **Tree (2 levels)** — fenced block of `codebase.tree`.
     5. **Top dependencies** — `codebase.top_deps` (each entry has `lang` field:
        `js`/`js-dev`/`py`/`rust`/etc). The agent reads "what stack" at a glance.
     6. **Entry points** — `package_scripts` (name → cmd), `package_bins`, `tauri`
        (bundle id + product name), `python_scripts`.
     7. **Routes / public surface** — `codebase.routes` if any, else "no route files
        detected".
     8. **DB schema** — `codebase.db_schema`: list prisma models (name + field
        count), drizzle schema files, supabase migration count. Skip section if
        `db_schema == null`.
     9. **External services (env groups)** — `codebase.env_groups` (prefix →
        count). Lets the agent see "this app talks to STRIPE, SUPABASE, AI
        providers" without parsing the raw env list.
     10. **Required env (names only)** — `manifest.runtime.required_env`.
     11. **Convention docs** — `codebase.convention_docs` (path + first H1).
         Pointer to CLAUDE.md / AGENTS.md / .cursor/rules / .windsurfrules /
         .github/copilot-instructions.md so the resuming agent reads them.
     12. **ADRs** — `codebase.adrs` (path + title). Skip section if empty.
     13. **Key configs** — `codebase.configs_present` as a comma-list.
     Write this card mechanically from the manifest — do not add narrative beyond
     what the fields provide. Yaml header `kind: codebase-derived`.

   - **`05-features-and-issues.md`** *(full/all only — from `derived.json` +
     `manifest.remote`)* — **what's in flight + what hurts**. Sections:
     1. **Current feature thrust** — bulleted `derived.feature_clusters` (top 5
        dirs by commit count over last 30 commits; per-cluster: recent 3 subjects).
     2. **Branches in flight** — `derived.branch_diffstats.entries` (branch → diff
        vs `base`).
     3. **Recent CI runs** — `manifest.remote.recent_runs` (latest 5: workflow,
        status, conclusion).
     4. **Open PRs** — `manifest.remote.open_prs`.
     5. **Open issues** — `manifest.remote.open_issues`.
     6. **TODO/FIXME sample** — `derived.todos_sample` grouped by top-level dir.
     7. **Last-commit diff highlights** — `derived.recent_diffs`.
     Yaml header `kind: features-issues-derived`.

   **Thin-transcript routing.** The writer auto-marks `02-tasks.md` with
   `kind: derived-stub` when `manifest.refs.transcript_lines < 50` (multi-repo,
   auto, EOD, brand-new session). In that mode the card has no §1 verbatim
   prompts — just §2 recent commits, §3 branches/peers, §4 TODOs, §5 in-progress
   git op, §6 dirty paths. Recall reads the stub flag and leads from 04+05
   instead, so thin captures still hand off the codebase cleanly. **Do not
   fabricate user intent the transcript doesn't contain.** If you have judgment
   to add (e.g. you've been working in this repo just not via Claude Code), put
   it in `00-KEY.md`.

5. **Publish atomically** (updates LATEST-KEY/LATEST, journal, registry; prunes
   working-memory snapshots to the `SGNK_RETAIN` newest — default 100 — while
   `_eod_`/`_milestone_` IDs are kept forever):
   ```bash
   HEAD="$(git -C "$REPO" rev-parse HEAD)"
   bash ${CLAUDE_SKILL_DIR}/scripts/sgnk-pointers.sh "$REPO" "$ID" <mode> "$HEAD" "<one-line summary>"
   ```

6. **Print** the snapshot path and the full `00-KEY.md` so the user knows it is safe
   to switch.

- `all` mode: read `~/.sgnk/GLOBAL-REGISTRY.md`, then repeat steps 1–4 per repo,
  `cd`-ing into each. Each repo's snapshot is independent; the journal/registry are
  append/replace-safe under concurrency (mkdir-mutex).
- `sync` (only if the user says it): `git -C "$REPO" add -f .sgnk/ && git commit -m
  "sgnk snapshot $ID"` on a `sgnk-snapshots` branch and push. `.sgnk/` is gitignored
  by default, hence `-f`.

## Guarantees (state these to the user when relevant)

- Completes in **seconds** even on huge monorepos — bounded commands, no full diffs,
  every list capped, remote (`gh`) phase time-boxed and skippable.
- `manifest.json` is **valid JSON** (the script self-checks with `jq`) and **secret-
  safe** (never reads `.env*`/keys; `required_env` is NAMES only).
- An agent can resume from `00-KEY.md` + `manifest.json` alone.

## Operator notes

- Always run the scripts — don't re-implement collection inline.
- If `sgnk-collect.sh` exits non-zero, it prints why (not a git repo / jq missing).
  Fix that; don't fabricate a manifest.
- macOS-native: no `flock`/`sha256sum`/GNU-date dependencies.
- Recall the other side with **`/sgnk-recall`**.
