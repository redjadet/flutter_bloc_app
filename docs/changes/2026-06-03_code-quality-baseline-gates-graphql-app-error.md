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
