---
name: sgnk-snapshot
argument-hint: "[quick|full|all] [<repo-name>...]  (default: full on current dir)"
description: Capture a schema-versioned, machine-readable v3 JSON snapshot of one or more production codebases. Argument forms — `/sgnk-snapshot` (current dir), `/sgnk-snapshot quick`, `/sgnk-snapshot hq` (named repo), `/sgnk-snapshot hq trade inw-api` (multi-repo), `/sgnk-snapshot all` (every registered repo). Use when the user says snapshot, sgnk, switching accounts, leaving, "my limit is near", or names specific repos.
allowed-tools: Bash(git:*), Bash(bash:*), Bash(jq:*), Bash(find:*), Bash(ls:*), Bash(cat:*), Bash(mv:*), Bash(mkdir:*), Bash(shasum:*), Bash(wc:*), Bash(lsof:*), Bash(ps:*), Bash(docker:*), Bash(gh:*), Bash(timeout:*), Bash(sort:*), Bash(head:*), Bash(tail:*), Bash(date:*), Bash(uname:*), Bash(whoami:*), Bash(hostname:*), Bash(od:*), Read, Write, Glob, Grep
---

# sgnk-snapshot — durable working-memory handoff

Capture everything an agent needs to resume this codebase from another account/tool/
platform. The **script collects mechanical facts**; **you write the judgment** it
can't. The repo stays on disk — only the *working memory* travels.

## The split (do not blur it)

- `scripts/sgnk-collect.sh` produces a deterministic, secret-safe **`manifest.json`**
  (git/runtime/toolchain/remote). Trust it. **Never hand-derive git facts.**
- You author the **narrative cards** (KEY/context/tasks/runtime) — decisions, intent,
  next action, dead-ends. This is the part that makes a handoff *seamless*, not just
  possible.

## Argument grammar (`$ARGUMENTS`)

The args are an unordered mix of an optional **mode** + zero-or-more **targets**.

**Mode** (first matching token wins, default `full`):
- `quick` — KEY card + manifest only. Fast pre-limit save.
- `full`  — all four cards + manifest.
- `all`   — iterate every repo in `~/.sgnk/GLOBAL-REGISTRY.md` (multi-repo).

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
in sequence. **The narrative cards (KEY/01/02/03) are still written by you, the
model** — for multi-repo runs that means you write one set of cards per repo.
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

2b. **Always derive** the mechanical narrative inputs (cheap, runs locally on any
   repo even when you don't have live-session context for it):
   ```bash
   bash ${CLAUDE_SKILL_DIR}/scripts/sgnk-derive.sh "$REPO" > "$OUT/derived.json"
   ```
   This gives you: last 30 commits, commit-topic counts (feat/fix/chore/…),
   file-churn (top-touched files), per-branch last-commit subjects, README head,
   package metadata, TODO/FIXME samples, recent diffstats. Use it as the
   **floor** for narrative quality — even multi-repo/auto runs should produce
   richer-than-mechanical cards by reading derived.json.

   Decision rule for narrative depth:
   - **Live session context** (you've been working in this repo this session) →
     write the cards from that context first; use derived.json only to fill gaps
     (e.g. peers/branches inventory).
   - **No live context** (multi-repo run, named-target you haven't touched,
     EOD, milestone) → write cards by **summarizing derived.json**:
       * 01-context.md: distill the README head + package metadata into Key
         Technical Concepts; describe the architecture from the file churn.
       * 02-tasks.md: derive "Primary Request" from the dominant commit topic +
         README intent; "Files & Code Sections" from churn (top 5–10 files,
         with their recent commit subjects pulled from `commits[]`); "Recent
         Work" from commits[0..10]; "Branches & Peers" from
         `derived.branches` + `manifest.peers`; "Things to remove" from
         `todos_sample[]`.
       * 03-runtime.md: only if `manifest.runtime.services` is non-empty.
     Mark these cards `kind: derived` in their yaml header so the next agent
     knows they were script-summarized, not live narrative.

3. **Knowledge graph (graphify)** — *auto-built by the collector* in `full`/`all`
   mode when `kg_cli && (kg_stale || !kg_present)`. macOS-safe (background + poll,
   default 30s refresh / 60s first-build cap; override via `SGNK_GRAPHIFY_TIMEOUT`;
   skip via `SGNK_NO_GRAPHIFY=1`). After collect runs, `manifest.knowledge_graph`
   reflects the fresh state — you don't need to invoke `graphify` yourself. Just
   reference the outputs in the KEY card.

   `graphify-out/` is large and gitignored — it stays local (the resuming machine
   rebuilds it if absent). CLI verbs: `install | update <path> | explain "X" |
   path "A" "B" | watch <path>` — `graphify --help` for the full list. **No bare
   `graphify .` form.**

4. **Write the cards** into `$OUT/` — modelled on Claude Code's own auto-compaction
   format (proven to make resumption coherent). KEY ≤ 1 page; cards may be longer
   but stay tight — *never* paste large code bodies or full diffs.

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
     3. **Top modules** — bulleted list of `codebase.top_modules` (path → file count).
     4. **Tree (2 levels)** — fenced block of `codebase.tree`.
     5. **Entry points** — `package_scripts` (name → cmd), `package_bins`, `tauri`
        (bundle id + product name), `python_scripts`.
     6. **Routes / public surface** — `codebase.routes` if any, else "no route files
        detected".
     7. **Key configs** — `codebase.configs_present` as a comma-list.
     8. **Required env (names only)** — `manifest.runtime.required_env`.
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

   **Thin-transcript routing.** When `manifest.refs.transcript_lines < 50` (multi-
   repo, auto, EOD, or a brand-new session), there isn't enough live signal to
   write a credible `02-tasks.md`. In that case:
   - Mark `02-tasks.md` with yaml header `kind: derived-stub`.
   - Fill it ONLY with: §13 Branches & peers, §11 Things to remove (from
     `derived.todos_sample`), §9 DEAD-ENDS (empty placeholder). Skip §1–§8 and §10
     entirely — do not fabricate intent the user never expressed.
   - Recall reads the stub flag and leads from 04+05 instead. So thin captures
     still hand off the codebase cleanly.

5. **Publish atomically** (updates LATEST-KEY/LATEST, journal, registry; prunes to 20):
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
