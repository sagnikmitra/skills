import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { getRegistry, groupByCategory, type RegistrySkill } from "../../../lib/registry";

const VALID = new Set(["claude", "codex", "antigravity", "manual"]);
const LABEL: Record<string, string> = {
  claude: "Claude",
  codex: "Codex",
  antigravity: "Antigravity",
  manual: "Manual",
};
const TAGLINE: Record<string, string> = {
  claude: "Skills + workflows scanned from ~/.claude/skills — invoked by the Claude Code CLI.",
  codex: "Skills + agent instructions scanned from ~/.codex/skills and ~/.codex/agents.",
  antigravity: "Skills imported from the Antigravity IDE workspace.",
  manual: "Manually authored skills under ./manual-skills.",
};

export async function generateStaticParams() {
  return [...VALID].map((source) => ({ source }));
}

export async function generateMetadata(
  { params }: { params: Promise<{ source: string }> }
): Promise<Metadata> {
  const { source } = await params;
  if (!VALID.has(source)) return { title: "Not found · sgnk skills" };
  const label = LABEL[source]!;
  return {
    title: `${label} skills · sgnk`,
    description: TAGLINE[source],
    alternates: { canonical: `/source/${source}` },
  };
}

export default async function SourcePage({ params }: { params: Promise<{ source: string }> }) {
  const { source } = await params;
  if (!VALID.has(source)) notFound();
  const reg = await getRegistry();
  const label = LABEL[source]!;
  const skills: RegistrySkill[] = reg.skills
    .filter((s) => s.status === "active")
    .filter((s) => s.sources.map((x) => x.toLowerCase()).includes(source));
  const grouped = groupByCategory(skills);

  return (
    <>
      <section className="hero">
        <div className="eyebrow"><span className={`dot dot-${source}`} />Source</div>
        <h1>{label}</h1>
        <p>{TAGLINE[source]}</p>
        <div className="stats">
          <div className="stat">
            <span className="stat-n" data-src={source}>{skills.length}</span>
            <span className="stat-l">skills</span>
          </div>
          <div className="stat">
            <span className="stat-n">{grouped.size}</span>
            <span className="stat-l">categories</span>
          </div>
        </div>
      </section>

      <div className="filter-bar">
        <Link href="/">All sources</Link>
        {[...VALID].map((s) => (
          <Link key={s} href={`/source/${s}`} className={s === source ? "active" : ""}>
            {LABEL[s]}
          </Link>
        ))}
      </div>

      {[...grouped.entries()].map(([category, items]) => (
        <section className="category-section" key={category}>
          <h2>
            {category}
            <span className="cat-count">· {items.length}</span>
          </h2>
          <div className="skill-grid">
            {items.map((s) => (
              <Link key={s.id} href={`/s/${s.slug}`} className="skill-card">
                <h3>{s.name}</h3>
                <p>{s.description}</p>
                <div className="meta">
                  {s.sources.map((src) => (
                    <span key={src} className={`badge badge-${src.toLowerCase()}`}>{src}</span>
                  ))}
                </div>
              </Link>
            ))}
          </div>
        </section>
      ))}

      {skills.length === 0 && (
        <p className="empty-state">
          No skills currently sourced from <strong>{label}</strong>.{" "}
          <Link href="/">All skills →</Link>
        </p>
      )}
    </>
  );
}

export const revalidate = 3600;
