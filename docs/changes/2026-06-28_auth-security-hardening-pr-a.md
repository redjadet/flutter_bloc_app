# Auth security hardening — PR A (Firebase session cleanup)

## Summary

Introduces `SessionLifecycleCoordinator` as the central session cleanup and
invalidation seam for Firebase-primary auth. Wraps all `AuthRepository` variants
with `SignOutAwareAuthRepository`, promotes `AuthTokenManager` to a DI singleton,
and classifies Firebase token refresh failures in `AuthTokenInterceptor` (including
persistent 401 after replay).

## Changes

- `SessionLifecycleCoordinator` + auth-stream listener (closes FirebaseUI sign-out bypass)
- `SignOutAwareAuthRepository` decorator on all auth repo variants
- `AuthTokenManager` DI singleton with two-phase `bindAuthTokenManager`
- `auth_token_refresh_classifier.dart` for auth-classified `FirebaseAuthException` codes
- Interceptor invalidation on classified refresh failure and post-retry 401
- HF orchestration token cache cleared via coordinator on sign-out
- Debug logging redaction (HF token suffix, App Check full token)

**Deferred:** [`plans/auth_security_hardening_deferred.md`](../plans/auth_security_hardening_deferred.md) (AUTH-D01–D04).

## Verification

```bash
flutter test test/core/auth/ test/shared/http/ test/features/auth/data/sign_out_aware_auth_repository_test.dart
./bin/router_feature_validate
./bin/checklist
```
