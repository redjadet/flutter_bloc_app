# Batch C — therapy initState + CallCubit guard

**Date:** 2026-06-22

## Summary

- **CallCubit.refresh:** `RequestIdGuard` prevents stale slower refresh from overwriting newer appointments.
- **Therapy + websocket pages:** `context.cubit<Type>()` startup moved to `addPostFrameCallback` + `mounted` guard (10 files).
- **Guard script:** `tool/check_inherited_widget_in_initstate.sh` matches `context.cubit<` and ignores reads inside `addPostFrameCallback`.

## Verification

```bash
bash tool/check_inherited_widget_in_initstate.sh
flutter test test/features/online_therapy_demo/
./bin/router_feature_validate
```
