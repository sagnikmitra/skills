---
name: sgnk-recall
argument-hint: "[latest|all|list|<id>] [<repo-name>...]  (default: latest on current dir)"
description: Deterministically load a SGNK snapshot after switching accounts/tools/agents/platforms — parse manifest.json, compute exact git drift, reconcile live state, restore runtime, present a resume plan. Argument forms — `/sgnk-recall` (current dir), `/sgnk-recall list` (chronological history), `/sgnk-recall hq` (named repo), `/sgnk-recall hq trade` (multi-repo brief), `/sgnk-recall all` (every registered repo), `/sgnk-recall <snapshot-id>` (specific past snapshot). Use when the user says recall, resume, "list snapshots", "what snapshots are there", or names specific repos.
allowed-tools: Bash(git:*), Bash(bash:*), Bash(jq:*), Bash(cat:*), Bash(ls:*), Bash(lsof:*), Bash(ps:*), Bash(gh:*), Bash(timeout:*), Bash(find:*), Read, Glob, Grep
---

# sgnk-recall — pick up exactly where the last session left off

Whoever left wrote a snapshot. You arrive, load it, and **reconcile it against the
live repo** before touching anything. The loader is deterministic; your job is the
judgment: what changed since, what's safe to resume, what to avoid.

## Procedure (default: `latest`)

1. **Parse args** (`$ARGUMENTS`) — same grammar as `/sgnk-snapshot`. Unordered mix
   of an optional **mode** + zero-or-more **targets**.

   **Mode** (first matching token wins, default `latest`):
   - `latest` — load the newest snapshot for the target (default).
   - `list` / `history` — emit the chronological snapshot timeline (latest →
     oldest), latest marked, kind-tagged (`manual` / `auto` / `eod` / `milestone`).
     Triggers: user says "list snapshots", "history", "what snapshots do we have",
     "go back two", "before the refactor". Run `list` FIRST in these cases —
     do not silently load LATEST.
   - `all` — every registered repo in `~/.sgnk/GLOBAL-REGISTRY.md`.
   - A bare **snapshot id** like `20260608T001450Z_sgnk-compaction-format_3728` —
     load that specific past snapshot.

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

2. **Load + drift** (one deterministic call per target, JSON out):
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

2. **Read the narrative** the loader doesn't carry, in **resumption-signal order**:
   - **`02-tasks.md` § All User Messages first** — these are verbatim user prompts
     and the densest source of intent. The arriving agent should read these *before*
     any decisions card, exactly the way Claude Code's own auto-compaction surfaces
     them. Then read the rest of 02 (Files & Changes, Errors & Fixes, Problem
     Solving, Current Work, Pending Tasks, DEAD-ENDS).
   - Then `00-KEY.md` (change_intent, REPLAY, OPEN, knowledge-graph + transcript
     footer).
   - `01-context.md` / `03-runtime.md` only as needed.
   - **Ground-truth fallback:** `manifest.refs.transcript_path` is the full Claude
     Code session jsonl (`~/.claude/projects/<sanitized-cwd>/<uuid>.jsonl`). If
     anything in the cards is ambiguous, grep it directly — `jq -r 'select(.type=="user") | .message.content' <path>` extracts every user message verbatim. Treat the jsonl as authoritative; the cards are the curated summary.

3. **Reconcile and report EXACT drift — loudly when it's high:**
   - commits landed since the snapshot (list them),
   - branch / dirty deltas,
   - whether the recorded rebase/merge/cherry-pick is **still pending**,
   - which dev services are **down** and how to restart them (from `03-runtime.md`),
   - CI / open-PR changes, unaddressed review comments.
   - If `new_commits` says the recorded head isn't in history (rebased / different
     clone), say so plainly — the REPLAY checkout may need adjusting.

4. **Multiple concurrent snapshots** (other tools): the `journal` lists each with
   provenance ("claude/sagnik 2h ago", "codex/… 20m ago"). Surface them, reconcile,
   and flag conflicts (e.g. two tools on different branches).

5. **Knowledge graph (graphify)** — if `manifest.knowledge_graph.present` (or
   `graphify-out/graph.json` exists on disk), REFER the user to it so they can explore
   the codebase semantically instead of re-reading files:
   - `graphify query "<question>"` (broad BFS context), `graphify path "A" "B"`,
     `graphify explain "Node"`, or read `graphify-out/GRAPH_REPORT.md`.
   - If `knowledge_graph.stale` is true, suggest `graphify . --update` to refresh.
   - If NOT present but `cli_available` is true, note it builds automatically on the
     next `/sgnk-snapshot` (or `graphify .` now).

6. **Brief the user**, then stop. The brief, in this order:
   - **Verbatim user prompts** from 02 (the most recent 3–5) — let the user see
     their own words back so they confirm intent.
   - Where we were + change_intent.
   - The plan with current step + **THE next action** + REPLAY + OPEN anchors.
   - **Blockers** (02 §10) — what's stuck.
   - **Pending tasks** + **Things to remove** + **Good-to-have** (02 §7/11/12) —
     so the resuming agent sees the full follow-on backlog at a glance.
   - DEAD-ENDS to avoid; errors already fixed.
   - Live drift (commits since, dirty delta, in-progress op, ports down).
   - **Branches & peers** — list `manifest.vcs.branches_detail` (last commit per
     branch) and `manifest.peers.authors` so the user can switch context fast
     and remember who's involved.
   - Runtime to restore; failing tests/CI.
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
