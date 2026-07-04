# Batch C — therapy initState + CallCubit guard

**Date:** 2026-06-22

## Summary

- **CallCubit.refresh:** `RequestIdGuard` prevents stale slower refresh from overwriting newer appointments.
- **CallCubit session operations:** `selectAppointment` invalidates stale create/join completions and clears busy state so old sessions cannot overwrite the new selection.
- **Therapy + websocket pages:** `context.cubit<Type>()` startup moved to `addPostFrameCallback` + `mounted` guard (10 files).
- **Guard script:** `tool/check_inherited_widget_in_initstate.sh` matches `context.cubit<` and ignores reads inside `addPostFrameCallback`.
- **Checklist routing:** `tool/check_regression_guards.sh` auto-selects the therapy call cubit regression plus Batch B/D stream/cache/chat guards for matching feature paths.

## Verification

```bash
bash tool/check_inherited_widget_in_initstate.sh
flutter test test/features/online_therapy_demo/
CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths apps/mobile/lib/features/online_therapy_demo/presentation/cubit/call_cubit.dart
./bin/router_feature_validate
```
