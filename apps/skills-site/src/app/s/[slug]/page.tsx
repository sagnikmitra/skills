import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { getRegistry, getSkillBySlug, getSkillMarkdown, getRelatedSkills, deriveCategory } from "../../../lib/registry";
import { CopyLink } from "../../../components/copy-link";

const SITE = "https://skills.sgnk.ai";

export async function generateStaticParams() {
  const reg = await getRegistry();
  // Only build active skill pages — archived slugs would 404 anyway and waste build time.
  return reg.skills.filter((s) => s.status === "active").map((s) => ({ slug: s.slug }));
}

export async function generateMetadata(
  { params }: { params: Promise<{ slug: string }> }
): Promise<Metadata> {
  const { slug } = await params;
  const skill = await getSkillBySlug(slug);
  if (!skill) return { title: "Skill not found · sgnk" };
  const desc = skill.description.replace(/\s+/g, " ").slice(0, 200);
  return {
    title: `${skill.name} · sgnk skills`,
    description: desc,
    alternates: { canonical: `${SITE}/s/${skill.slug}` },
    openGraph: {
      type: "article",
      url: `${SITE}/s/${skill.slug}`,
      title: `${skill.name} · sgnk skills`,
      description: desc,
      siteName: "sgnk · skills",
    },
    twitter: { card: "summary_large_image", title: skill.name, description: desc },
  };
}

type SP = { tab?: string };

export default async function SkillPage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<SP>;
}) {
  const { slug } = await params;
  const { tab: rawTab } = await searchParams;
  // Strictly validate the tab; anything else collapses to "skill".
  const tab: "skill" | "workflow" = rawTab === "workflow" ? "workflow" : "skill";
  const skill = await getSkillBySlug(slug);
  if (!skill) notFound();

  const md = await getSkillMarkdown(slug, tab);
  const related = await getRelatedSkills(slug, 4);
  const category = deriveCategory(skill);
  const ghBase = "https://github.com/sagnikmitra/skills/blob/main/skills";
  const ghUrl = `${ghBase}/${skill.slug}/${tab}.md`;

  const ld = {
    "@context": "https://schema.org",
    "@type": "TechArticle",
    headline: skill.name,
    description: skill.description,
    inLanguage: "en",
    url: `${SITE}/s/${skill.slug}`,
    dateModified: skill.lastUpdated,
    author: { "@type": "Person", name: "Sagnik Mitra", url: "https://sgnk.ai" },
    keywords: [skill.category, ...skill.sources].join(", "),
  };

  return (
    <article className="skill-detail">
      <script type="application/ld+json" suppressHydrationWarning>
        {JSON.stringify(ld)}
      </script>
      <aside className="skill-side">
        <Link href="/">← All skills</Link>
        <h1 style={{ marginTop: ".75rem", fontSize: "1.25rem" }}>{skill.name}</h1>
        <div className="tabs" role="tablist" aria-label="Skill documents">
          <Link
            href={`/s/${slug}?tab=skill`}
            role="tab"
            aria-selected={tab === "skill"}
            className={tab === "skill" ? "active" : ""}
          >
            skill.md
          </Link>
          <Link
            href={`/s/${slug}?tab=workflow`}
            role="tab"
            aria-selected={tab === "workflow"}
            className={tab === "workflow" ? "active" : ""}
          >
            workflow.md
          </Link>
        </div>
        <dl>
          <dt>Category</dt>
          <dd>{category}</dd>
          <dt>Sources</dt>
          <dd>
            {skill.sources.map((src, i) => (
              <span key={src}>
                <Link href={`/source/${src.toLowerCase()}`}>{src}</Link>
                {i < skill.sources.length - 1 ? ", " : ""}
              </span>
            ))}
          </dd>
          <dt>Last updated</dt>
          <dd>
            <time dateTime={skill.lastUpdated}>
              {new Date(skill.lastUpdated).toLocaleDateString("en-US", {
                year: "numeric", month: "short", day: "numeric",
              })}
            </time>
          </dd>
          <dt>Status</dt><dd>{skill.status}</dd>
          <dt>Mirrored to</dt>
          <dd>
            HQ landing<br />
            HQ sidebar<br />
            md.sgnk.ai<br />
            Obsidian
          </dd>
        </dl>
        <div className="side-actions">
          <CopyLink path={`/s/${skill.slug}`} />
          <a
            href={ghUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="side-link"
            aria-label="View source on GitHub"
          >
            ⎘ Source ↗
          </a>
        </div>
      </aside>
      <section className="markdown">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{md}</ReactMarkdown>
        {related.length > 0 && (
          <aside className="related">
            <h2>Related in {category}</h2>
            <div className="related-grid">
              {related.map((r) => (
                <Link key={r.id} href={`/s/${r.slug}`} className="related-card">
                  <h3>{r.name}</h3>
                  <p>{r.description.slice(0, 140)}{r.description.length > 140 ? "…" : ""}</p>
                </Link>
              ))}
            </div>
          </aside>
        )}
      </section>
    </article>
  );
}

export const revalidate = 3600;
