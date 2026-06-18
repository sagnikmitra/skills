---
name: sgnk-md-update
description: Pull latest sgnk-md, rebuild the Tauri macOS app, replace the installed copy in /Applications, and relaunch. Preserves GitHub OAuth login (bundle ID ai.sgnk.md unchanged). Use when the user types /sgnk-md-update or asks to update sgnk-md, rebuild the md app, pull latest md app, ship md, or reinstall sgnk-md.
---

# sgnk-md-update — one-command upgrade

When the user invokes this skill, run `scripts/update.sh`. The script
handles every step end-to-end and surfaces what changed.

## What it does

```
git status check  ─►  git pull --rebase  ─►  npm install (only if package.json or
                                      │                    package-lock.json changed)
                                      │
                                      ▼
                            npm run tauri:build
                                      │
                                      ▼
              quit running sgnk-md  ─►  back up old /Applications/sgnk-md.app
                                      │  to sgnk-md-prev.app
                                      ▼
                  install fresh .app  ─►  open it
                                      │
                                      ▼
                       summary: commits pulled, size, .dmg path
```

## Safety guarantees

- **Aborts before any destructive step** if `git status` shows uncommitted
  changes in tracked files. User must commit or stash first. Untracked files
  are fine.
- **Backup, not delete**: previous `/Applications/sgnk-md.app` moves to
  `/Applications/sgnk-md-prev.app`. To roll back: kill new app + restore the
  `-prev` copy.
- **Build-first**: only touches `/Applications/` after a successful
  `tauri:build`. A red build leaves the installed app untouched.
- **Login preserved**: bundle ID `ai.sgnk.md` doesn't change, so WKWebView
  cookies at `~/Library/WebKit/ai.sgnk.md/` survive the swap.

## Invocation

```bash
bash ~/.claude/skills/sgnk-md-update/scripts/update.sh
```

Optional flags:
- `--no-pull`         skip `git pull` (rebuild current checkout)
- `--no-install`      skip `npm install` even if `package.json` or `package-lock.json` changed
- `--skip-relaunch`   build + install, don't auto-launch
- `--dry-run`         show every step without executing

## When to use

After any of:
- pushing a new feature to `md` repo
- the user pulled changes elsewhere and wants the desktop app caught up
- editing `src-tauri/` (native menu, plugins, icons, bundle config)
- `sgnk-md.app` is misbehaving and you want a clean reinstall

## Not needed when

- you only changed **web** code that's already deployed to `md.sgnk.ai`.
  The running app pulls those automatically within 60 s. Use View → Reload
  (⌘R) to force immediate.
- you only touched `apps/skills-site` (separate Vercel project, irrelevant
  to the desktop app).

## Operator notes for Claude

- Always run the script — don't re-implement its steps inline.
- If the script exits non-zero, show the user the last 30 lines of output
  and offer to investigate. Do not retry blindly.
- If `git status` is dirty, stop and tell the user what's uncommitted. Do
  not auto-stash without consent.
- Bundle ID changes need a heads-up: if `src-tauri/tauri.conf.json` changed
  the `identifier`, mention that the user will lose GitHub OAuth on next
  launch and need to re-sign in.
- The swap into `/Applications` is the one irreversible-ish step: it `mv`s the
  current `sgnk-md.app` to `sgnk-md-prev.app` (overwriting any earlier `-prev`
  backup) and strips the Gatekeeper quarantine flag. The build-first +
  backup-not-delete design bounds the blast radius, but if the machine has a
  customized or signed install in `/Applications`, surface a one-line heads-up
  ("about to replace /Applications/sgnk-md.app; old copy goes to
  sgnk-md-prev.app") before running rather than swapping silently. Use
  `--dry-run` first to preview the exact swap when unsure.
