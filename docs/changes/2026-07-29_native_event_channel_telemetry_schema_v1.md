# Native EventChannel telemetry schema-v1 contract

Date: 2026-07-29

## Summary

Hardened the native showcase telemetry `EventChannel` to a versioned render
contract: stream config arguments, extractable native pre-bridge accumulator,
background task-queue channel construction, and Dart-side schema/session/
sequence validation.

## Changes

- Dart: `NativeShowcaseTelemetryStreamConfig`, schema-v1 snapshot fields,
  `receiveBroadcastStream(arguments)`, data-layer rejection rules
- Native: `NativeShowcaseTelemetryAccumulator` on Android / iOS / macOS;
  listen-arg validation; full `droppedBeforeBridgeCount` accounting
- Registration: `makeBackgroundTaskQueue()` for telemetry EventChannels
- Tests: Dart mapper/Cubit/page updates; Android JUnit + iOS XCTest accumulator
  coverage

## Measurement checklist (physical device; optional for merge)

Record for one Android and one iOS device over 60s foreground:

- Source rate, bridge event rate, UI rebuild rate
- Native `nativeWindowStartedAt` → `nativeEmittedAt` p50/p95
- Frame timing / jank
- Build mode, device/OS, source type

Do not publish end-to-end latency headlines without this evidence.

## Validation

```bash
cd apps/mobile && flutter test test/features/native_platform_showcase/
bash tool/check_feature_folder_contract.sh
bash tool/check_clean_architecture_imports.sh
./tool/analyze.sh
flutter build apk --debug
flutter build ios --simulator --debug
# macOS may fail on unrelated SPM plugin modules (desktop_webview_auth /
# flutter_tts); macOS telemetry sources mirror the compiling iOS handler.
flutter build macos --debug
```

Native registration changes require a full rebuild (not hot reload).
