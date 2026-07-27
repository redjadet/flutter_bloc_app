# Secure logging hardening (2026-07-27)

## Goal

Centralize redaction for every Dart `AppLogger` sink and Crashlytics recording,
remove confirmed URI/native URL leaks, and enforce high-confidence sensitive-log
patterns in CI.

## Changes

- Added `LogRedaction` and routed all `AppLogger` public APIs through one
  sanitized `_log` ingress; added `AppLogger.event`.
- Deep-link cubit and HTTP telemetry log sanitized scheme/host/path (or event
  fields) instead of full URIs / interpolated Dio errors.
- iOS `SceneDelegate` no longer logs `url.absoluteString`.
- Crashlytics handlers record sanitized exception text + original stack only
  (`printDetails: false`); never `recordFlutterFatalError` with raw details.
- `tool/check_raw_print.sh` scans `apps/**/lib` and `packages/**/lib`.
- New `tool/check_sensitive_logging.sh` (+ fixtures, `--self-test`) wired into
  `./bin/checklist`.

## Limits

- Free-text secret scrubbing is heuristic.
- Existing stringly `AppLogger` call sites were not bulk-migrated to `event`.
- Optional `TelemetryEventSink` payloads are unchanged.

## Rollback

Revert this change set to restore prior logging behavior (and reopen the
documented leak paths).

## Validation

- `./bin/checklist`: pass
- `./bin/integration_preflight`: pass
- `./bin/integration_tests` (`integration_test/all_flows_test.dart`): pass
- `flutter build ios --simulator --debug`: pass
- `tool/check_sensitive_logging.sh --self-test`: pass
