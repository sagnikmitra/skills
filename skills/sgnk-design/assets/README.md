# assets/

This skill intentionally ships **no binary assets**. The brand PNGs are
source-of-truth artifacts that live in the canonical repo, not duplicated here,
so they never drift from the deployed marks.

Canonical asset locations (in `sagnikmitra.github.io`):

- `harness/sgnk.png` — corner wordmark (top-right of the topbar).
- `harness/sgnk-lightrail.png` — full-bleed `sagnik → sgnk · ai` lightrail hero.
- `favicon.png` (repo root) — browser-tab icon.

When building a new sgnk Writes piece, copy the marks you need into your own
`<slug>/` directory (see the **Starter Article Shell** copy workflow in
`../references/sgnk-design-system.md`) rather than referencing this folder.

If you ever want a self-contained asset payload for the skill, copy those PNGs
here and update the spec's copy workflow to point at this directory — until
then, this directory is deliberately empty.
