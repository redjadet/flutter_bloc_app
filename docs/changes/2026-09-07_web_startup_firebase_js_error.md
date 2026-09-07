# Web startup stuck: WalletConnect Firebase.app() JS Error

## Why

GitHub Pages web build stuck after HTML/Flutter splash (blank view, no
`flt-scene-host`). Headless Chrome showed uncaught `Error` from
`firebase_core.getApp()` while resolving `WalletConnectAuthRepository` during
router/DI setup at `MyApp` create.

## Root cause

Web bootstrap skips Firebase init, but `registerWalletConnectAuthServices`
still called `Firebase.app()` and caught only `on Exception`. On dart2js the
missing default app surfaces as a raw JS `Error`, which is not a Dart
`Exception`, so it escaped, tore down painting, and left a blank Flutter view.

## Fix

- Guard with `Firebase.apps.isEmpty` and catch `on Object` before falling back
  to the mock WalletConnect repository.
- Clarify the existing unit test that resolution must succeed without Firebase.

## Regression capture

Bug class: optional Firebase on web + `Firebase.app()` under `try` that catches
only `Exception` / `Firebase*Exception` (misses dart2js JS `Error`).

| Lane | Artifact |
| --- | --- |
| Static guard | `tool/check_firebase_app_object_catch.sh` (+ fixtures) |
| Checklist | wired in `tool/delivery_checklist.sh` |
| Unit | `test/app/composition/register_walletconnect_auth_services_test.dart` in `tool/check_regression_guards.sh` |
| Lesson | `tasks/lessons.md` (2026-09-07) |

## Proof

```bash
bash tool/check_firebase_app_object_catch.sh --self-test
bash tool/check_firebase_app_object_catch.sh
cd apps/mobile && flutter test test/app/composition/register_walletconnect_auth_services_test.dart
# After Pages deploy: load https://redjadet.github.io/flutter_bloc_app/ — home UI, not blank forever
```
