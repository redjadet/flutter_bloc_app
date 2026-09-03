# Auth security hardening — PR C (App auth UX)

## Summary

Adds `AppAuthCubit` for Firebase `sessionExpired` UX (snackbar + redirect) while
keeping GoRouter on `AuthRepository.authStateChanges`. Final [`authentication.md`](../authentication.md)
update with coordinator architecture.

## Changes

- `AppAuthCubit` / `AppAuthState` with sticky `sessionExpired`
- `_AppAuthSessionListener` in `AppScope`
- l10n `sessionExpiredMessage`
- Full authentication doc pass

## Verification

```bash
flutter test test/app/presentation/cubit/app_auth_cubit_test.dart
flutter gen-l10n
```

## Deferred (not in PR C)

See [`authentication.md`](../authentication.md) — AUTH-D01 (Render coordinator), AUTH-D02 (`RegisterPage` backend), AUTH-D03 (role/claims ADR), AUTH-D04 (`auth_injection_failed` extra).
