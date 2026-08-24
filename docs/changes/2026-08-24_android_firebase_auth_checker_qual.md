# 2026-08-24 — Android firebase_auth 6.6 checker-qual classpath

## Why

After dart-minor-patch (#729), local `assembleDebug` failed on
`:firebase_auth:compileDebugKotlin` — Checker Framework
`UnknownInitialization` annotation inaccessible under AGP 9 built-in Kotlin +
KGP 2.4. CI `build` lane does not assemble Android APK, so the gap was local-only.

## Scope

- `apps/mobile/android/build.gradle`: `compileOnly checker-qual` for
  `:firebase_auth` subproject.
- `tool/run_integration_tests.sh`: wait for adb emulator boot when pin is
  `emulator-*` (avoids race before `sys.boot_completed`).

## Proof

- `flutter build apk --debug` succeeds after checker-qual classpath fix
- `./bin/integration_tests` on `CHECKLIST_INTEGRATION_DEVICE=emulator-5554`
  EXIT 0 (+30 all_flows; log `/tmp/integration_android_r6.log`)
