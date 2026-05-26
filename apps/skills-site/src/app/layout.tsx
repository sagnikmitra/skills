import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "Skills · sgnk",
  description:
    "Public catalog of skills, workflows, and agent instructions. Synced from Claude, Codex, and Antigravity into one canonical registry.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://rsms.me/" />
        <link rel="stylesheet" href="https://rsms.me/inter/inter.css" />
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
            <a
              href="https://github.com/sagnikmitra/skills"
              target="_blank"
              rel="noreferrer"
              className="nav-cta"
            >
              GitHub ↗
            </a>
          </nav>
        </header>
        <main className="site-main">{children}</main>
        <footer className="site-footer">
          <p>
            Canonical source: <code>skills/skills.registry.json</code> · synced from{" "}
            Claude / Codex / Antigravity · mirrored to HQ, md.sgnk.ai, Obsidian.
          </p>
        </footer>
      </body>
    </html>
  );
}
