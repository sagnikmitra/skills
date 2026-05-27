import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "About · sgnk skills",
  description:
    "How the skills registry works: scanner, normalizer, fan-out to HQ, md.sgnk.ai, Obsidian, and skills.sgnk.ai.",
  alternates: { canonical: "/about" },
};

export default function AboutPage() {
  return (
    <article className="markdown">
      <h1>About this catalog</h1>
      <p>
        This is the public face of the Skills Sync System. One canonical
        registry powers four destinations:
      </p>
      <ul>
        <li><strong>HQ project</strong> — landing page top-nav Skills section + post-login sidebar.</li>
        <li><strong>md.sgnk.ai</strong> — Skills folder rendered inside the vault editor.</li>
        <li><strong>Obsidian vault</strong> — Skills folder with frontmatter, tags, and backlinks.</li>
        <li><strong>skills.sgnk.ai</strong> (this site) — the public catalog you&rsquo;re reading.</li>
      </ul>
      <h2>Source systems</h2>
      <ul>
        <li>Claude (<code>~/.claude/skills</code>)</li>
        <li>Codex (<code>~/.codex/skills</code> + project-level <code>AGENTS.md</code>)</li>
        <li>Antigravity (configurable; opt-in)</li>
      </ul>
      <h2>Pipeline</h2>
      <pre><code>{`Claude / Codex / Antigravity
        ↓  scanner + normalizer (scripts/sync.mjs)
   skills.registry.json  ←  canonical source of truth
        ↓  fan-out
HQ landing · HQ sidebar · md.sgnk.ai · Obsidian · skills.sgnk.ai`}</code></pre>
      <h2>Normalized shape</h2>
      <p>Every skill is normalized to exactly two files:</p>
      <ul>
        <li><code>skill.md</code> — what the skill is, capabilities, when to use, dependencies.</li>
        <li><code>workflow.md</code> — how the skill executes, step-by-step, edge cases, integration notes.</li>
      </ul>
      <h2>Sync rules</h2>
      <ul>
        <li>Add → fan out to every destination, append to registry.</li>
        <li>Update → re-write only the changed files, bump <code>lastUpdated</code>.</li>
        <li>Delete → archive under <code>_Archived/</code>, never hard-delete.</li>
        <li>Conflict → write a conflict report; never silently overwrite a destination edit.</li>
      </ul>
      <p>
        Source repo:{" "}
        <a href="https://github.com/sagnikmitra/skills" target="_blank" rel="noopener noreferrer">
          github.com/sagnikmitra/skills
        </a>
      </p>
    </article>
  );
}
