# macOS guest sign-in timeout → local guest fallback

## Why

macOS `integration_test/all_flows` hung mid-suite when Firebase anonymous
sign-in never returned (Keychain / plugin stall without an exception).
`DebugKeychainGuestAuthRepository` only fell back on Keychain *errors*, so a
non-completing future blocked Guest IT indefinitely under direnv Firebase
dart-defines.

## What landed

- Bound `signInAnonymously()` with a 15s timeout (`signInAnonymouslyTimeout`,
  overridable in tests).
- On `TimeoutException`, activate `macos-debug-local-guest` (same path as
  Keychain entitlement failures).
- Unit coverage: stalling Firebase Auth mock → local guest on macOS debug.

## Verification

```bash
cd apps/mobile && flutter test --no-pub \
  test/app/composition/register_auth_services_test.dart
direnv exec . bash -lc \
  'cd apps/mobile && flutter test --no-pub -d macos --name "Guest sign-in" \
   integration_test/guest_sign_in_flow_test.dart'
ALLOW_DESKTOP_INTEGRATION_DEVICE=1 CHECKLIST_INTEGRATION_DEVICE=macos \
  INTEGRATION_TESTS_RUN_COVERAGE=0 ./bin/integration_tests
```
