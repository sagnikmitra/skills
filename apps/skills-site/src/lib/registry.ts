// Read the canonical registry + per-skill normalized files at request time.
// The site is intentionally simple: registry.json drives the catalog;
// skill.md / workflow.md are rendered as markdown on demand.

import fs from "node:fs/promises";
import path from "node:path";

// Content lives inside the app so Vercel ships it with the build.
// scripts/sync.mjs writes here on every sync.
const CONTENT_DIR = path.join(process.cwd(), "content");
const REGISTRY_PATH = path.join(CONTENT_DIR, "skills.registry.json");
const SKILLS_DIR = path.join(CONTENT_DIR, "skills");

export type RegistrySkill = {
  id: string;
  name: string;
  slug: string;
  description: string;
  category: string;
  sources: string[];
  primarySource: string;
  skillPath: string;
  workflowPath: string;
  hqPublic: boolean;
  hqSidebar: boolean;
  mdProject: boolean;
  obsidian: boolean;
  lastUpdated: string;
  status: "active" | "archived";
};

export type Registry = {
  schemaVersion: number;
  generatedAt: string;
  count: number;
  skills: RegistrySkill[];
};

export async function getRegistry(): Promise<Registry> {
  const raw = await fs.readFile(REGISTRY_PATH, "utf8");
  return JSON.parse(raw) as Registry;
}

export async function getSkillBySlug(slug: string): Promise<RegistrySkill | null> {
  const reg = await getRegistry();
  return reg.skills.find((s) => s.slug === slug) ?? null;
}

export async function getSkillMarkdown(slug: string, file: "skill" | "workflow"): Promise<string> {
  const p = path.join(SKILLS_DIR, slug, `${file}.md`);
  try {
    return await fs.readFile(p, "utf8");
  } catch {
    return `_${file}.md not found for ${slug}_`;
  }
}

export function groupByCategory(skills: RegistrySkill[]): Map<string, RegistrySkill[]> {
  const map = new Map<string, RegistrySkill[]>();
  for (const s of skills) {
    const arr = map.get(s.category) ?? [];
    arr.push(s);
    map.set(s.category, arr);
  }
  for (const arr of map.values()) arr.sort((a, b) => a.name.localeCompare(b.name));
  return new Map([...map.entries()].sort(([a], [b]) => a.localeCompare(b)));
}
