# Native showcase EventChannel telemetry

Date: 2026-07-02

## Summary

Added a bounded high-frequency native telemetry demo to
`native_platform_showcase` using `EventChannel`
(`com.example.flutter_bloc_app/native_showcase/telemetry`). Existing command
`MethodChannel` interop (`invokeSwift` / `invokeKotlin`) and FFI paths are
unchanged.

## Architecture

```text
Native worker (60 Hz sample + 250 ms aggregate)
  -> EventChannel
  -> EventChannelNativeShowcaseTelemetryService
  -> WatchNativeShowcaseTelemetryUseCase
  -> NativePlatformShowcaseCubit (subscription + sequence guard)
  -> NativePlatformShowcaseTelemetrySection (selector-isolated UI)
```

## Platforms

| Platform | Handler |
| --- | --- |
| Android | `NativeShowcaseTelemetryStreamHandler.kt` |
| iOS | `NativeShowcaseTelemetryStreamHandler.swift` |
| macOS | `NativeShowcaseTelemetryStreamHandler.swift` |
| Web / Windows / Linux | Dart emits one `unavailable` snapshot |

## Validation

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/native_platform_showcase/ test/native_platform_service_test.dart
bash tool/check_feature_folder_contract.sh
bash tool/check_clean_architecture_imports.sh
bash tool/analyze.sh
flutter build apk --debug
flutter build ios --simulator --debug
flutter build macos --debug
```

All commands above passed on 2026-07-02 in worktree `codex/native-communication-plan`.

Native registration changes require full rebuild (not hot reload).
