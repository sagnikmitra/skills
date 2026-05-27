// Read the canonical registry + per-skill normalized files at request time.
// The site is intentionally simple: registry.json drives the catalog;
// skill.md / workflow.md are rendered as markdown on demand.

import fs from "node:fs/promises";
import path from "node:path";
import { cache } from "react";

// Content lives inside the app so Vercel ships it with the build.
// scripts/sync.mjs writes here on every sync.
const CONTENT_DIR = path.join(process.cwd(), "content");
const REGISTRY_PATH = path.join(CONTENT_DIR, "skills.registry.json");
const SKILLS_DIR = path.join(CONTENT_DIR, "skills");

export type RegistrySkill = {
  // Below mirrors the canonical registry shape produced by scripts/sync.mjs.
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

// React.cache memoizes within a single render pass — page + per-slug lookups
// no longer reread the registry file twice.
export const getRegistry = cache(async (): Promise<Registry> => {
  try {
    const raw = await fs.readFile(REGISTRY_PATH, "utf8");
    return JSON.parse(raw) as Registry;
  } catch {
    // Graceful fallback so a missing/corrupt registry returns 200 with empty,
    // not a 500 stack page.
    return { schemaVersion: 1, generatedAt: new Date().toISOString(), count: 0, skills: [] };
  }
});

export async function getSkillBySlug(slug: string): Promise<RegistrySkill | null> {
  const reg = await getRegistry();
  return reg.skills.find((s) => s.slug === slug) ?? null;
}

const SAFE_SLUG = /^[a-z0-9][a-z0-9-]{0,80}$/i;
const SAFE_FILE = new Set(["skill", "workflow"]);

export async function getSkillMarkdown(slug: string, file: "skill" | "workflow"): Promise<string> {
  // Defense-in-depth: route validation already filters via generateStaticParams,
  // but reject anything that could escape SKILLS_DIR.
  if (!SAFE_SLUG.test(slug) || !SAFE_FILE.has(file)) {
    return `_invalid skill reference_`;
  }
  const p = path.join(SKILLS_DIR, slug, `${file}.md`);
  // Verify resolved path is still inside SKILLS_DIR.
  const resolved = path.resolve(p);
  if (!resolved.startsWith(path.resolve(SKILLS_DIR) + path.sep)) {
    return `_invalid skill reference_`;
  }
  try {
    return await fs.readFile(resolved, "utf8");
  } catch {
    return `_${file}.md not found for ${slug}_`;
  }
}

/**
 * Derive a richer category from id/name/category. Registry only has 6 buckets
 * (115 in "General"); we re-bucket by id prefix / vendor namespace.
 */
export async function getRelatedSkills(
  slug: string,
  limit = 4,
): Promise<RegistrySkill[]> {
  const reg = await getRegistry();
  const target = reg.skills.find((s) => s.slug === slug);
  if (!target) return [];
  const cat = deriveCategory(target);
  return reg.skills
    .filter((s) => s.status === "active" && s.slug !== slug && deriveCategory(s) === cat)
    .sort((a, b) => new Date(b.lastUpdated).getTime() - new Date(a.lastUpdated).getTime())
    .slice(0, limit);
}

export function deriveCategory(s: RegistrySkill): string {
  const id = s.id.toLowerCase();
  const cat = s.category.toLowerCase();

  // sgnk first-party
  if (id.startsWith("sgnk-") || id === "gvc" || cat === "sgnk") return "sgnk";

  // Vendor / integration namespaces (plugin:foo or foo:bar)
  const nsMatch = id.match(/^(?:plugin[_:])?([a-z0-9-]+):/);
  if (nsMatch && nsMatch[1]) {
    const ns: string = nsMatch[1];
    const VENDOR_LABEL: Record<string, string> = {
      vercel: "Vercel",
      cloudflare: "Cloudflare",
      supabase: "Supabase",
      sentry: "Sentry",
      firecrawl: "Firecrawl",
      figma: "Figma",
      coderabbit: "CodeRabbit",
      codspeed: "CodSpeed",
      "anthropic-skills": "Anthropic Skills",
      superpowers: "Superpowers",
      "chrome-devtools-mcp": "Chrome DevTools",
      "claude-mem": "Claude Memory",
      "claude-md-management": "CLAUDE.md",
      "code-review": "Code Review",
      "pr-review-toolkit": "PR Review",
      "skill-creator": "Skill Creator",
      caveman: "Caveman",
      "frontend-design": "Frontend Design",
      "claude-code-setup": "Claude Setup",
    };
    if (VENDOR_LABEL[ns]) return VENDOR_LABEL[ns]!;
    return ns.charAt(0).toUpperCase() + ns.slice(1);
  }

  // Printing Press family
  if (id.startsWith("pp-") || id.startsWith("printing-press")) return "Printing Press";

  // Design / planning / review pipelines
  if (id.startsWith("plan-")) return "Planning";
  if (id.startsWith("design-") || id.startsWith("web-design")) return "Design";
  if (id.endsWith("-review") || id.endsWith("-revamp")) return "Review";

  // Investigation / debug
  if (["investigate", "verify", "debug", "qa", "qa-only", "retro"].includes(id)) return "Debug & QA";

  // Browser / automation
  if (["browse", "gstack", "canary", "open-gstack-browser", "connect-chrome", "setup-browser-cookies"].includes(id))
    return "Browser";

  // Deployment / shipping
  if (["ship", "land-and-deploy", "setup-deploy", "deploy-to-vercel", "vercel-cli-with-tokens"].includes(id))
    return "Deploy";

  // Docs / research
  if (["find-docs", "find-skills", "document-release", "market-researcher", "context7-cli", "context7-mcp"].includes(id))
    return "Docs & Research";

  // Safety / control
  if (["freeze", "unfreeze", "careful", "guard", "cso"].includes(id)) return "Safety";

  // Health / metrics
  if (["health", "benchmark", "score", "ux-revamp"].includes(id)) return "Health";

  // Honor original non-General category
  if (s.category && s.category !== "General") return s.category;

  return "General";
}

// Pinned section order; everything else alpha after.
const CATEGORY_ORDER = [
  "sgnk",
  "Printing Press",
  "Design",
  "Planning",
  "Review",
  "Vercel",
  "Cloudflare",
  "Supabase",
  "Sentry",
  "Firecrawl",
  "Figma",
  "Anthropic Skills",
  "Superpowers",
  "Chrome DevTools",
  "Claude Memory",
  "CLAUDE.md",
  "Code Review",
  "PR Review",
  "CodeRabbit",
  "CodSpeed",
  "Caveman",
  "Frontend Design",
  "Browser",
  "Deploy",
  "Debug & QA",
  "Docs & Research",
  "Safety",
  "Health",
  "Skill Creator",
  "General",
];

export function groupByCategory(skills: RegistrySkill[]): Map<string, RegistrySkill[]> {
  const map = new Map<string, RegistrySkill[]>();
  for (const s of skills) {
    const cat = deriveCategory(s);
    const arr = map.get(cat) ?? [];
    arr.push(s);
    map.set(cat, arr);
  }
  for (const arr of map.values()) arr.sort((a, b) => a.name.localeCompare(b.name));

  const rank = (c: string) => {
    const i = CATEGORY_ORDER.indexOf(c);
    return i === -1 ? 999 : i;
  };
  return new Map(
    [...map.entries()].sort(([a], [b]) => {
      const ra = rank(a);
      const rb = rank(b);
      if (ra !== rb) return ra - rb;
      return a.localeCompare(b);
    })
  );
}
