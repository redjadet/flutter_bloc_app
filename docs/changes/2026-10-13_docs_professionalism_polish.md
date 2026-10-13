# Docs professionalism polish (emoji / heading tone)

**Date:** 2026-10-13  
**Scope:** Reader-facing living docs only; no policy or technical meaning changes.

## Why

High-traffic contributor and review docs still used emoji-decorated section
headings and checklist marks that read as casual portfolio scaffolding rather
than engineering documentation.

## What changed

- Removed emoji from section headings in [`docs/contributing/FAQ.md`](../contributing/FAQ.md)
  and [`docs/review/flutter_best_practices_review.md`](../review/flutter_best_practices_review.md);
  normalized review headings to sentence case.
- Replaced emoji Good/Bad and Need-dispose headings with plain prose in
  [`docs/architecture/dry_principles.md`](../architecture/dry_principles.md) and
  [`docs/engineering/REPOSITORY_LIFECYCLE.md`](../engineering/REPOSITORY_LIFECYCLE.md).
- Cleaned decorative status marks / title ampersand tone in
  [`docs/offline_first/ANALYSIS_AND_IMPROVEMENTS.md`](../offline_first/ANALYSIS_AND_IMPROVEMENTS.md)
  and the counter offline checklist
  ([`docs/offline_first/counter.md`](../offline_first/counter.md)).

## Intentionally unchanged

- Inline `// ✅` / `// ❌` markers in validation-guide code contrasts (teaching
  convention for good vs bad snippets).
- Core indexes (`README.md`, `AGENTS.md`, `docs/README.md`, `DESIGN.md`,
  `CODEMAP.md`) — already professional after prior consistency passes.
- Historical `docs/changes/` and `docs/audits/` content.

## Verification

- `git diff --check` clean on touched files.
- Spot-checked relative links in edited docs still resolve to existing paths.
