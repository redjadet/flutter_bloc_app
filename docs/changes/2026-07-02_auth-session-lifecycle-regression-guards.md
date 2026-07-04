# Auth session lifecycle regression guards

## Summary

Auth session lifecycle paths now route to focused regression tests before broad
coverage. This catches session-expired UX races and cross-provider invalidation
drops early when `SessionLifecycleCoordinator` or `AppAuthCubit` changes.

## Bug class

- Invalidation event emitted before provider sign-out completes can race router
  auth state and bounce users away from `/auth`.
- A global invalidation in-flight flag can drop concurrent invalidation for a
  different provider.
- Weak async tests can miss this class unless they prove real overlap and stream
  delivery.

## Guard wiring

- `tool/check_regression_guards.sh` includes:
  - `test/app/presentation/cubit/app_auth_cubit_test.dart`
  - `test/core/auth/session_lifecycle_coordinator_test.dart`
- Auto mode selects those tests for `apps/mobile/lib/core/auth/*`, `AppAuthCubit`, and their
  auth test paths.
- `tool/delivery_checklist.sh` runs focused regression guards before coverage for
  those auth paths.

## Verification

```bash
flutter test test/app/presentation/cubit/app_auth_cubit_test.dart test/core/auth/session_lifecycle_coordinator_test.dart
CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths apps/mobile/lib/core/auth/session_lifecycle_coordinator.dart
CHECK_REGRESSION_GUARDS_MODE=auto tool/check_regression_guards.sh --paths apps/mobile/lib/app/presentation/cubit/app_auth_cubit.dart
```
