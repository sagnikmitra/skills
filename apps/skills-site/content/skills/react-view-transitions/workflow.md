# React View Transitions — Workflow

## Overview

How the `react-view-transitions` skill works, step by step.

## Source Workflow

Claude skill workflow.

## Step-by-step Workflow

# vercel-react-view-transitions — Workflow

> Auto-generated from `SKILL.md`. The skill itself is the source of truth;
> this is a human-readable map of what it does and how it runs.

## What it does & when to use

Guide for implementing smooth, native-feeling animations using React's View Transition API (`<ViewTransition>` component, `addTransitionType`, and CSS view transition pseudo-elements). Use this skill whenever the user wants to add page transitions, animate route changes, create shared element animations, animate enter/exit of components, animate list reorder, implement directional (forward/back) navigation animations, or integrate view transitions in Next.js. Also use when the user mentions view transitions, `startViewTransition`, `ViewTransition`, transition types, or asks about animating between UI states in React without third-party animation libraries.

## How it works

Workflow outline (sections of `SKILL.md`):

1. When to Animate
2. Availability
3. Implementation Workflow
4. Core Concepts
5. Styling with View Transition Classes
6. Transition Types
7. Shared Element Transitions
8. Common Patterns
9. How Multiple VTs Interact
10. Next.js Integration
11. Accessibility
12. Reference Files
13. Full Compiled Document

## Components

- `references/` (4): css-recipes.md, implementation.md, nextjs.md, patterns.md

## Invoke

- Slash: `/vercel-react-view-transitions`
- Or a natural-language request matching the triggers above.

---
_Source: `SKILL.md` in this directory._

## Execution Logic

The skill executes when its trigger fires (slash command, natural-language match, or direct invocation). It reads its references, applies its rules, and produces the documented outputs.

## Edge Cases

See the source skill's `references/` and `scripts/` folders for edge-case handling.

## Failure Handling

A skill failure surfaces as a tool error or a partial output; never a silent skip. Re-run with `--verbose` (where applicable) for diagnostics.

## Integration Notes

- Claude — invoked via the `Skill` tool with `skill: "react-view-transitions"`.
- Codex — referenced from `AGENTS.md` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from `Skills/React View Transitions/workflow.md`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ~/.claude/skills/react-view-transitions/WORKFLOW.md_
