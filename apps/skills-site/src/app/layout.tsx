import type { Metadata } from "next";
import Link from "next/link";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

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

export const metadata: Metadata = {
  title: "Skills · sgnk",
  description:
    "Public catalog of skills, workflows, and agent instructions. Synced from Claude, Codex, and Antigravity into one canonical registry.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${mono.variable}`}>
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
