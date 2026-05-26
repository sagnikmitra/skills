# Pp Ahrefs — Workflow

## Overview

How the `pp-ahrefs` skill works, step by step.

## Source Workflow

Codex skill workflow.

## Step-by-step Workflow

# Ahrefs — Printing Press CLI

## Prerequisites: Install the CLI

This skill drives the `ahrefs-pp-cli` binary. **You must verify the CLI is installed before invoking any command from this skill.** If it is missing, install it first:

1. Install via the Printing Press installer:
   ```bash
   npx -y @mvanhorn/printing-press install ahrefs --cli-only
   ```
2. Verify: `ahrefs-pp-cli --version`
3. Ensure `$GOPATH/bin` (or `$HOME/go/bin`) is on `$PATH`.

If the `npx` install fails (no Node, offline, etc.), fall back to a direct Go install (requires Go 1.26.3 or newer):

```bash
go install github.com/mvanhorn/printing-press-library/library/marketing/ahrefs/cmd/ahrefs-pp-cli@latest
```

If `--version` reports "command not found" after install, the install step did not put the binary on `$PATH`. Do not proceed with skill commands until verification succeeds.

## When Not to Use This CLI

Do not activate this CLI for requests that require creating, updating, deleting, publishing, commenting, upvoting, inviting, ordering, sending messages, booking, purchasing, or changing remote state. This printed CLI exposes read-only commands for inspection, export, sync, and analysis.

## Command Reference

**keywords-explorer** — Keywords Explorer endpoints.

- `ahrefs-pp-cli keywords-explorer matching-terms` — Matching terms
- `ahrefs-pp-cli keywords-explorer overview` — Overview
- `ahrefs-pp-cli keywords-explorer related-terms` — Related terms
- `ahrefs-pp-cli keywords-explorer search-suggestions` — Search suggestions
- `ahrefs-pp-cli keywords-explorer volume-by-country` — Volume by country
- `ahrefs-pp-cli keywords-explorer volume-history` — Time-series. Volume history

**public** — Public endpoints.

- `ahrefs-pp-cli public crawler-ip-ranges` — Crawler IP ranges
- `ahrefs-pp-cli public crawler-ips` — Crawler IP addresses

**rank-tracker** — Rank Tracker endpoints.

- `ahrefs-pp-cli rank-tracker competitors-overview` — Competitors overview
- `ahrefs-pp-cli rank-tracker overview` — Overview
- `ahrefs-pp-cli rank-tracker serp-overview` — SERP Overview

**serp-overview** — Serp Overview endpoints.

- `ahrefs-pp-cli serp-overview` — SERP Overview

**site-audit** — Site Audit endpoints.

- `ahrefs-pp-cli site-audit issues` — Project Issues
- `ahrefs-pp-cli site-audit page-content` — Page content
- `ahrefs-pp-cli site-audit page-explorer` — Page explorer
- `ahrefs-pp-cli site-audit projects` — Project Health Scores

**site-explorer** — Site Explorer endpoints.

- `ahrefs-pp-cli site-explorer all-backlinks` — Backlinks
- `ahrefs-pp-cli site-explorer backlinks-stats` — Backlinks stats
- `ahrefs-pp-cli site-explorer broken-backlinks` — Broken Backlinks
- `ahrefs-pp-cli site-explorer domain-rating` — Point-in-time snapshot. Domain rating
- `ahrefs-pp-cli site-explorer domain-rating-history` — Time-series. Domain Rating history
- `ahrefs-pp-cli site-explorer metrics` — Point-in-time snapshot. Metrics
- `ahrefs-pp-cli site-explorer metrics-by-country` — Metrics by country
- `ahrefs-pp-cli site-explorer organic-competitors` — Organic competitors
- `ahrefs-pp-cli site-explorer organic-keywords` — Organic keywords
- `ahrefs-pp-cli site-explorer pages-by-traffic` — Pages by traffic
- `ahrefs-pp-cli site-explorer refdomains-history` — Time-series. Refdomains history
- `ahrefs-pp-cli site-explorer top-pages` — Top pages

**subscription-info** — Subscription Info endpoints.

- `ahrefs-pp-cli subscription-info` — Limits and usage


### Finding the right command

When you know what you want to do but not which command does it, ask the CLI directly:

```bash
ahrefs-pp-cli which "<capability in your own words>"
```

`which` resolves a natural-language capability query to the best matching command from this CLI's curated feature index. Exit code `0` means at least one match; exit code `2` means no confident match — fall back to `--help` or use a narrower query.

## Auth Setup

Set your API key via environment variable:

```bash
export AHREFS_API_KEY="<your-key>"
```

Or persist it in `~/.config/ahrefs-pp-cli/config.toml`.

Run `ahrefs-pp-cli doctor` to verify setup.

## Agent Mode

Add `--agent` to any command. Expands to: `--json --compact --no-input --no-color --yes`.

- **Pipeable** — JSON on stdout, errors on stderr
- **Filterable** — `--select` keeps a subset of fields. Dotted paths descend into nested structures; arrays traverse element-wise. Critical for keeping context small on verbose APIs:

  ```bash
  ahrefs-pp-cli keywords-explorer matching-terms --agent --select id,name,status
  ```
- **Previewable** — `--dry-run` shows the request without sending
- **Offline-friendly** — sync/search commands can use the local SQLite store when available
- **Non-interactive** — never prompts, every input is a flag
- **Read-only** — do not use this CLI for create, update, delete, publish, comment, upvote, invite, order, send, or other mutating requests

### Response envelope

Commands that read from the local store or the API wrap output in a provenance envelope:

```json
{
  "meta": {"source": "live" | "local", "synced_at": "...", "reason": "..."},
  "results": <data>
}
```

Parse `.results` for data and `.meta.source` to know whether it's live or local. A human-readable `N results (live)` summary is printed to stderr only when stdout is a terminal — piped/agent consumers get pure JSON on stdout.

## Agent Feedback

When you (or the agent) notice something off about this CLI, record it:

```
ahrefs-pp-cli feedback "the --since flag is inclusive but docs say exclusive"
ahrefs-pp-cli feedback --stdin < notes.txt
ahrefs-pp-cli feedback list --json --limit 10
```

Entries are stored locally at `~/.ahrefs-pp-cli/feedback.jsonl`. They are never POSTed unless `AHREFS_FEEDBACK_ENDPOINT` is set AND either `--send` is passed or `AHREFS_FEEDBACK_AUTO_SEND=true`. Default behavior is local-only.

Write what *surprised* you, not a bug report. Short, specific, one line: that is the part that compounds.

## Output Delivery

Every command accepts `--deliver <sink>`. The output goes to the named sink in addition to (or instead of) stdout, so agents can route command results without hand-piping. Three sinks are supported:

| Sink | Effect |
|------|--------|
| `stdout` | Default; write to stdout only |
| `file:<path>` | Atomically write output to `<path>` (tmp + rename) |
| `webhook:<url>` | POST the output body to the URL (`application/json` or `application/x-ndjson` when `--compact`) |

Unknown schemes are refused with a structured error naming the supported set. Webhook failures return non-zero and log the URL + HTTP status on stderr.

## Named Profiles

A profile is a saved set of flag values, reused across invocations. Use it when a scheduled agent calls the same command every run with the same configuration - HeyGen's "Beacon" pattern.

```
ahrefs-pp-cli profile save briefing --json
ahrefs-pp-cli --profile briefing keywords-explorer matching-terms
ahrefs-pp-cli profile list --json
ahrefs-pp-cli profile show briefing
ahrefs-pp-cli profile delete briefing --yes
```

Explicit flags always win over profile values; profile values win over defaults. `agent-context` lists all available profiles under `available_profiles` so introspecting agents discover them at runtime.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 2 | Usage error (wrong arguments) |
| 3 | Resource not found |
| 4 | Authentication required |
| 5 | API error (upstream issue) |
| 7 | Rate limited (wait and retry) |
| 10 | Config error |

## Argument Parsing

Parse `$ARGUMENTS`:

1. **Empty, `help`, or `--help`** → show `ahrefs-pp-cli --help` output
2. **Starts with `install`** → ends with `mcp` → MCP installation; otherwise → see Prerequisites above
3. **Anything else** → Direct Use (execute as CLI command with `--agent`)
## MCP Server Installation

1. Install the MCP server:
   ```bash
   go install github.com/mvanhorn/printing-press-library/library/marketing/ahrefs/cmd/ahrefs-pp-mcp@latest
   ```
2. Register with Claude Code:
   ```bash
   claude mcp add ahrefs-pp-mcp -- ahrefs-pp-mcp
   ```
3. Verify: `claude mcp list`

## Direct Use

1. Check if installed: `which ahrefs-pp-cli`
   If not found, offer to install (see Prerequisites at the top of this skill).
2. Match the user query to the best command from the Unique Capabilities and Command Reference above.
3. Execute with the `--agent` flag:
   ```bash
   ahrefs-pp-cli <command> [subcommand] [args] --agent
   ```
4. If ambiguous, drill into subcommand help: `ahrefs-pp-cli <command> --help`.

## Execution Logic

The skill executes when its trigger fires (slash command, natural-language match, or direct invocation). It reads its references, applies its rules, and produces the documented outputs.

## Edge Cases

See the source skill's `references/` and `scripts/` folders for edge-case handling.

## Failure Handling

A skill failure surfaces as a tool error or a partial output; never a silent skip. Re-run with `--verbose` (where applicable) for diagnostics.

## Integration Notes

- Claude — invoked via the `Skill` tool with `skill: "pp-ahrefs"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Pp Ahrefs/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: (none)_
