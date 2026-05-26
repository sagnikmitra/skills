import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "Skills · sgnk",
  description: "Public catalog of skills, workflows, and agent instructions. Synced from Claude, Codex, and Antigravity into one canonical registry.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header className="site-header">
          <nav className="site-nav">
            <Link href="/" className="brand">sgnk · skills</Link>
            <div className="nav-links">
              <Link href="/">All</Link>
              <Link href="/?source=claude">Claude</Link>
              <Link href="/?source=codex">Codex</Link>
              <Link href="/?source=antigravity">Antigravity</Link>
              <Link href="/about">About</Link>
              <a href="https://github.com/sagnikmitra/skills-registry" target="_blank" rel="noreferrer">GitHub ↗</a>
            </div>
          </nav>
        </header>
        <main className="site-main">{children}</main>
        <footer className="site-footer">
          <p>
            Canonical source: <code>skills-registry/skills.registry.json</code> · synced from{" "}
            Claude / Codex / Antigravity · mirrored to HQ, md.sgnk.ai, Obsidian.
          </p>
        </footer>
      </body>
    </html>
  );
}
