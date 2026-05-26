# Gvc

## Purpose

GitHub + Vercel + Cloudflare project bootstrap. Use when the user gives a project name and wants a private GitHub repository, local clone, hello-world Next.js app, initial commit and push, Vercel project/deployment, Cloudflare DNS custom domain such as project.sgnk.ai, and live health checks. Trigger on requests like "use gvc for xyz", "create/deploy xyz", "make xyz.sgnk.ai live", or any one-name repo-to-Vercel-to-domain bootstrap.

## Description

# GVC

## Overview

Create a production-ready starter app from one project name: GitHub repo, local clone, Next.js hello world, Vercel production deploy, Cloudflare DNS, and final URL verification.

Default Sagnik machine settings:

- GitHub owner: `sagnikmitra`
- Vercel scope: `sagnik`
- Domain root: `sgnk.ai`
- Local root: `/Users/sagnikmitra/Desktop/GitHub`
- Local dev launcher: `sgnk <project>`
- Repo visibility: private
- Site visibility: public
- Account token file: `/Users/sagnikmitra/.config/codex-env/tokens.zsh`

For other machines, require equivalent flags/env and explain missing setup rather than asking for secrets in chat.

## Project Name Rules

Normalize the user-provided name before running anything:

- Lowercase.
- Convert underscores/spaces to hyphens.
- Keep only `a-z`, `0-9`, and `-`.
- Collapse repeated hyphens.
- Reject empty names, leading/trailing hyphens, labels over 63 chars, and names that do not match the final normalized name unless the user clearly permits normalization.

Examples: `xyz` -> `xyz`, `xyz-A` -> `xyz-a`, `my_app` -> `my-app`.

## Quick Start

Prefer the bundled runner for deterministic execution:

```bash
python3 ~/.codex/skills/gvc/scripts/gvc_bootstrap.py xyz \
  --github-owner sagnikmitra \
  --vercel-scope sagnik \
  --domain-root sgnk.ai \
  --base-dir /Users/sagnikmitra/Desktop/GitHub
```

Use `--dry-run` first when changing defaults or running on a new machine.

## Workflow

1. Load Sagnik account tokens from `/Users/sagnikmitra/.config/codex-env/tokens.zsh` or let the runner import it. Do not use `INW_*` tokens for GVC; those are for other specific projects.
2. Verify required tools: `git`, `gh`, `node`, `npm`, `vercel`, `curl`, `dig`.
3. Verify required tokens without printing values:
   - GitHub: `GH_TOKEN` or `GITHUB_TOKEN`
   - Vercel: `VERCEL_TOKEN`
   - Cloudflare: `CLOUDFLARE_API_TOKEN`
4. Create or reuse `github.com/<owner>/<project>` as a private repo.
5. For a newly-created empty repo, initialize the local repo directly at `<base-dir>/<project>` and add `origin`; clone only when reusing an existing remote repo.
6. Scaffold a minimal Next.js App Router starter directly from the runner and write the hello-world screen. Avoid `create-next-app`, local `npm install`, and local build on the happy path because Vercel production build plus live URL health is the final authority.
7. Use `--local-build` only when debugging or changing the template; use `--lockfile` only when a local package lock is explicitly needed.
8. Commit `Hello <project>` and push `main`.
9. Create/link Vercel project `<project>`, connect the GitHub repo, set framework `nextjs`, disable Vercel protection for public custom-domain access, and deploy production.
10. Add `<project>.<domain-root>` to the Vercel project.
11. In Cloudflare, create/update DNS-only records from Vercel config. Prefer Vercel-recommended A records when available; they avoid router/local resolver failures seen with Vercel's per-domain CNAME chains. Fall back to CNAME only when Vercel does not provide IPv4 values. Add Vercel TXT verification records if requested.
12. Verify the domain in Vercel. The runner caches TXT verification work and polls quickly, so repeated Vercel verification responses do not cause repeated Cloudflare writes or noisy logs.
13. Poll HTTP health through normal DNS and Cloudflare public DNS. On Sagnik's machine, if public DNS works but local DNS fails, auto-set Wi-Fi DNS to `1.1.1.1,8.8.8.8`, flush cache, and retest browser-style loading.
14. Redeploy production only if the verified custom domain is not healthy after a short probe. This avoids an unnecessary second Vercel deploy on the normal happy path.
15. Confirm the local dev launcher resolves with `sgnk <project> --dry-run`. Do not maintain a manual project registry; `sgnk` discovers all repos under `/Users/sagnikmitra/Desktop/GitHub` at runtime.
16. Return the GitHub URL, local path, Vercel deployment URL, custom URL, local dev command, health path, checks run, and any residual DNS propagation caveat.

## Local Dev Launcher

The global `sgnk` command is installed at `/Users/sagnikmitra/.local/bin/sgnk`.

Use it to open any local project under `/Users/sagnikmitra/Desktop/GitHub`:

```bash
sgnk <project>
```

Behavior:

- Resolves the project dynamically from the GitHub folder every run.
- Searches the repo root and common app folders for `package.json` with a `dev` script.
- Runs `npm run dev` in the selected folder.
- Detects the localhost URL from dev-server output and opens it in the browser.
- Supports new cloned/GVC-created repos without editing a registry, as long as the repo has a `dev` script.

Useful checks:

```bash
sgnk --list
sgnk --dry-run <project>
```

For GVC-created projects, ensure the scaffold keeps a root `package.json` with:

```json
{
  "scripts": {
    "dev": "next dev"
  }
}
```

## Failure Rules

- Never print token values.
- Do not overwrite an existing non-empty local directory unless it is already the matching Git repo.
- Do not delete unrelated Cloudflare records. Only update the exact project A/CNAME records and add missing exact TXT verification records.
- Keep the GitHub repo private by default.
- Keep the deployed site public by disabling Vercel deployment protection only for this new project.
- If a token, CLI, team scope, domain zone, or permission is missing, stop with exact missing item and remediation.
- Do not use `create-next-app` unless the direct scaffold path fails and the user explicitly wants the official generator.
- Do not run local dependency install/build by default. Use Vercel's production build and custom-domain `HTTP 200` as the release gate.
- Do not add new projects to a static `sgnk` registry. The launcher must stay dynamic so every cloned or newly bootstrapped repo becomes runnable by name.

## Resources

- Run `scripts/gvc_bootstrap.py` for the full bootstrap.
- Read `references/operator-guide.md` only when credentials, permissions, Vercel scopes, Cloudflare DNS, or health checks fail.

## Source

Codex

## Capabilities

- See original source for capabilities.

## Inputs

Inputs depend on the skill's trigger and arguments. See the source SKILL.md.

## Outputs

Outputs depend on the skill. Typical: files written, reports generated, agent actions performed.

## When To Use

When the user invokes `/gvc` or describes a task the skill's description matches.

## Dependencies

See the source skill's references and scripts folders.

## Related Systems

- Claude (if synced from `~/.claude/skills/gvc`)
- HQ Project — landing page Skills section
- MD Project (md.sgnk.ai) — `Skills/Gvc/`
- Obsidian Vault — `Skills/Gvc/`

## Examples

See workflow.md.

---

_Source: ~/.codex/skills/gvc/SKILL.md_
_Category: General_
