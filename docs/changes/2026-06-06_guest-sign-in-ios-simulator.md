# Guest sign-in on iOS simulator (router, App Check, local guest, RTDB skip)

**Date:** 2026-06-06

## Summary

- **Router:** Anonymous users may leave `/auth` after guest sign-in; Settings upgrade uses `AppRoutes.authUpgradePath()` (`?upgrade=true`) so anonymous users can return to auth only for upgrade (`lib/app/router/auth_redirect.dart`, `lib/core/router/app_routes.dart`, `lib/core/router/app_routes_auth.part.dart`, `AccountSection`). Post-login redirect query params reject external/scheme tricks via `isSafeRedirectPath`.
- **Bootstrap:** Skip Firebase App Check on iOS simulator in debug; set `isIosSimulatorInDebug` on **reuse** paths too (existing Firebase app / duplicate-app) so DI still skips RTDB after hot restart (`firebase_bootstrap_service.dart`, `firebase_bootstrap_service_helpers.dart`).
- **DI:** Narrow keychain-only local guest fallback for macOS debug or iOS simulator debug (`register_auth_services.dart`); omit RTDB remotes for those sessions via `shouldSkipFirebaseRemoteRepositories` (`injector_helpers.dart`) to stop recurring `no-current-user` / sync noise.
- **Quality gates:** `./bin/router_feature_validate` runs auth redirect, register_auth_services, injector_helpers, and sign-in page tests; `integration_test/guest_sign_in_flow_test.dart` registered for smoke/pr_smoke; selective map rule `auth_guest_sign_in` covers router, DI, bootstrap (`.dart` prefixes), and auth presentation paths. Guest integration flow accepts Firebase anonymous **or** simulator local-guest id.

## Verification

```bash
flutter test test/app/router/auth_redirect_test.dart test/core/di/register_auth_services_test.dart test/core/di/injector_helpers_test.dart test/sign_in_page_test.dart
./bin/router_feature_validate
echo "lib/core/di/injector_helpers.dart" | python3 tool/integration_selective_resolve.py
```

Device/simulator: Continue as guest → counter/home; after ~60s sync, no repeated `waitForAuthUser` / `pullRemote failed` logs on iOS simulator debug with local guest.
