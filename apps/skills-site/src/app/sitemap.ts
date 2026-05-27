import type { MetadataRoute } from "next";
import { getRegistry } from "../lib/registry";

const SITE = "https://skills.sgnk.ai";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const reg = await getRegistry();
  const now = new Date();
  const staticUrls: MetadataRoute.Sitemap = [
    { url: `${SITE}/`, lastModified: now, changeFrequency: "hourly", priority: 1 },
    { url: `${SITE}/about`, lastModified: now, changeFrequency: "monthly", priority: 0.5 },
  ];
  const skillUrls: MetadataRoute.Sitemap = reg.skills
    .filter((s) => s.status === "active")
    .map((s) => ({
      url: `${SITE}/s/${s.slug}`,
      lastModified: new Date(s.lastUpdated),
      changeFrequency: "weekly",
      priority: 0.7,
    }));
  return [...staticUrls, ...skillUrls];
}
