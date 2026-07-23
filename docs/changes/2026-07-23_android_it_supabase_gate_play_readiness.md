# 2026-07-23 — Android IT Chat/IoT auth-gate flake + Play readiness

## Summary

Full Android integration suite failed Chat list + IoT (×2) under load while
focused re-runs passed. Root cause: `IotDemoAuthGate` on Chat/IoT routes when
Supabase bootstrap becomes initialized without a session (host `SUPABASE_*` /
dart-defines). Gate redirects to supabase auth → tests miss
`Conversation history` / `IoT Demo`.

## Fix

- Integration harness: `SupabaseBootstrapService.resetForTest()` + no-op
  `initializeClient` so demo flows stay local-only.
- Overflow/example helpers: conditional edge nudge + menu-open retry (safer
  taps on small AVD).
- Added `apps/mobile/android/key.properties.example` (real file still required
  for release signing).

## Verification

```bash
CHECKLIST_INTEGRATION_DEVICE=emulator-5554 \
INTEGRATION_TESTS_RUN_COVERAGE=0 INTEGRATION_TESTS_RUN_PREFLIGHT=0 \
./bin/integration_tests
# → +28 All tests passed
./tool/release_android_play.sh preflight  # Fastlane play_preflight OK
```

## Remaining for Play upload

Wire gitignored `apps/mobile/android/key.properties` to
`~/.keystores/flutter_bloc_app-upload.jks` (passwords/alias). Then
`./tool/release_android_play.sh upload_internal`.
