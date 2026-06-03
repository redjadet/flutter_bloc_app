# Quality Phase 2: gate fail flip + MapSample AppError

**Date:** 2026-06-03

## Summary

- **QG-D05** / **QG-D07**: default mode `warn` → **fail** in `tool/check_*.sh`; catalog and deferred backlog updated.
- **Google Maps** `MapSampleCubit`: `AppError? lastError` on load failure (Chart-aligned); retry when `isRetryable`.

## Verification

```bash
bash tool/check_lifecycle_observer_dispose.sh
bash tool/check_deferred_heavy_routes.sh
flutter test test/features/google_maps/
```

## Follow-up

- `./bin/checklist` and iOS exhaustive integration on branch before merge.
