# Docs professionalism polish (emoji / heading tone)

**Date:** 2026-10-13

**Scope:** Reader-facing living docs only; no policy or technical meaning
changes.

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
- Follow-up on review: removed leftover closing status emoji in
  [`docs/offline_first/ANALYSIS_AND_IMPROVEMENTS.md`](../offline_first/ANALYSIS_AND_IMPROVEMENTS.md);
  dropped markdown hard-break trailing spaces that failed `git diff --check`.

## Intentionally unchanged

- Inline `// ✅` / `// ❌` markers in validation-guide and similar code
  contrasts (teaching convention for good vs bad snippets), including the
  `// ✅ Added` annotation inside the ANALYSIS fix example.
- Core indexes ([`README.md`](../../README.md), [`AGENTS.md`](../../AGENTS.md),
  [`docs/README.md`](../README.md), [`DESIGN.md`](../../DESIGN.md),
  [`CODEMAP.md`](../../CODEMAP.md)) — already professional after prior
  consistency passes.
- Historical `docs/changes/` and `docs/audits/` content.
- Broader Title Case normalization outside headings this pass already touched.

## Verification

- `git diff --check` clean on touched files.
- Spot-checked relative links in edited docs still resolve to existing paths.
