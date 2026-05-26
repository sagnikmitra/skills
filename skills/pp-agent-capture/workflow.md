# Pp Agent Capture — Workflow

## Overview

How the `pp-agent-capture` skill works, step by step.

## Source Workflow

Codex skill workflow.

## Step-by-step Workflow

# Agent Capture - Printing Press CLI

## Prerequisites: Install the CLI

This skill drives the `agent-capture-pp-cli` binary. **You must verify the CLI is installed before invoking any command from this skill.** If it is missing, install it first:

1. Install via the Printing Press installer:
   ```bash
   npx -y @mvanhorn/printing-press install agent-capture --cli-only
   ```
2. Verify: `agent-capture-pp-cli --version`
3. Ensure `$GOPATH/bin` (or `$HOME/go/bin`) is on `$PATH`.

If the `npx` install fails (no Node, offline, etc.), fall back to a direct Go install (requires Go 1.26.3 or newer):

```bash
go install github.com/mvanhorn/printing-press-library/library/developer-tools/agent-capture/cmd/agent-capture-pp-cli@latest
```

If `--version` reports "command not found" after install, the install step did not put the binary on `$PATH`. Do not proceed with skill commands until verification succeeds.

## When to Use This CLI

Reach for this when the user wants:

- screenshot a specific window or app (`screenshot`, `batch` for multiple)
- record video of a window, app, display, or region (`record`)
- convert a recording to an optimized GIF (`convert`)
- do a full capture + record + GIF pipeline in one command (`pipeline`)
- diff against a baseline screenshot (`diff`) for before/after evidence
- bundle screenshots + recording + GIF as evidence for a PR or bug report (`evidence`)
- find the right window by fuzzy-matching its title (`find`)
- stitch multiple screenshots into an animated GIF (`stitch`)
- extract text from a window using macOS Vision OCR (`ocr`)
- record a terminal session via VHS tape files (`vhs`)
- render Remotion compositions to video or stills (`remotion`)
- monitor a UI by periodic screenshots (`watch`)
- save and replay capture configs (`preset`)

Skip it on non-macOS hosts; the CLI uses ScreenCaptureKit (macOS only). On first run it will prompt for Screen Recording permission; the `permissions` command guides that flow.

## Argument Parsing

Parse `$ARGUMENTS`:

1. **Empty, `help`, or `--help`** -> show `agent-capture --help`
2. **Starts with `install`** -> CLI installation (no MCP server ships today)
3. **Anything else** -> Direct Use (map to the best command and run it)
## Direct Use

1. Check installed: `which agent-capture`. If missing, offer CLI installation.
2. If permissions aren't granted, run `agent-capture permissions` first.
3. Use `agent-capture list` to see available capture targets (open windows, displays).
4. Use `agent-capture find <text>` to fuzzy-match a window title before capturing.
5. Execute with `--json` for structured output (agent-native default):
   ```bash
   agent-capture <command> [args] --json
   ```

## Notable Commands

| Command | What it does |
|---------|--------------|
| `screenshot` | Capture a window, app, display, or region |
| `record` | Record video of a window, app, display, or region |
| `pipeline` | Record + convert + optimize in one command |
| `convert` | Video -> optimized GIF (two-pass palette) |
| `diff` | Capture + diff against a baseline |
| `evidence` | Full bundle (screenshots + recording + GIF) for a PR |
| `batch` | Screenshot multiple apps in one invocation |
| `find` | Fuzzy search open window titles |
| `list` | List available capture targets |
| `ocr` | Extract text from a window using macOS Vision |
| `stitch` | Combine screenshots into an animated GIF |
| `vhs` | Run a VHS tape file for terminal recording |
| `remotion` | Render Remotion compositions |
| `watch` | Periodic capture for UI monitoring |
| `preset` | Save / load capture configs |
| `permissions` | Guide Screen Recording permission setup |
| `health` | Machine-readable CI / agent preflight |

Run any command with `--help` for full flag documentation.

## Agent Mode

Add `--agent` to any command. Expands to: `--json --compact --no-input --no-color --yes`.

- **Pipeable** — JSON on stdout, errors on stderr
- **Filterable** — `--select` keeps a subset of fields, with dotted-path support (see below)
- **Previewable** — `--dry-run` shows the request without sending
- **Cacheable** — GET responses cached for 5 minutes, bypass with `--no-cache`
- **Non-interactive** — never prompts, every input is a flag


### Filtering output

`--select` accepts dotted paths to descend into nested responses; arrays traverse element-wise:

```bash
<cli>-pp-cli <command> --agent --select id,name
<cli>-pp-cli <command> --agent --select items.id,items.owner.name
```

Use this to narrow huge payloads to the fields you actually need — critical for deeply nested API responses.


## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 2 | Usage error (wrong arguments) |
| 3 | Target not found (no matching window or display) |
| 4 | Permissions missing (Screen Recording not granted) |
| 5 | Capture error (ScreenCaptureKit failure, ffmpeg failure) |

## Execution Logic

The skill executes when its trigger fires (slash command, natural-language match, or direct invocation). It reads its references, applies its rules, and produces the documented outputs.

## Edge Cases

See the source skill's `references/` and `scripts/` folders for edge-case handling.

## Failure Handling

A skill failure surfaces as a tool error or a partial output; never a silent skip. Re-run with `--verbose` (where applicable) for diagnostics.

## Integration Notes

- Claude — invoked via the `Skill` tool with `skill: "pp-agent-capture"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/Pp Agent Capture/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: (none)_
