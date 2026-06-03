# Checklist quality gates — warn → fail promotion

**Date:** 2026-06-03

## Summary

Promoted `check_remote_image_cache_hints.sh` and `check_cubit_subscription_cancel.sh`
from warn-only (always exit 0) to fail when violations exist. Baseline on `main` was
0 violations for both gates before promotion (QG-D09).

## Changes

- Scripts exit `1` on violations; checklist messages no longer say "(warn-only)"
- Baseline severity: `warn` → `fail`
- Removed **QG-D09** from [`plans/checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md)
- Catalog + validation routing matrix updated

## Verification

```bash
# Fixtures — bad must fail, suppressed must pass
bash tool/check_remote_image_cache_hints.sh --paths tool/fixtures/remote_image_cache_hints/presentation/bad.dart
bash tool/check_remote_image_cache_hints.sh --paths tool/fixtures/remote_image_cache_hints/presentation/suppressed.dart
bash tool/check_cubit_subscription_cancel.sh --paths tool/fixtures/cubit_subscription_cancel/presentation/bad_cubit.dart
bash tool/check_cubit_subscription_cancel.sh --paths tool/fixtures/cubit_subscription_cancel/presentation/suppressed_cubit.dart

# Full lib scope — expect 0 violations
bash tool/check_remote_image_cache_hints.sh
bash tool/check_cubit_subscription_cancel.sh
```
