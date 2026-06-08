# sgnk.ai brand + design system (for published pages)

When the piece is going on sgnk.ai (a /writing post, a research page, etc.), wrap the in-voice prose in the brand. The live **harness page** (`sgnk.ai/harness`, source: `sagnikmitra.github.io/harness/index.html`) is the canonical worked example — copy its shell.

## Identity

- **Tagline:** `Craft. Harness. Deploy.` (topbar + footer). Do not reopen the tagline debate; this is settled.
- **Thesis:** sgnk → ai. Innovation/craft first, AI deployed on top. The logo literally extracts the "a" and "i" out of "sagnik".
- **Author line:** `Sagnik Mitra · sgnk`. Email `sagnik@sgnk.ai`.

## Visual system

- **Colours:** white `#fff`, electric blue `#1a5cff`, black `#000`. Functional greys for separators only.
- **Type:** `Google Sans` for everything, `Google Sans Code` for code/captions. (No pixel display font in body — it's the logo, not text.)
- **Hero:** the three-panel lightrail image (`/harness/sgnk-lightrail.png`) — sagnik (white) → sgnk (blue) → ai (black). Top-right: the `sgnk.png` wordmark linking to `https://sgnk.ai`. Favicon from repo root `/favicon.png`.
- **Components:** sticky topbar (brand + tagline + logo), pull-quotes (blue left-border, `.pull` with a small uppercase `.label`), styled diagram boxes (`.flow`/`.node`), tables (uppercase `th`, blue-soft row hover), dark code blocks with blue left-border, a TOC (`.toc`, two columns), a references list, and a dark `.cite-block` with BibTeX + plain-text and a copy button.

## Page conventions

- **Absolute asset paths.** Vercel serves `sgnk.ai/harness` without a trailing slash, so relative paths break. Always use `/harness/...` (or the page's own absolute base), never bare `sgnk.png`.
- **Link to the source generously.** For research pages, scatter dashed "→ in the paper" links (`.paperlink`) into sections, plus a header Download-PDF button and a footer PDF link. The user explicitly wants the page to hand off to the fuller source often.
- **Keep the figures.** Diagrams, code listings, formulas, and tables carry the technical credibility even when the prose is plain and playful. Keep them; rewrite only the prose around them.
- **OG/Twitter cards** updated to the punchier title so shares unfurl well.

## Deploy

The page lives in the `sagnikmitra.github.io` repo (`harness/` etc.), which the Vercel project `sgnk-ai` auto-deploys to apex `sgnk.ai` — and which also serves `sagnikmitra.com` via GitHub Pages. Commit + push to `master`, Vercel redeploys. See the `sgnk-ai-deploy-topology` memory for the full wiring. Verify the live no-slash URL after deploy.

## Tone-for-brand reminder

The page can be polished and premium; the *voice* stays plain, warm, and playful-but-subtle. Polished design + earnest first-person prose is exactly the sgnk.ai combination — it reads as a real person who happens to have good taste, which is the whole brand.
