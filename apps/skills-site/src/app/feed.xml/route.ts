import { getRegistry } from "../../lib/registry";

const SITE = "https://skills.sgnk.ai";
export const revalidate = 3600;

function escape(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

export async function GET() {
  const reg = await getRegistry();
  // 50 most-recently-updated active skills.
  const items = reg.skills
    .filter((s) => s.status === "active")
    .sort((a, b) => new Date(b.lastUpdated).getTime() - new Date(a.lastUpdated).getTime())
    .slice(0, 50);

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>sgnk · skills</title>
    <link>${SITE}</link>
    <description>Recently updated skills, workflows, and agent instructions.</description>
    <language>en</language>
    <atom:link href="${SITE}/feed.xml" rel="self" type="application/rss+xml" />
    <lastBuildDate>${new Date().toUTCString()}</lastBuildDate>
${items
  .map(
    (s) => `    <item>
      <title>${escape(s.name)}</title>
      <link>${SITE}/s/${s.slug}</link>
      <guid isPermaLink="true">${SITE}/s/${s.slug}</guid>
      <category>${escape(s.category)}</category>
      <pubDate>${new Date(s.lastUpdated).toUTCString()}</pubDate>
      <description>${escape(s.description.slice(0, 500))}</description>
    </item>`,
  )
  .join("\n")}
  </channel>
</rss>`;

  return new Response(xml, {
    headers: {
      "Content-Type": "application/rss+xml; charset=utf-8",
      "Cache-Control": "public, max-age=0, s-maxage=3600",
    },
  });
}
