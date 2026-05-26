#!/usr/bin/env node
/**
 * sync.mjs — the unified Skills Sync System.
 *
 * Zero-dependency Node script. Scans configured Claude / Codex / Antigravity
 * source folders, normalizes every skill into `{skill.md, workflow.md}`,
 * generates `skills.registry.json`, then fans out to every destination
 * (Obsidian vault, MD Project, HQ vault page, skills-site content). Handles
 * add / update / archive / conflict detection per skills-sync.config.json.
 *
 * Usage:
 *   node scripts/sync.mjs                # full sync
 *   node scripts/sync.mjs --dry          # report only, no writes
 *   node scripts/sync.mjs --only=claude  # restrict source
 *   node scripts/sync.mjs --verbose
 *
 * Exit codes:
 *   0  success (incl. dry-run)
 *   1  config / IO error
 *   2  conflicts detected (report written; manual resolution required)
 */
import {
  existsSync, readdirSync, readFileSync, writeFileSync, statSync,
  mkdirSync, rmSync, copyFileSync,
} from "node:fs";
import { dirname, join, basename, extname, resolve, relative } from "node:path";
import { homedir } from "node:os";
import { fileURLToPath } from "node:url";
import { createHash } from "node:crypto";

// ─── arg parsing ────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
const DRY = argv.includes("--dry");
const VERBOSE = argv.includes("--verbose") || argv.includes("-v");
const ONLY = (argv.find((a) => a.startsWith("--only=")) ?? "").split("=")[1];

// ─── load config ────────────────────────────────────────────────────────
const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const CONFIG_PATH = join(ROOT, "skills-sync.config.json");
if (!existsSync(CONFIG_PATH)) {
  console.error(`config not found: ${CONFIG_PATH}`);
  process.exit(1);
}
const config = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));

function expand(p) {
  if (!p) return p;
  if (p.startsWith("~")) return join(homedir(), p.slice(1));
  if (p.startsWith("./") || p.startsWith("../") || !p.startsWith("/")) return resolve(ROOT, p);
  return p;
}

// ─── utilities ──────────────────────────────────────────────────────────
function log(...args) { if (VERBOSE) console.log("·", ...args); }
function info(...args) { console.log(...args); }
function warn(...args) { console.warn("⚠", ...args); }

function ensureDir(p) {
  if (DRY) return;
  if (!existsSync(p)) mkdirSync(p, { recursive: true });
}

function writeFile(p, content) {
  if (DRY) { log("DRY write:", p); return; }
  ensureDir(dirname(p));
  writeFileSync(p, content);
}

function readSafe(p) {
  try { return readFileSync(p, "utf8"); } catch { return null; }
}

function sha256(s) {
  return createHash("sha256").update(s).digest("hex");
}

function slugify(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/-{2,}/g, "-");
}

function titleCase(slug) {
  return slug
    .split("-")
    .map((w) => w[0]?.toUpperCase() + w.slice(1))
    .join(" ");
}

function statMtime(p) {
  try { return statSync(p).mtime.toISOString(); } catch { return null; }
}

function parseFrontmatter(md) {
  if (!md || !md.startsWith("---")) return { frontmatter: {}, body: md ?? "" };
  const end = md.indexOf("\n---", 4);
  if (end === -1) return { frontmatter: {}, body: md };
  const fmRaw = md.slice(4, end).replace(/^\n/, "");
  const body = md.slice(end + 4).replace(/^\n+/, "");
  const frontmatter = {};
  const lines = fmRaw.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const m = line.match(/^([a-zA-Z_][\w-]*)\s*:\s*(.*)$/);
    if (!m) continue;
    let val = m[2].trim();
    // YAML block scalar (| or >): gather following indented lines.
    if (val === "|" || val === ">" || val === "|-" || val === ">-") {
      const block = [];
      const fold = val.startsWith(">");
      i++;
      while (i < lines.length && /^\s{2,}/.test(lines[i])) {
        block.push(lines[i].replace(/^\s{2}/, ""));
        i++;
      }
      i--; // step back so outer loop increments correctly
      val = fold ? block.join(" ").replace(/\s+/g, " ").trim() : block.join("\n").trim();
    } else if (val.startsWith("[") && val.endsWith("]")) {
      val = val.slice(1, -1).split(",").map((s) => s.trim().replace(/^["']|["']$/g, "")).filter(Boolean);
    } else if (val.startsWith('"') && val.endsWith('"')) {
      val = val.slice(1, -1);
    }
    frontmatter[m[1]] = val;
  }
  return { frontmatter, body };
}

function categoryFor(slug) {
  for (const rule of config.rules.categoryRules ?? []) {
    if (new RegExp(rule.pattern).test(slug)) return rule.category;
  }
  return "General";
}

// ─── scan a source ──────────────────────────────────────────────────────
function scanSkillFolderSource(source, sourceName) {
  const base = expand(source.path);
  if (!existsSync(base)) {
    if (!source.optional) warn(`source missing (not optional): ${base}`);
    else log(`skip optional source ${sourceName}: ${base}`);
    return [];
  }
  const skillFiles = source.skillFileNames ?? ["SKILL.md", "skill.md"];
  const workflowFiles = source.workflowFileNames ?? ["WORKFLOW.md", "WORKFLOW-MAP.md", "workflow.md"];

  const entries = readdirSync(base, { withFileTypes: true });
  const skills = [];

  for (const entry of entries) {
    // A skill is either:
    //   - a directory containing one of skillFileNames, OR
    //   - a sub-namespace ("plugin:skill") via colon-separated name
    if (!entry.isDirectory()) continue;
    const dir = join(base, entry.name);

    // Detect namespaced sub-skills (one level deep)
    const sub = readdirSync(dir, { withFileTypes: true });
    const subSkillDirs = sub.filter((s) => s.isDirectory() && skillFiles.some((f) => existsSync(join(dir, s.name, f))));

    if (subSkillDirs.length > 0) {
      for (const ss of subSkillDirs) {
        skills.push(buildScanRecord({
          sourceName,
          rootDir: join(dir, ss.name),
          slug: slugify(`${entry.name}-${ss.name}`),
          rawName: `${entry.name}:${ss.name}`,
          skillFiles, workflowFiles,
        }));
      }
      // Also keep the parent if it has its own SKILL.md
      if (skillFiles.some((f) => existsSync(join(dir, f)))) {
        skills.push(buildScanRecord({ sourceName, rootDir: dir, slug: slugify(entry.name), rawName: entry.name, skillFiles, workflowFiles }));
      }
      continue;
    }

    if (skillFiles.some((f) => existsSync(join(dir, f)))) {
      skills.push(buildScanRecord({ sourceName, rootDir: dir, slug: slugify(entry.name), rawName: entry.name, skillFiles, workflowFiles }));
    } else {
      log(`no SKILL.md in ${dir} — skipped`);
    }
  }
  return skills;
}

function buildScanRecord({ sourceName, rootDir, slug, rawName, skillFiles, workflowFiles }) {
  const skillFile = skillFiles.map((f) => join(rootDir, f)).find(existsSync) ?? null;
  const workflowFile = workflowFiles.map((f) => join(rootDir, f)).find(existsSync) ?? null;
  return {
    sourceName,
    rootDir,
    slug,
    rawName,
    skillFile,
    workflowFile,
    mtime: statMtime(skillFile) ?? statMtime(rootDir),
  };
}

function scanAgentFolderSource(source, sourceName) {
  // Lightweight: every file matching matchFiles becomes a skill named after its parent dir.
  const base = expand(source.path);
  if (!existsSync(base)) {
    if (!source.optional) warn(`source missing (not optional): ${base}`);
    return [];
  }
  const matchers = (source.matchFiles ?? ["AGENTS.md"]).map((p) => new RegExp("^" + p.replace(/\*/g, ".*") + "$", "i"));
  const out = [];
  function walk(dir) {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, e.name);
      if (e.isDirectory()) walk(full);
      else if (matchers.some((re) => re.test(e.name))) {
        const slug = slugify(`${sourceName}-${basename(dir)}-${e.name.replace(/\.md$/i, "")}`);
        out.push({
          sourceName, rootDir: dir, slug,
          rawName: `${basename(dir)}/${e.name}`,
          skillFile: full, workflowFile: null,
          mtime: statMtime(full),
        });
      }
    }
  }
  walk(base);
  return out;
}

// ─── normalize one skill ────────────────────────────────────────────────
function normalize(scan) {
  const skillRaw = scan.skillFile ? readFileSync(scan.skillFile, "utf8") : "";
  const wfRaw = scan.workflowFile ? readFileSync(scan.workflowFile, "utf8") : "";
  const { frontmatter: skillFm, body: skillBody } = parseFrontmatter(skillRaw);
  const { body: wfBody } = parseFrontmatter(wfRaw);

  const name = skillFm.name ?? scan.rawName ?? scan.slug;
  const description = skillFm.description ?? extractFirstParagraph(skillBody) ?? `${titleCase(scan.slug)} skill.`;
  const category = categoryFor(scan.slug);
  const inferredCapabilities = extractListUnder(skillBody, ["Capabilities", "Features", "What it does"]) ?? [];

  // Normalized skill.md
  const normalizedSkill = renderSkillMd({
    name, description, category, scan, capabilities: inferredCapabilities, body: skillBody,
  });

  // Normalized workflow.md (use existing if present; otherwise stub a sensible default)
  const normalizedWorkflow = renderWorkflowMd({ name, scan, body: wfBody, fallbackFromSkillBody: skillBody });

  return {
    slug: scan.slug,
    name,
    description,
    category,
    source: scan.sourceName,
    sources: [scan.sourceName],
    skillMd: normalizedSkill,
    workflowMd: normalizedWorkflow,
    skillHash: sha256(normalizedSkill),
    workflowHash: sha256(normalizedWorkflow),
    lastUpdated: scan.mtime ?? new Date().toISOString(),
    rawSkillPath: scan.skillFile,
    rawWorkflowPath: scan.workflowFile,
  };
}

function extractFirstParagraph(md) {
  if (!md) return null;
  const lines = md.split("\n").filter((l) => l.trim() && !l.startsWith("#"));
  return lines[0]?.trim().slice(0, 280) ?? null;
}

function extractListUnder(md, headings) {
  if (!md) return null;
  for (const h of headings) {
    const re = new RegExp(`^#{1,6}\\s+${h}\\b.*$`, "im");
    const m = md.match(re);
    if (!m) continue;
    const start = md.indexOf(m[0]) + m[0].length;
    const rest = md.slice(start);
    const stop = rest.search(/^#{1,6}\s+/m);
    const block = stop === -1 ? rest : rest.slice(0, stop);
    const items = [...block.matchAll(/^\s*[-*]\s+(.+)$/gm)].map((mm) => mm[1].trim());
    if (items.length) return items;
  }
  return null;
}

function renderSkillMd({ name, description, category, scan, capabilities, body }) {
  const cap = capabilities.length
    ? capabilities.map((c) => `- ${c}`).join("\n")
    : "- See original source for capabilities.";
  return `# ${titleCase(scan.slug)}

## Purpose

${description}

## Description

${(body || description).trim()}

## Source

${capitalize(scan.sourceName)}

## Capabilities

${cap}

## Inputs

Inputs depend on the skill's trigger and arguments. See the source SKILL.md.

## Outputs

Outputs depend on the skill. Typical: files written, reports generated, agent actions performed.

## When To Use

When the user invokes \`/${scan.slug}\` or describes a task the skill's description matches.

## Dependencies

See the source skill's references and scripts folders.

## Related Systems

- Claude (if synced from \`~/.claude/skills/${scan.slug}\`)
- HQ Project — landing page Skills section
- MD Project (md.sgnk.ai) — \`Skills/${titleCase(scan.slug)}/\`
- Obsidian Vault — \`Skills/${titleCase(scan.slug)}/\`

## Examples

See workflow.md.

---

_Source: ${scan.skillFile ? relativeFromHome(scan.skillFile) : "(none)"}_
_Category: ${category}_
`;
}

function renderWorkflowMd({ name, scan, body, fallbackFromSkillBody }) {
  const baseBody = body && body.trim().length > 40
    ? body.trim()
    : (fallbackFromSkillBody || "(no workflow content yet — see source skill)").trim();
  return `# ${titleCase(scan.slug)} — Workflow

## Overview

How the \`${scan.slug}\` skill works, step by step.

## Source Workflow

${capitalize(scan.sourceName)} skill workflow.

## Step-by-step Workflow

${baseBody}

## Execution Logic

The skill executes when its trigger fires (slash command, natural-language match, or direct invocation). It reads its references, applies its rules, and produces the documented outputs.

## Edge Cases

See the source skill's \`references/\` and \`scripts/\` folders for edge-case handling.

## Failure Handling

A skill failure surfaces as a tool error or a partial output; never a silent skip. Re-run with \`--verbose\` (where applicable) for diagnostics.

## Integration Notes

- Claude — invoked via the \`Skill\` tool with \`skill: "${scan.slug}"\`.
- Codex — referenced from \`AGENTS.md\` if mirrored.
- Antigravity — referenced from the workspace agent rules if mirrored.
- HQ Project — listed on the landing page Skills section + post-login sidebar.
- MD Project (md.sgnk.ai) — file rendered from \`Skills/${titleCase(scan.slug)}/workflow.md\`.
- Obsidian — file rendered with frontmatter + tags.

## Usage Examples

Invoke via slash command or natural language matching the skill description.

---

_Source: ${scan.workflowFile ? relativeFromHome(scan.workflowFile) : "(none)"}_
`;
}

function capitalize(s) { return s ? s[0].toUpperCase() + s.slice(1) : s; }
function relativeFromHome(p) {
  const h = homedir();
  return p.startsWith(h) ? "~" + p.slice(h.length) : p;
}

// ─── dedup + merge across sources ───────────────────────────────────────
function mergeBySlug(normalizedList) {
  const map = new Map();
  for (const n of normalizedList) {
    const prev = map.get(n.slug);
    if (!prev) { map.set(n.slug, n); continue; }
    // Same slug seen in multiple sources → merge sources list
    prev.sources = Array.from(new Set([...prev.sources, ...n.sources]));
    // Keep most recently updated content
    if (new Date(n.lastUpdated) > new Date(prev.lastUpdated)) {
      prev.skillMd = n.skillMd;
      prev.workflowMd = n.workflowMd;
      prev.skillHash = n.skillHash;
      prev.workflowHash = n.workflowHash;
      prev.lastUpdated = n.lastUpdated;
      prev.rawSkillPath = n.rawSkillPath;
      prev.rawWorkflowPath = n.rawWorkflowPath;
    }
  }
  return [...map.values()].sort((a, b) => a.slug.localeCompare(b.slug));
}

// ─── conflict detection vs prior registry ───────────────────────────────
function detectConflicts(newSkills, priorRegistry) {
  const prior = new Map((priorRegistry?.skills ?? []).map((s) => [s.id, s]));
  const conflicts = [];
  const reg = config.rules.conflictReportPath ?? "./reports/conflicts";

  for (const dest of [config.destinations.obsidian, config.destinations.mdProject, config.destinations.hqVault]) {
    if (!dest) continue;
    const destBase = expand(dest.path);
    for (const skill of newSkills) {
      const destSkill = join(destBase, titleCase(skill.slug), "skill.md");
      const destWf = join(destBase, titleCase(skill.slug), "workflow.md");
      const priorRec = prior.get(skill.slug);
      if (!priorRec) continue;
      const liveSkill = readSafe(destSkill);
      const liveWf = readSafe(destWf);
      // Strip any frontmatter we wrote so hash matches the normalized body.
      const stripFm = (s) => s ? (parseFrontmatter(s).body) : s;
      const liveSkillHash = liveSkill ? sha256(stripFm(liveSkill)) : null;
      const liveWfHash = liveWf ? sha256(stripFm(liveWf)) : null;
      if (liveSkillHash && liveSkillHash !== priorRec.hashes?.skill) {
        conflicts.push({ slug: skill.slug, dest: destSkill, kind: "destination-modified", priorHash: priorRec.hashes?.skill, currentHash: liveSkillHash });
      }
      if (liveWfHash && liveWfHash !== priorRec.hashes?.workflow) {
        conflicts.push({ slug: skill.slug, dest: destWf, kind: "destination-modified", priorHash: priorRec.hashes?.workflow, currentHash: liveWfHash });
      }
    }
  }
  return conflicts;
}

function writeConflictReport(conflicts) {
  if (!conflicts.length) return null;
  const dir = expand(config.rules.conflictReportPath ?? "./reports/conflicts");
  ensureDir(dir);
  const file = join(dir, `conflict-${new Date().toISOString().replace(/[:.]/g, "-")}.json`);
  writeFile(file, JSON.stringify({ count: conflicts.length, conflicts }, null, 2));
  return file;
}

// ─── archive removed skills ─────────────────────────────────────────────
function archiveRemoved(newSlugs, priorRegistry) {
  if (!priorRegistry || !config.rules.archiveOnRemoval) return [];
  const archived = [];
  const prior = priorRegistry.skills ?? [];
  const present = new Set(newSlugs);
  const archiveFolder = config.rules.archiveFolder ?? "_Archived";

  for (const old of prior) {
    if (present.has(old.id)) continue;
    for (const destKey of ["obsidian", "mdProject", "hqVault"]) {
      const dest = config.destinations[destKey];
      if (!dest) continue;
      const destBase = expand(dest.path);
      const liveDir = join(destBase, titleCase(old.id));
      if (!existsSync(liveDir)) continue;
      const archDir = join(destBase, archiveFolder, titleCase(old.id));
      ensureDir(archDir);
      if (!DRY) {
        for (const f of ["skill.md", "workflow.md"]) {
          const src = join(liveDir, f);
          if (existsSync(src)) copyFileSync(src, join(archDir, f));
        }
        rmSync(liveDir, { recursive: true, force: true });
      }
      archived.push({ slug: old.id, destKey, from: liveDir, to: archDir });
    }
  }
  return archived;
}

// ─── write a normalized skill to all destinations ───────────────────────
function writeSkillToDestinations(skill) {
  // Canonical (in registry repo)
  const canonicalDir = join(expand(config.destinations.registry.normalized), skill.slug);
  writeFile(join(canonicalDir, "skill.md"), skill.skillMd);
  writeFile(join(canonicalDir, "workflow.md"), skill.workflowMd);

  // Destinations with TitleCase folders
  const titleName = titleCase(skill.slug);
  for (const destKey of ["obsidian", "mdProject", "hqVault"]) {
    const dest = config.destinations[destKey];
    if (!dest || !dest.path) continue;
    if (destKey === "mdProject" && config.destinations.obsidian?.path === dest.path) continue; // dedupe identical paths
    const dir = join(expand(dest.path), titleName);
    const skillBody = dest.writeFrontmatter
      ? withFrontmatter(skill, dest.tags ?? ["skills"], "skill") + skill.skillMd
      : skill.skillMd;
    const wfBody = dest.writeFrontmatter
      ? withFrontmatter(skill, dest.tags ?? ["skills"], "workflow") + skill.workflowMd
      : skill.workflowMd;
    writeFile(join(dir, "skill.md"), skillBody);
    writeFile(join(dir, "workflow.md"), wfBody);
  }

  // Skills-site content (no frontmatter rewrite; raw normalized)
  if (config.destinations.skillsSite?.path) {
    const dir = join(expand(config.destinations.skillsSite.path), skill.slug);
    writeFile(join(dir, "skill.md"), skill.skillMd);
    writeFile(join(dir, "workflow.md"), skill.workflowMd);
  }
}

function withFrontmatter(skill, tags, kind) {
  const t = Array.from(new Set([...(tags ?? []), ...skill.sources.map((s) => s.toLowerCase())]));
  return `---
title: ${titleCase(skill.slug)}
type: ${kind === "workflow" ? "workflow" : "skill"}
slug: ${skill.slug}
source: ${skill.source}
sources: [${skill.sources.join(", ")}]
category: ${skill.category}
status: active
last_synced: ${new Date().toISOString().slice(0, 10)}
tags: [${t.join(", ")}]
---

`;
}

// ─── build registry ─────────────────────────────────────────────────────
function buildRegistry(skills) {
  return {
    schemaVersion: 1,
    generatedAt: new Date().toISOString(),
    count: skills.length,
    skills: skills.map((s) => ({
      id: s.slug,
      name: titleCase(s.slug),
      slug: s.slug,
      description: s.description,
      category: s.category,
      sources: s.sources,
      primarySource: s.source,
      skillPath: `skills/${s.slug}/skill.md`,
      workflowPath: `skills/${s.slug}/workflow.md`,
      hqPublic: true,
      hqSidebar: true,
      mdProject: true,
      obsidian: true,
      lastUpdated: s.lastUpdated,
      status: "active",
      hashes: { skill: s.skillHash, workflow: s.workflowHash },
    })),
  };
}

// ─── main ───────────────────────────────────────────────────────────────
async function main() {
  info(`Skills Sync — ${DRY ? "DRY RUN" : "WRITE"} mode${ONLY ? ` (only=${ONLY})` : ""}`);
  const scans = [];
  for (const [sourceName, sources] of Object.entries(config.sources)) {
    if (ONLY && ONLY !== sourceName) continue;
    for (const src of sources) {
      const list = src.kind === "agent-folder"
        ? scanAgentFolderSource(src, sourceName)
        : scanSkillFolderSource(src, sourceName);
      info(`  scanned ${sourceName} (${src.path}) → ${list.length} skills`);
      scans.push(...list);
    }
  }

  if (!scans.length) {
    warn("No skills discovered. Check config paths.");
    process.exit(0);
  }

  // Apply exclude filter
  const excludeSet = new Set(config.rules.excludeSlugs ?? []);
  const filtered = scans.filter((s) => !excludeSet.has(s.slug));

  const normalized = filtered.map(normalize);
  const merged = mergeBySlug(normalized);
  info(`  normalized → ${merged.length} unique skills`);

  // Load prior registry for conflict + archive
  const regPath = expand(config.destinations.registry.path);
  const prior = existsSync(regPath) ? JSON.parse(readFileSync(regPath, "utf8")) : null;

  const conflicts = detectConflicts(merged, prior);
  if (conflicts.length) {
    const reportFile = writeConflictReport(conflicts);
    warn(`${conflicts.length} conflict(s) detected. Report: ${reportFile}`);
  }

  const archived = archiveRemoved(merged.map((s) => s.slug), prior);
  if (archived.length) info(`  archived ${archived.length} removed skill(s)`);

  for (const skill of merged) writeSkillToDestinations(skill);

  const registry = buildRegistry(merged);
  writeFile(regPath, JSON.stringify(registry, null, 2));

  // Mirror the registry inside the skills-site content folder so the Next app
  // can read it at build time without crossing rootDirectory.
  if (config.destinations.skillsSite?.path) {
    const mirror = join(dirname(expand(config.destinations.skillsSite.path)), "skills.registry.json");
    writeFile(mirror, JSON.stringify(registry, null, 2));
  }

  // Regenerate the HQ + vault Index.md MOC pages after sync.
  if (!DRY) {
    try {
      const { spawnSync } = await import("node:child_process");
      const r = spawnSync(process.execPath, [join(ROOT, "scripts", "generate-hq-index.mjs")], { stdio: "inherit" });
      if (r.status !== 0) warn("generate-hq-index.mjs exited with status " + r.status);
    } catch (e) {
      warn("could not run generate-hq-index.mjs: " + (e?.message ?? e));
    }
  }

  info(`✅ Sync complete. ${merged.length} skills → registry @ ${relativeFromHome(regPath)}`);
  for (const destKey of ["obsidian", "mdProject", "hqVault", "skillsSite"]) {
    const d = config.destinations[destKey];
    if (d?.path) info(`   ${destKey.padEnd(12)} → ${relativeFromHome(expand(d.path))}`);
  }

  if (conflicts.length) process.exit(2);
}

main();
