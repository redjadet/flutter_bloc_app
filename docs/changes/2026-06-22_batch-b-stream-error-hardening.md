# Batch B — stream error hardening

**Date:** 2026-06-22

## Summary

- **Supabase auth:** `authStateChanges` subscription uses `cancelOnError: false` so a transient stream error no longer deafens the cubit to later auth events.
- **IAP demo:** Purchase-result stream errors emit `error` state (cubit) and `IapPurchaseResult.failure` with `IapDemoProductIds.unknownPurchaseStream` (real store repo) instead of swallowing. Terminal (non-pending) stream results clear `isBusy` and return to `ready`.
- **WebSocket echo:** Channel stream uses `cancelOnError: false` so reconnect after mid-stream errors works.
- **IoT demo:** Device watch uses `cancelOnError: false` so `onError` emission does not permanently kill the subscription.

## Deferred (repro-first / already handled)

- **Deeplink** stream `onError` already emits + supports `retryInitialize`; empty `onError` in `CubitExceptionHandler` is dead when `onErrorWithDetails` is set.
- **Realtime market / counter / todo** empty `onError` — no repro in Batch B.

## Verification

```bash
flutter test test/features/supabase_auth/presentation/cubit/supabase_auth_cubit_test.dart
flutter test test/features/in_app_purchase_demo/presentation/cubit/in_app_purchase_demo_cubit_test.dart
flutter test test/features/websocket/data/echo_websocket_repository_test.dart
./tool/analyze.sh
```
