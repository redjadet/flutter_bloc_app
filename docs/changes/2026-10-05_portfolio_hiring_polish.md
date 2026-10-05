# Portfolio polish for hiring reviewers

**Date:** 2026-10-05  
**Branch:** `cursor/portfolio-polish-hiring-bb77`

## Intent

Tighten the first impression for recruiters and senior engineers reviewing this
portfolio: lead with evidence, localize unfinished demo-hub copy, label Archive
demos, and remove placeholder skeleton text.

## Scope

- In: README presentation, Example hub grouping/l10n, demo entry titles,
  realtime market skeleton, web meta, `DESIGN.md` / LICENSE / feature_overview
  wording, integration title finds.
- Out: Architecture rewrites, new demos, dependency bumps, Archive removal.

## Layers touched

- [x] presentation (Example hub, overflow menu, therapy/AI titles, market skeleton)
- [x] routes / l10n (new ARB keys; no route changes)
- [x] docs / web surface

## Behavior contract

- Must remain true: Archive demos stay reachable; spine/demo ValueKeys unchanged.
- Failure/recovery: Missing title finds in preflight/integration updated to
  `Feature demos` after rename (prevents `pumpUntilFound` hang).

## Proof

```bash
flutter analyze --no-fatal-infos <changed dart files>
flutter test test/features/example test/example_page_test.dart
bash tool/check_missing_localizations.sh
bash tool/check_docs_gardening.sh --paths README.md docs/feature_overview.md DESIGN.md
bash tool/check_feature_brief_linked.sh
```
