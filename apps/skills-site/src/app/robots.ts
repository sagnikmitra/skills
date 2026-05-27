import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [{ userAgent: "*", allow: "/" }],
    sitemap: "https://skills.sgnk.ai/sitemap.xml",
    host: "https://skills.sgnk.ai",
  };
}
