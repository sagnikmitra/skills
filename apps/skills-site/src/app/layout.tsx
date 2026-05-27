import type { Metadata } from "next";
import Link from "next/link";
import { Inter, JetBrains_Mono } from "next/font/google";
import { Analytics } from "@vercel/analytics/next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import { ThemeToggle } from "../components/theme-toggle";
import "./globals.css";

// Inline at <head> to set theme before paint and avoid FOUC.
const themeInit = `(function(){try{var s=localStorage.getItem('theme');var l=s||(matchMedia('(prefers-color-scheme: light)').matches?'light':'dark');document.documentElement.dataset.theme=l;}catch(e){}})();`;

// next/font self-hosts at build time → no third-party CSP exception needed,
// and Next handles font-display: swap + size-adjust automatically.
const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});
const mono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-mono-self",
  display: "swap",
});

const SITE = "https://skills.sgnk.ai";

export const metadata: Metadata = {
  metadataBase: new URL(SITE),
  title: {
    default: "Skills · sgnk",
    template: "%s",
  },
  description:
    "Public catalog of skills, workflows, and agent instructions. Synced from Claude, Codex, and Antigravity into one canonical registry.",
  alternates: {
    canonical: "/",
    types: { "application/rss+xml": [{ url: "/feed.xml", title: "sgnk · skills" }] },
  },
  openGraph: {
    type: "website",
    url: SITE,
    siteName: "sgnk · skills",
    title: "Skills · sgnk",
    description:
      "Public catalog of skills, workflows, and agent instructions. Synced from Claude, Codex, and Antigravity.",
  },
  twitter: { card: "summary_large_image", title: "Skills · sgnk" },
  robots: { index: true, follow: true },
};

export const viewport = {
  themeColor: "#1f1e1d",
  colorScheme: "dark" as const,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${mono.variable}`} suppressHydrationWarning>
      <head>
        {/* Static, hardcoded IIFE — no user input, no XSS surface. Required
            inline to set [data-theme] before first paint (FOUC guard). */}
        <script dangerouslySetInnerHTML={{ __html: themeInit }} />
      </head>
      <body>
        <header className="site-header">
          <nav className="site-nav">
            <Link href="/" className="brand">
              <span className="brand-mark" aria-hidden />
              sgnk · skills
            </Link>
            <div className="nav-links">
              <Link href="/">All</Link>
              <Link href="/?source=claude">Claude</Link>
              <Link href="/?source=codex">Codex</Link>
              <Link href="/?source=antigravity">Antigravity</Link>
              <Link href="/about">About</Link>
            </div>
            <ThemeToggle />
            <a
              href="https://github.com/sagnikmitra/skills"
              target="_blank"
              rel="noopener noreferrer"
              className="nav-cta"
            >
              GitHub ↗
            </a>
            <details className="nav-toggle">
              <summary aria-label="Open navigation menu">☰</summary>
              <div className="mobile-panel">
                <Link href="/">All</Link>
                <Link href="/?source=claude">Claude</Link>
                <Link href="/?source=codex">Codex</Link>
                <Link href="/?source=antigravity">Antigravity</Link>
                <Link href="/about">About</Link>
                <a
                  href="https://github.com/sagnikmitra/skills"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  GitHub ↗
                </a>
              </div>
            </details>
          </nav>
        </header>
        <main className="site-main">{children}</main>
        <Analytics />
        <SpeedInsights />
        <footer className="site-footer">
          <p>
            Canonical source: <code>apps/skills-site/content/skills.registry.json</code> · synced from{" "}
            Claude / Codex / Antigravity · mirrored to HQ, md.sgnk.ai, Obsidian.
          </p>
        </footer>
      </body>
    </html>
  );
}
