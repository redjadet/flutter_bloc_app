# Verifiable evidence (short path for reviewers)

This page is the **short, checkable** companion to the [30-minute interview showcase](interview_showcase.md). Each case states the problem, the design trade-off, where the code lives, which automated tests cover it, and how to re-run those tests locally.

**Verification:** [![CI](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml) · [All workflow runs on `main`](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml?query=branch%3Amain) · Latest green `main` CI run (verified 2026-10-08): [run 37781041928](https://github.com/redjadet/flutter_bloc_app/actions/runs/37781041928)

For the full walkthrough and JD mapping table, use [interview_showcase.md](interview_showcase.md).

---

## 1. Offline-first counter: local persistence and queue replay

**Problem:** The counter must stay usable offline, survive restarts, and reconcile with a remote source when connectivity returns—without losing increments or double-applying writes.

**Design decision:** Hive-backed local storage plus a pending-sync queue and `OfflineFirstCounterRepository` that enqueues mutations and delegates flush to `BackgroundSyncCoordinator`. Trade-off: more moving parts than “remote-only,” but explicit queue semantics and testable coordinator boundaries instead of ad-hoc retries in the UI.

**Source (start here):**

- [`apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart`](../apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart)
- [`apps/mobile/lib/features/counter/data/hive_counter_repository.dart`](../apps/mobile/lib/features/counter/data/hive_counter_repository.dart)
- [`packages/networking/lib/src/sync/background_sync_coordinator.dart`](../packages/networking/lib/src/sync/background_sync_coordinator.dart) (coordinator)
- Guide: [offline_first adoption guide](offline_first/adoption_guide.md)

**Regression / unit tests (verified in repo):**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/features/counter/data/background_sync_counter_flow_test.dart`](../apps/mobile/test/features/counter/data/background_sync_counter_flow_test.dart) | `coordinator flushes queued operations end-to-end` |
| [`apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart`](../apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart) | `processOperation updates remote and local state` |
| [`apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart`](../apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart) | `pullRemote applies newer snapshot` |

**Run:**

```bash
cd apps/mobile && flutter test \
  test/features/counter/data/background_sync_counter_flow_test.dart \
  test/features/counter/data/offline_first_counter_repository_test.dart
```

**Untested / manual:** Real Firebase/RTDB or Supabase remote endpoints; production network partitions; OS background execution limits on physical devices.

---

## 2. BLoC boundary and Clean Architecture (counter spine)

**Problem:** UI and state logic must not depend on Hive, channels, or transport details so features stay testable and swappable.

**Design decision:** `CounterCubit` depends only on the `CounterRepository` port; data implementations sit behind `offline_first_counter_repository.dart` and related adapters. Trade-off: extra types and folders versus a single “god repository” file.

**Source:**

- Feature layout: [`apps/mobile/lib/features/counter/`](../apps/mobile/lib/features/counter/)
- Cubit: [`apps/mobile/lib/features/counter/presentation/cubit/counter_cubit.dart`](../apps/mobile/lib/features/counter/presentation/cubit/counter_cubit.dart)
- Contract: [feature structure contract](architecture/feature_structure_contract.md), [clean architecture](clean_architecture.md)

**Tests:**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/counter_cubit_test.dart`](../apps/mobile/test/counter_cubit_test.dart) | `updates state when repository emits flushed snapshot` |
| [`apps/mobile/test/counter_cubit_test.dart`](../apps/mobile/test/counter_cubit_test.dart) | `increment persists value and timestamp` |

**Run:**

```bash
cd apps/mobile && flutter test test/counter_cubit_test.dart
bash tool/check_feature_folder_contract.sh
```

**Untested / manual:** Folder contract is enforced by script in CI; it is not a single Dart `test()`—run the script above after structural edits.

---

## 3. MethodChannel: Swift / Kotlin host bridges

**Problem:** Demonstrate typed, defensive calls into iOS Swift and Android Kotlin (greeting, haptic, share, native security crypto) with graceful degradation on unsupported hosts.

**Design decision:** Thin Dart services (`MethodChannelNativeShowcaseHostLanguageService`, `MethodChannelNativeSecurityShowcaseService`) map platform replies through explicit mappers (schema version, status, reason codes) instead of passing raw maps to Cubits. Trade-off: verbose mapping code versus predictable failure modes in UI.

**Source:**

- [`apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service.dart)
- [`apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_security_showcase_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_security_showcase_service.dart)
- [`apps/mobile/lib/features/native_platform_showcase/data/native_security_channel_reply_mapper.dart`](../apps/mobile/lib/features/native_platform_showcase/data/native_security_channel_reply_mapper.dart)
- Native handlers: [`apps/mobile/ios/Runner/`](../apps/mobile/ios/Runner/), [`apps/mobile/android/app/src/main/kotlin/`](../apps/mobile/android/app/src/main/kotlin/)
- Teaching pack: [`apps/mobile/lib/features/native_platform_showcase/README.md`](../apps/mobile/lib/features/native_platform_showcase/README.md)

**Tests:**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart) | `invokeSwift returns success when channel responds` |
| [`apps/mobile/test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart) | `shareText passes text argument on Android` |
| [`apps/mobile/test/features/native_platform_showcase/data/method_channel_native_security_showcase_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/method_channel_native_security_showcase_service_test.dart) | `maps a successful reply to a success result` |
| [`apps/mobile/test/features/native_platform_showcase/data/native_security_channel_reply_mapper_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/native_security_channel_reply_mapper_test.dart) | `maps a successful P-256 reply` |

**Run:**

```bash
cd apps/mobile && flutter test \
  test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart \
  test/features/native_platform_showcase/data/method_channel_native_security_showcase_service_test.dart \
  test/features/native_platform_showcase/data/native_security_channel_reply_mapper_test.dart
```

**Untested / manual:** Actual Swift/Kotlin handler bodies on simulators/devices (biometric prompts, Keychain/Keystore, real share sheets). Unit tests use `TestDefaultBinaryMessenger` mocks.

---

## 4. EventChannel: native telemetry stream

**Problem:** Surface a live native telemetry stream to Flutter without blocking the UI isolate or accepting malformed events.

**Design decision:** `EventChannelNativeShowcaseTelemetryService` validates schema version, session id, and monotonic sequence before emitting domain snapshots; invalid events are dropped. Trade-off: strict filtering may hide native bugs until logs are read, but Cubits never see partial garbage state.

**Source:**

- [`apps/mobile/lib/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart)
- Cubit consumption: [`apps/mobile/lib/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart`](../apps/mobile/lib/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart)

**Tests:**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart) | `maps valid schema-v1 payload` |
| [`apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart) | `ignores stale session id` |
| [`apps/mobile/test/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit_test.dart`](../apps/mobile/test/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit_test.dart) | `stream error becomes failed telemetry while loaded data remains` |

**Run:**

```bash
cd apps/mobile && flutter test \
  test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart \
  test/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit_test.dart
```

**Untested / manual:** Native EventChannel producers on iOS/Android hardware; macOS registers a subset of channels only (see showcase README).

---

## 5. FFI and PlatformView (native code interop)

**Problem:** Show Dart calling into bundled native code (FFI) and embedding a platform view, with safe stubs on web/desktop.

**Design decision:** Conditional imports (`native_showcase_ffi_io.dart` / `native_showcase_ffi_stub.dart`) and `FfiNativeShowcaseNativeCodeService` keep `dart:ffi` out of web builds; PlatformView section shows placeholders off-mobile. Trade-off: duplicate entry points per platform versus a single broken web compile.

**Source:**

- FFI: [`apps/mobile/lib/features/native_platform_showcase/data/ffi_native_showcase_native_code_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/ffi_native_showcase_native_code_service.dart), [`native/native_showcase/native_showcase.c`](../native/native_showcase/native_showcase.c), iOS bridge in `NativeShowcaseBridge.swift`
- PlatformView UI: [`apps/mobile/lib/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section.dart`](../apps/mobile/lib/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section.dart)
- Related FFI demo (secure messaging): [`apps/mobile/lib/features/secure_messaging_demo/data/ffi_secure_core_repository.dart`](../apps/mobile/lib/features/secure_messaging_demo/data/ffi_secure_core_repository.dart)

**Tests:**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart`](../apps/mobile/test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart) | `round trip maps UTF-8 and base64` |
| [`apps/mobile/test/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section_test.dart`](../apps/mobile/test/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section_test.dart) | `shows unavailable placeholder off mobile` |

**Run:**

```bash
cd apps/mobile && flutter test \
  test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart \
  test/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section_test.dart
```

**Untested / manual:** Live `dart:ffi` calls into `libnative_showcase.so` / iOS `@_cdecl` symbols (requires full rebuild on device); real `UiKitView` / `AndroidView` rendering on phones. FFI unit tests for secure messaging use injected native gateways, not the on-disk `.so`.

---

## Scope and limits

This repository is a **portfolio reference app** for interviews and technical review. It is **not** evidence of production scale, employer-specific tenure, or live user counts. Backend demos may require local configuration documented in [`.env.example`](../.env.example) and [feature scope](feature_overview.md).
