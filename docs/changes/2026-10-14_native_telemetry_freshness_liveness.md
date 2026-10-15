# Native telemetry freshness and source liveness

Date: 2026-10-14

## Summary

Teaching follow-up for the native EventChannel telemetry demo: update rate and
displayed-value age are separate concerns. Dart now marks values stale on a
monotonic freshness deadline (even when no new event arrives), and hosts emit
explicit liveness ticks when a delivery window heard source samples but accepted
none (all duplicate-filtered).

## Changes

- Domain: `NativeShowcaseTelemetryFreshness` + monotonic
  `NativeShowcaseTelemetryFreshnessTracker` (receipt age vs value age)
- Cubit: periodic freshness re-evaluation; liveness ticks keep the last accepted
  average on screen
- Native Android / iOS / macOS accumulators: all-dup windows with source activity
  emit `acceptedCount == 0` liveness payloads instead of going quiet
- UI + l10n: value age, receipt age, stale/fresh, source live/quiet
- Tests: Dart freshness + Cubit; Android JUnit + iOS XCTest accumulator updates

## Non-goals

- No schema version bump (liveness reuses schema-v1 with `acceptedCount == 0`)
- No cross-clock latency claim from native wall timestamps vs Dart wall time
- Physical-device latency report remains deferred

## Validation

```bash
cd apps/mobile && flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/native_platform_showcase/
bash tool/check_feature_folder_contract.sh
bash tool/check_clean_architecture_imports.sh
```

## Freezed note

`NativeShowcaseTelemetryFreshness` is a plain immutable class (no Freezed).
`NativePlatformShowcaseState.telemetryFreshness` required updating
`native_platform_showcase_state.freezed.dart` to match the annotation.
A `/tmp` worktree `build_runner` run completed with **0 outputs** and removed
the part file, so the annotation-matched generated surface is committed with
this change; regenerate when the host builder is healthy.
