# Production readiness FCM setup resilience

## Summary

FCM setup can fail after Firebase initializes (for example, from a platform
permission or plugin error). Previously that exception escaped
`_initializeFcm()` and changed the already-ready production-readiness demo into
a fatal error state.

The cubit now retains `ready` state and surfaces the existing non-fatal FCM
error banner. Stream-error behavior remains unchanged.

## Regression proof

- `apps/mobile/test/features/production_readiness/presentation/production_readiness_cubit_test.dart`
  covers a throwing FCM permission request.
- `cd apps/mobile && flutter test test/features/production_readiness/presentation/production_readiness_cubit_test.dart`
