import Link from "next/link";
import { notFound } from "next/navigation";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { getRegistry, getSkillBySlug, getSkillMarkdown } from "@/lib/registry";

export async function generateStaticParams() {
  const reg = await getRegistry();
  return reg.skills.map((s) => ({ slug: s.slug }));
}

type SP = { tab?: "skill" | "workflow" };

export default async function SkillPage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<SP>;
}) {
  const { slug } = await params;
  const { tab = "skill" } = await searchParams;
  const skill = await getSkillBySlug(slug);
  if (!skill) notFound();

  const md = await getSkillMarkdown(slug, tab);

  return (
    <article className="skill-detail">
      <aside className="skill-side">
        <Link href="/">← All skills</Link>
        <h1 style={{ marginTop: ".75rem", fontSize: "1.25rem" }}>{skill.name}</h1>
        <div className="tabs">
          <Link href={`/s/${slug}?tab=skill`} className={tab === "skill" ? "active" : ""}>skill.md</Link>
          <Link href={`/s/${slug}?tab=workflow`} className={tab === "workflow" ? "active" : ""}>workflow.md</Link>
        </div>
        <dl>
          <dt>Category</dt><dd>{skill.category}</dd>
          <dt>Sources</dt><dd>{skill.sources.join(", ")}</dd>
          <dt>Last updated</dt><dd>{new Date(skill.lastUpdated).toLocaleDateString()}</dd>
          <dt>Status</dt><dd>{skill.status}</dd>
          <dt>Mirrored to</dt>
          <dd>
            HQ landing<br />
            HQ sidebar<br />
            md.sgnk.ai<br />
            Obsidian
          </dd>
        </dl>
      </aside>
      <section className="markdown">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{md}</ReactMarkdown>
      </section>
    </article>
  );
}

export const revalidate = 3600;
