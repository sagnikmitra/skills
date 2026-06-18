---
name: sgnk-recall
argument-hint: "[list | all | <snapshot-id>] [<repo-name>...]  (default: latest on current dir)"
description: Deterministically load a SGNK snapshot after switching accounts/tools/agents/platforms — parse manifest.json, compute exact git drift, reconcile live state, restore runtime, present a resume plan. Argument forms — `/sgnk-recall` (current dir), `/sgnk-recall list` (chronological history), `/sgnk-recall hq` (named repo), `/sgnk-recall hq trade` (multi-repo brief), `/sgnk-recall all` (every registered repo), `/sgnk-recall <snapshot-id>` (specific past snapshot). Use when the user says recall, resume, "starting fresh", "pick up where I left off", "list snapshots", "what snapshots are there", or names specific repos to resume.
allowed-tools: Bash(git:*), Bash(bash:*), Bash(jq:*), Bash(cat:*), Bash(ls:*), Bash(lsof:*), Bash(ps:*), Bash(gh:*), Bash(timeout:*), Bash(find:*), Read, Glob, Grep
---

# sgnk-recall — pick up exactly where the last session left off

Whoever left wrote a snapshot. You arrive, load it, and **reconcile it against the
live repo** before touching anything. The loader is deterministic; your job is the
judgment: what changed since, what's safe to resume, what to avoid.

## Procedure (default: `latest`)

1. **Parse args** (`$ARGUMENTS`) — same grammar as `/sgnk-snapshot`. Unordered mix
   of an optional **mode** + zero-or-more **targets**.

   **Mode** (first matching token wins, default `latest`). Two are *loader-parsed*
   (passed through as the loader's second arg) and two are *model-side* (you expand
   them yourself before calling the loader):
   - `latest` *(model-side, default)* — load the newest snapshot for the target.
     This is the implicit default: call the loader with **no** id. (The loader also
     tolerates a literal `latest`/`all` token and treats it as the default, so an
     accidental pass-through won't error.)
   - `list` / `history` *(loader-parsed)* — emit the chronological snapshot timeline
     (latest → oldest), latest marked, kind-tagged (`manual` / `auto` / `eod` /
     `milestone`). Triggers: user says "list snapshots", "history", "what snapshots
     do we have", "go back two", "before the refactor". Run `list` FIRST in these
     cases — do not silently load LATEST.
   - `all` *(model-side)* — expand to every registered repo in
     `~/.sgnk/GLOBAL-REGISTRY.md`, then run the loader once per repo (default id each).
   - A bare **snapshot id** like `20260608T001450Z_sgnk-compaction-format_3728`
     *(loader-parsed)* — load that specific past snapshot.

   **Targets** (any remaining tokens):
   - *(none)* → current `git rev-parse --show-toplevel`.
   - Bare names like `hq`, `trade`, `inw-api` → resolve via
     `"${GVC_BASE_DIR:-$HOME/Desktop/GitHub}/<name>"`. If that's not a git repo,
     grep `~/.sgnk/GLOBAL-REGISTRY.md` for a matching basename. Ask the user
     if there's no unique match.
   - Absolute paths are accepted as-is.

   Examples:
   - `/sgnk-recall`              → latest on current dir
   - `/sgnk-recall list`         → timeline on current dir
   - `/sgnk-recall hq`           → latest on `~/Desktop/GitHub/hq`
   - `/sgnk-recall list hq`      → timeline on `~/Desktop/GitHub/hq`
   - `/sgnk-recall hq trade`     → brief on each (multi-repo cross-context)
   - `/sgnk-recall all`          → brief on every registered repo
   - `/sgnk-recall 20260608T001450Z_sgnk-compaction-format_3728` → that snapshot

2. **Load + drift + auto-heal** (one deterministic call per target, JSON out):
   ```bash
   bash ${CLAUDE_SKILL_DIR}/scripts/sgnk-load.sh "<resolved-repo-path>" [mode|id]
   ```

   For multi-repo (`hq trade`, `all`): run the loader once per target, then write
   a *cross-repo brief* — for each repo show 2–4 lines (branch / dirty / commits
   since / next action). Don't paste the full per-repo recall — the user can
   `/sgnk-recall <name>` for any single repo to drill in.

   The output has three parts:
   - `manifest` — the full recorded v3 state.
   - `drift` — computed live, NOW: `head.commits_since` + `new_commits`,
     `branch` change, `dirty` delta, `upstream` ahead/behind, `in_progress_op`
     still-pending, `runtime` (which recorded ports are up/down), `remote` PRs.
   - `journal` — recent snapshots across all chats/tools with provenance.

   **Auto-heal:** the loader detects "thin" snapshots (missing `04-codebase.md` /
   `05-features-and-issues.md`, OR a historical manifest with an empty
   `codebase.tree`) and silently runs `sgnk-collect.sh` + `sgnk-write-cards.sh`
   against the current repo state. The fresh manifest is saved as
   `manifest-current.json` (alongside the untouched historical `manifest.json`)
   and the missing cards are written. So even old `milestone-initial-archive`
   bootstraps surface full codebase + features context on first recall.

3. **Read the narrative.** All five cards (01–05) are always present after the
   loader returns — either written at snapshot time or by auto-heal just now.
   Check the `kind:` yaml header on `02-tasks.md` to pick the route:

   **Route A — live session (`kind: live-derived` or `kind: live`):**
   - **`02-tasks.md` §1 Verbatim user prompts first** — the densest source of
     intent, extracted directly from the Claude Code transcript jsonl. Read
     these *before* any decisions card, exactly the way Claude Code's own
     auto-compaction surfaces them. Then §2–§6 (Recent work, Branches & peers,
     TODOs, In-progress git op, Dirty paths). If the snapshot model also wrote
     additional sections (Errors & Fixes, Problem Solving, Pending Tasks,
     Blockers), read those next — they're enrichment above the mechanical floor.
   - Then `00-KEY.md` (change_intent, REPLAY, OPEN, knowledge-graph + transcript
     footer).
   - Then `04-codebase.md` + `05-features-and-issues.md` for the structural
     picture.
   - `01-context.md` / `03-runtime.md` as needed.

   **Route B — thin session (`kind: derived-stub`):**
   - Lead with `04-codebase.md` — this *is* the handoff when no live narrative
     exists. Surface what-it-does, frameworks, top modules, entry points, routes,
     configs.
   - Then `05-features-and-issues.md` — feature thrust, branches in flight, CI,
     open PRs/issues, TODOs.
   - Then `02-tasks.md` §2–§6 (recent commits, branches & peers, TODOs).
   - Then `00-KEY.md` for any narrative the model wrote (project arc,
     suggested next action).
   - **Do NOT claim "no user prompts" or "no decisions captured."** A thin-
     transcript snapshot is not a defect; lead with the codebase cards instead.

   **Ground-truth fallback (both routes):** `manifest.refs.transcript_path` is
   the full Claude Code session jsonl
   (`~/.claude/projects/<sanitized-cwd>/<uuid>.jsonl`). If anything in the cards
   is ambiguous, grep it directly — `jq -r 'select(.type=="user") | .message.content' <path>` extracts every user message verbatim. Treat the jsonl as authoritative; the cards are the curated summary.

4. **Reconcile and report EXACT drift — loudly when it's high:**
   - commits landed since the snapshot (list them),
   - branch / dirty deltas,
   - whether the recorded rebase/merge/cherry-pick is **still pending**,
   - which dev services are **down** and how to restart them (from `03-runtime.md`),
   - CI / open-PR changes, unaddressed review comments.
   - If `new_commits` says the recorded head isn't in history (rebased / different
     clone), say so plainly — the REPLAY checkout may need adjusting.

5. **Multiple concurrent snapshots** (other tools): the `journal` lists each with
   provenance ("claude/sagnik 2h ago", "codex/… 20m ago"). Surface them, reconcile,
   and flag conflicts (e.g. two tools on different branches).

6. **Knowledge graph (graphify)** — if `manifest.knowledge_graph.present` (or
   `graphify-out/graph.json` exists on disk), REFER the user to it so they can explore
   the codebase semantically instead of re-reading files:
   - `graphify query "<question>"` (broad BFS context), `graphify path "A" "B"`,
     `graphify explain "Node"`, or read `graphify-out/GRAPH_REPORT.md`.
   - If `knowledge_graph.stale` is true, suggest `graphify . --update` to refresh.
   - If NOT present but `cli_available` is true, note it builds automatically on the
     next `/sgnk-snapshot` (or `graphify .` now).

7. **Brief the user**, then stop. The brief structure depends on which route
   the narrative took (step 3). Skip sections that are empty rather than printing
   "none" stubs.

   **Route A (live) — order:**
   - **Verbatim user prompts** from 02 §2 (most recent 3–5) — let the user see
     their own words back so they confirm intent.
   - Where we were + change_intent.
   - **Codebase you're inheriting** (from `04-codebase.md`) — one line each:
     what-it-does, frameworks/stack, top 3 modules, primary entry point. Keep it
     to ~5 lines; the full card is one file away.
   - The plan with current step + **THE next action** + REPLAY + OPEN anchors.
   - **Blockers** (02 §10) — what's stuck.
   - **Pending tasks** + **Things to remove** + **Good-to-have** (02 §7/11/12).
   - **Current feature thrust + open PRs/issues** (from `05-features-and-issues.md`).
   - DEAD-ENDS to avoid; errors already fixed.
   - Live drift (commits since, dirty delta, in-progress op, ports down).
   - **Branches & peers** — list `manifest.vcs.branches_detail` (last commit per
     branch) and `manifest.peers.authors` so the user can switch context fast.
   - Runtime to restore; failing tests/CI.
   - **Knowledge-graph pointer** + **transcript path** for deeper grounding.

   **Route B (thin / derived-stub) — order:**
   - **Codebase you're inheriting** (from `04-codebase.md`) — lead with this. Give
     the resuming agent a complete picture before drift / branches: what-it-does,
     frameworks, top modules, tree summary, entry points, routes, configs,
     required env. Aim for ~10 lines.
   - **Current feature thrust + branches in flight** (from `05-features-and-issues.md`).
   - **Open PRs / issues / CI** (from 05) — what the project is publicly working on.
   - **TODO/FIXME sample** (from 05) — likely unfinished work.
   - Snapshot intent (KEY card) if the model wrote one.
   - Live drift (commits since, dirty delta).
   - **Knowledge-graph pointer** + **transcript path** for deeper grounding.

   Offer 1–2 improvements. **Do NOT mutate anything until the user confirms.** Load
   ONE snapshot + the compact journal by default; expand only if asked (protect
   the context budget).

## Setup (run once)

These are bundled, idempotent, and safe to re-run:

- **Install automation (global):**
  ```bash
  bash ${CLAUDE_SKILL_DIR}/scripts/sgnk-install.sh
  ```
  Creates `~/.sgnk/{bin,state}`, installs the three hook scripts, and merges the
  SessionStart / UserPromptSubmit / SessionEnd hooks into `~/.claude/settings.json`
  (backs it up first; preserves existing caveman/graphify hooks).
    - *SessionStart* → auto-surfaces this repo's KEY card as context.
    - *UserPromptSubmit* → nudges you to snapshot after a long session.
    - *SessionEnd* → writes a mechanical AUTO snapshot if you forgot to.

- **Bootstrap a repo for cross-tool recall (per repo):**
  ```bash
  bash ${CLAUDE_SKILL_DIR}/scripts/sgnk-bootstrap.sh "$(git rev-parse --show-toplevel)"
  ```
  Adds `.sgnk/` to `.gitignore` and writes a delimited SGNK pointer block into
  `AGENTS.md`, `.github/copilot-instructions.md`, `.windsurfrules`, and
  `.cursor/rules/sgnk.mdc` so Codex/Copilot/Cursor/Windsurf/Antigravity also read
  `.sgnk/LATEST-KEY.md` on start.

## Operator notes

- Trust `sgnk-load.sh` for manifest + drift; don't recompute git facts by hand.
- The loader exits non-zero with a clear message if there's no snapshot — then offer
  to run `/sgnk-snapshot`.
- Pairs with **`/sgnk-snapshot`** (the leaving side).
