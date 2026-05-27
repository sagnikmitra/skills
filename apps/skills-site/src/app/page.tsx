import Link from "next/link";
import { getRegistry, groupByCategory, type RegistrySkill } from "../lib/registry";

type SP = { source?: string; q?: string };

export default async function HomePage({ searchParams }: { searchParams: Promise<SP> }) {
  const sp = await searchParams;
  const reg = await getRegistry();
  const source = sp.source?.toLowerCase();
  const q = sp.q?.trim().toLowerCase() ?? "";

  let skills: RegistrySkill[] = reg.skills.filter((s) => s.status === "active");
  if (source && source !== "all") {
    skills = skills.filter((s) => s.sources.map((x) => x.toLowerCase()).includes(source));
  }
  if (q) {
    skills = skills.filter(
      (s) =>
        s.name.toLowerCase().includes(q) ||
        s.id.toLowerCase().includes(q) ||
        s.description.toLowerCase().includes(q),
    );
  }

  const grouped = groupByCategory(skills);
  const sourceCounts = countBy(reg.skills, "sources");
  const preserveSource = source && source !== "all" ? `&source=${source}` : "";

  return (
    <>
      <section className="hero">
        <div className="eyebrow">Skills registry</div>
        <h1>Skills</h1>
        <p>
          Public catalog of skills, workflows, and agent instructions. Synced from
          Claude, Codex, and Antigravity into one canonical registry — mirrored
          to HQ, md.sgnk.ai, and Obsidian.
        </p>
        <div className="stats">
          <div className="stat"><span className="stat-n">{reg.count}</span><span className="stat-l">total skills</span></div>
          <div className="stat"><span className="stat-n" data-src="claude">{sourceCounts.claude ?? 0}</span><span className="stat-l"><span className="dot dot-claude" />Claude</span></div>
          <div className="stat"><span className="stat-n" data-src="codex">{sourceCounts.codex ?? 0}</span><span className="stat-l"><span className="dot dot-codex" />Codex</span></div>
          <div className="stat"><span className="stat-n" data-src="antigravity">{sourceCounts.antigravity ?? 0}</span><span className="stat-l"><span className="dot dot-antigravity" />Antigravity</span></div>
        </div>
      </section>

      <form className="search-bar" action="/" method="GET" role="search">
        <span className="search-icon" aria-hidden>⌕</span>
        <input
          type="search"
          name="q"
          defaultValue={q}
          placeholder="Search skills by name, id, or description…"
          autoComplete="off"
          aria-label="Search skills"
        />
        {source && source !== "all" && <input type="hidden" name="source" value={source} />}
        {q && (
          <Link href={`/${source ? `?source=${source}` : ""}`} className="search-clear" aria-label="Clear search">
            ×
          </Link>
        )}
      </form>

      <div className="filter-bar">
        <Link href={q ? `/?q=${encodeURIComponent(q)}` : "/"} className={!source ? "active" : ""}>All ({reg.count})</Link>
        <Link href={`/?source=claude${q ? `&q=${encodeURIComponent(q)}` : ""}`} className={source === "claude" ? "active" : ""}>Claude</Link>
        <Link href={`/?source=codex${q ? `&q=${encodeURIComponent(q)}` : ""}`} className={source === "codex" ? "active" : ""}>Codex</Link>
        <Link href={`/?source=antigravity${q ? `&q=${encodeURIComponent(q)}` : ""}`} className={source === "antigravity" ? "active" : ""}>Antigravity</Link>
        <Link href={`/?source=manual${q ? `&q=${encodeURIComponent(q)}` : ""}`} className={source === "manual" ? "active" : ""}>Manual</Link>
      </div>

      {q && (
        <p className="result-count">
          {skills.length} {skills.length === 1 ? "result" : "results"} for <strong>{q}</strong>
          {preserveSource && <> in <em>{source}</em></>}
        </p>
      )}

      {[...grouped.entries()].map(([category, items]) => {
        const isSgnk = category === "sgnk";
        return (
          <section
            className={`category-section${isSgnk ? " category-featured" : ""}`}
            key={category}
            style={{ ["--cat" as string]: categoryHue(category) }}
          >
            <h2>
              <span className="cat-dot" style={{ background: categoryHue(category) }} />
              {isSgnk ? "sgnk · first-party" : category}
              <span className="cat-count">· {items.length}</span>
            </h2>
            <div className="skill-grid">
              {items.map((s) => (
                <Link
                  key={s.id}
                  href={`/s/${s.slug}`}
                  className="skill-card"
                  style={{ ["--cat" as string]: categoryHue(category) }}
                >
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
        );
      })}

      {skills.length === 0 && (
        <p className="empty-state">
          No skills match <strong>{q || "this filter"}</strong>.{" "}
          <Link href="/">Clear filters →</Link>
        </p>
      )}
    </>
  );
}

// Stable per-category hue — derived from name so order doesn't shift palette.
const CAT_PALETTE = [
  "#d97757", // Claude coral (primary)
  "#c8967a", // warm tan
  "#4cb782", // mint
  "#e0a23a", // amber
  "#c97cd6", // orchid
  "#5aa9e6", // sky
  "#e07a7a", // coral-pink
  "#8ad0b8", // sage
];
function categoryHue(cat: string): string {
  // sgnk always gets coral
  if (cat === "sgnk") return "#d97757";
  let h = 0;
  for (let i = 0; i < cat.length; i++) h = (h * 31 + cat.charCodeAt(i)) >>> 0;
  return CAT_PALETTE[h % CAT_PALETTE.length]!;
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
