# Integration host path / memory recovery docs

## Why

Cross-platform `./bin/integration_tests` failed on this host before any product
assertion ran: stale SwiftPM XCFramework absolute paths after a removed
`Flutter_SDK/projects` alias, Xcode DerivedData `build.db` disk I/O on a full
system volume, and Android AVD jetsam under memory pressure when launch and
tests ran as separate shell commands.

## What landed

- Document host recovery in
  [`docs/engineering/integration_runner_contract.md`](../engineering/integration_runner_contract.md)
  (iOS SPM/DerivedData table; Android memory-pressure + one-shell chain).
- Durable operator prefs for Lacie path alias + DerivedData relocation.
- Comment on `tool/ensure_android_integration_avd.sh` matching the contract.
- Refresh iOS/macOS SPM `Package.resolved` AppCheck `11.3.1` → `11.3.2`
  (resolve during successful builds).

## Verification

| Platform | Command / device | Result |
| --- | --- | --- |
| Web | `INTEGRATION_PREFLIGHT_WEB_DEVICE=chrome ./bin/integration_preflight` | +5 / +5 |
| iOS | `CHECKLIST_INTEGRATION_DEVICE=B9524A50-… ./bin/integration_tests` | +30 `all_flows` |
| Android | `--launch && CHECKLIST_INTEGRATION_DEVICE=emulator-5554 ./bin/integration_tests` | +30 `all_flows` |
| macOS | `CHECKLIST_INTEGRATION_DEVICE=macos ./bin/integration_tests` | +30 `all_flows` |

Host-only (not in git): `~/Flutter_SDK/projects/bloc_test_app` → Lacie checkout
symlink; `~/Library/Developer/Xcode/DerivedData` → Lacie `XcodeDerivedData`.
