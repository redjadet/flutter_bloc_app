# 2026-08-24 — integration harness (macOS + desktop fast-path)

## Why

Checklist and supported-platform integration after upgrade lane: macOS
`all_flows` failed on counter assumptions and duplicate social-feed scenario
controls. Pinned `CHECKLIST_INTEGRATION_DEVICE=macos` also hung on `adb
devices` during discovery.

## Scope

- App launch / guest sign-in: drive count via `CounterValueText` (relative
  increment/decrement). Do not assume text `"0"` or semantics labels (macOS
  IT does not expose `Text.semanticsLabel` to finders; Hive may retain count).
- Social feed: skip opening tune sheet when scenario controls already visible
  (wide/desktop side panel); allow `findsWidgets` for shared key.
- `tool/run_integration_tests.sh`: host-desktop fast-path when
  `ALLOW_DESKTOP_INTEGRATION_DEVICE=1`; timeout hung `adb devices`.
- README coverage badge refresh from checklist (85.30%).

## Out of scope

- Android emulator lane (no emulator connected this run).
- Product counter reset / Hive wipe between desktop suite runs.

## Proof

- `./bin/checklist` EXIT 0 (2907 tests, 85.30% coverage)
- iOS sim `./bin/integration_tests` EXIT 0 (preflight + all_flows)
- Narrow macOS: `flutter test … --name 'App launch|Guest sign-in'` EXIT 0
- Full macOS: `CHECKLIST_INTEGRATION_DEVICE=macos
  ALLOW_DESKTOP_INTEGRATION_DEVICE=1 ./bin/integration_tests` EXIT 0
  (+30 all_flows; log `/tmp/integration_macos_r3.log`)
