# 2026-07-23 — Android integration test fixes

## Summary

Ran `./bin/integration_tests` on the local Android emulator (`Small_Phone_3`,
resized to 1080×2400@420) and fixed failures that blocked the suite on Android
but not on iOS.

## Root causes

1. **Guest sign-in** — Firebase dart-defines were not injected into integration
   `flutter test`; without config, Android skipped auth. Guest CTA also sat
   below a short viewport.
2. **Overflow destinations (IoT)** — popup menu items were found but tapped at
   the viewport edge (missed hit-test).
3. **Settings back** — `tester.pageBack()` expects Cupertino back; Material uses
   `Icons.arrow_back`.
4. **Hive secure storage** — Android emulator Keystore path failed intermittently;
   Apple debug already used in-memory secret storage.

## Changes

- Inject env dart-defines (keys logged only) via `tool/run_integration_tests.sh`
- Android emulator local-guest parity with iOS simulator
- Overflow open scrolls + nudges menu item into hittable area
- Cross-platform `_pageBack` helper
- `useInMemorySecretStorageInDebug()` includes Android
- Integration log filter ignores Hive key persistence noise on mobile
- `tool/ensure_android_integration_avd.sh` + contract § Android AVD (persist
  medium-phone panel sizing; host-local AVD, not git)

## Verification

Focused (earlier):

```bash
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 \
INTEGRATION_TESTS_RUN_COVERAGE=0 \
INTEGRATION_TESTS_RUN_PREFLIGHT=0 \
./bin/integration_tests \
  integration_test/guest_sign_in_flow_test.dart \
  integration_test/iot_demo_flow_test.dart \
  integration_test/iot_demo_ble_tab_flow_test.dart \
  integration_test/extended_flows_test.dart
# → All tests passed (exit 0)
```

Full exhaustive (follow-up):

```bash
tool/ensure_android_integration_avd.sh
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 \
INTEGRATION_TESTS_RUN_COVERAGE=0 \
./bin/integration_tests
# → All tests passed (28/28, exit 0, ~120s on emulator-5554)
```
