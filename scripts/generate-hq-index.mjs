#!/usr/bin/env node
/**
 * generate-hq-index.mjs — write the HQ-side Index.md MOC pages.
 *
 * Reads skills.registry.json and emits:
 *   - <hqVault>/Index.md            (HQ-scoped index, links to local copies)
 *   - <obsidian>/Index.md           (vault-wide skills index)
 *
 * Idempotent. Run from sync.mjs or directly:
 *   node scripts/generate-hq-index.mjs
 */
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { homedir } from "node:os";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const config = JSON.parse(readFileSync(join(ROOT, "skills-sync.config.json"), "utf8"));
const expand = (p) => p?.startsWith("~") ? join(homedir(), p.slice(1)) : (p?.startsWith("/") ? p : resolve(ROOT, p));

const registry = JSON.parse(readFileSync(join(ROOT, "skills.registry.json"), "utf8"));
const titleCase = (slug) => slug.split("-").map((w) => w[0]?.toUpperCase() + w.slice(1)).join(" ");

function groupByCategory(skills) {
  const m = new Map();
  for (const s of skills) {
    if (!m.has(s.category)) m.set(s.category, []);
    m.get(s.category).push(s);
  }
  for (const arr of m.values()) arr.sort((a, b) => a.name.localeCompare(b.name));
  return new Map([...m.entries()].sort(([a], [b]) => a.localeCompare(b)));
}

function renderIndex(scope, skills) {
  const grouped = groupByCategory(skills);
  const today = new Date().toISOString().slice(0, 10);
  const totalsBySource = skills.reduce((acc, s) => {
    for (const src of s.sources) acc[src] = (acc[src] ?? 0) + 1;
    return acc;
  }, {});

  let out = `---
title: Skills Index
type: skills-index
scope: ${scope}
generated: ${today}
total: ${skills.length}
tags: [skills, moc${scope === "hq" ? ", hq" : ""}]
---

# Skills Index ${scope === "hq" ? "— HQ" : "— Vault"}

> Auto-generated from \`skills.registry.json\`. Do not edit by hand — edits will be overwritten on next sync.
> **Sync:** \`cd ~/Desktop/GitHub/skills-registry && npm run sync\`
> **Public catalog:** [skills.sgnk.ai](https://skills.sgnk.ai)

## Totals

- **Total:** ${skills.length} skills
${Object.entries(totalsBySource).sort(([a], [b]) => a.localeCompare(b)).map(([k, v]) => `- **${k[0].toUpperCase() + k.slice(1)}:** ${v}`).join("\n")}

## Filter by source

- [Claude only](#claude) · [Codex only](#codex) · [Antigravity only](#antigravity) · [All](#all)

`;

  for (const [category, items] of grouped) {
    out += `\n## ${category} <small>(${items.length})</small>\n\n`;
    for (const s of items) {
      const title = titleCase(s.slug);
      out += `- [[${title}/skill|${title}]] — ${s.description.replace(/\n/g, " ").slice(0, 140)}  \n`;
      out += `  <sub>sources: ${s.sources.join(", ")} · [workflow]([[${title}/workflow]]) · [public](https://skills.sgnk.ai/s/${s.slug})</sub>\n`;
    }
  }

  out += `\n---\n\n_Generated ${today} · ${skills.length} skills · registry schema v${registry.schemaVersion}_\n`;
  return out;
}

function writeIfChanged(p, content) {
  mkdirSync(dirname(p), { recursive: true });
  if (existsSync(p) && readFileSync(p, "utf8") === content) return false;
  writeFileSync(p, content);
  return true;
}

const dests = [];
if (config.destinations.hqVault?.path) {
  const p = join(expand(config.destinations.hqVault.path), "Index.md");
  if (writeIfChanged(p, renderIndex("hq", registry.skills))) dests.push(p);
}
if (config.destinations.obsidian?.path) {
  const p = join(expand(config.destinations.obsidian.path), "Index.md");
  if (writeIfChanged(p, renderIndex("vault", registry.skills))) dests.push(p);
}

console.log(`HQ/vault Skills Index written → ${dests.length} file(s):`);
for (const d of dests) console.log("  ·", d);
