import Link from "next/link";
import { getRegistry, groupByCategory, type RegistrySkill } from "@/lib/registry";

type SP = { source?: string; q?: string };

export default async function HomePage({ searchParams }: { searchParams: Promise<SP> }) {
  const sp = await searchParams;
  const reg = await getRegistry();
  const source = sp.source?.toLowerCase();
  const q = sp.q?.toLowerCase();

  let skills: RegistrySkill[] = reg.skills.filter((s) => s.status === "active");
  if (source && source !== "all") skills = skills.filter((s) => s.sources.map((x) => x.toLowerCase()).includes(source));
  if (q) skills = skills.filter((s) => s.name.toLowerCase().includes(q) || s.description.toLowerCase().includes(q));

  const grouped = groupByCategory(skills);
  const sourceCounts = countBy(reg.skills, "sources");

  return (
    <>
      <section className="hero">
        <h1>Skills</h1>
        <p>
          Public catalog of skills, workflows, and agent instructions. Synced from
          Claude, Codex, and Antigravity into one canonical registry — mirrored
          to HQ, md.sgnk.ai, and Obsidian.
        </p>
        <div className="stats">
          <div className="stat"><span className="stat-n">{reg.count}</span><span className="stat-l">total skills</span></div>
          <div className="stat"><span className="stat-n">{sourceCounts.claude ?? 0}</span><span className="stat-l">Claude</span></div>
          <div className="stat"><span className="stat-n">{sourceCounts.codex ?? 0}</span><span className="stat-l">Codex</span></div>
          <div className="stat"><span className="stat-n">{sourceCounts.antigravity ?? 0}</span><span className="stat-l">Antigravity</span></div>
        </div>
      </section>

      <div className="filter-bar">
        <Link href="/" className={!source ? "active" : ""}>All ({reg.count})</Link>
        <Link href="/?source=claude" className={source === "claude" ? "active" : ""}>Claude</Link>
        <Link href="/?source=codex" className={source === "codex" ? "active" : ""}>Codex</Link>
        <Link href="/?source=antigravity" className={source === "antigravity" ? "active" : ""}>Antigravity</Link>
        <Link href="/?source=manual" className={source === "manual" ? "active" : ""}>Manual</Link>
      </div>

      {[...grouped.entries()].map(([category, items]) => (
        <section className="category-section" key={category}>
          <h2>{category} <span style={{ opacity: .5, fontWeight: 400 }}>· {items.length}</span></h2>
          <div className="skill-grid">
            {items.map((s) => (
              <Link key={s.id} href={`/s/${s.slug}`} className="skill-card">
                <h3>{s.name}</h3>
                <p>{s.description}</p>
                <div className="meta">
                  {s.sources.map((src) => <span key={src} className="badge">{src}</span>)}
                </div>
              </Link>
            ))}
          </div>
        </section>
      ))}

      {skills.length === 0 && <p style={{ color: "var(--muted)" }}>No skills match this filter.</p>}
    </>
  );
}

function countBy(skills: RegistrySkill[], key: "sources" | "category"): Record<string, number> {
  const out: Record<string, number> = {};
  for (const s of skills) {
    const vals = key === "sources" ? s.sources : [s.category];
    for (const v of vals) out[v.toLowerCase()] = (out[v.toLowerCase()] ?? 0) + 1;
  }
  return out;
}

// Static page-time data; revalidate hourly so a sync push appears within an hour.
export const revalidate = 3600;
