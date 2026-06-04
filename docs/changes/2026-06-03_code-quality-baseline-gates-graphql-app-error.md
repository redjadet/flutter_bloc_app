# Code quality baseline, checklist gates, Graphql AppError

**Date:** 2026-06-03

## Summary

- Baseline audit and Phase 0b spike docs under `docs/audits/`.
- Promoted **QG-D05** (`check_deferred_heavy_routes.sh`) and **QG-D07** (`check_lifecycle_observer_dispose.sh`) as warn-first checklist gates with `tool/fixtures/`.
- Graphql demo cubit adopts `AppError? lastError` (Chart-aligned) with mapper and retry gating.

## Verification

```bash
bash tool/check_lifecycle_observer_dispose.sh
bash tool/check_deferred_heavy_routes.sh
bash tool/validate_validation_docs.sh
flutter test test/features/graphql_demo/
bash tool/modular_metrics.sh --cross-feature-only
```

## Follow-up (post-merge, 2026-06-03)

| Check | Result |
| --- | --- |
| `./bin/checklist-fast` on clean `main` | pass |
| QG-D05 / QG-D07 on `lib/` | 0 violations (warn mode) |
| `./bin/integration_preflight` | pass |
| iOS `standard_flows_test.dart` (iPhone 17e) | 22/22 pass |

Baseline audit updated: [code_quality_baseline_2026-06-03.md](../audits/code_quality_baseline_2026-06-03.md) (post-merge table).
