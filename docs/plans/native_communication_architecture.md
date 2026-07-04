# Native Communication Architecture Plan

Status: implemented (2026-07-02).

## Goal

Add a small, real `EventChannel` native stream to `native_platform_showcase`
and use it as the repo reference for high-frequency native data. Preserve the
current low-frequency `MethodChannel` calls.

Target architecture:

```text
Native source
  -> background worker
  -> throttle/filter/batch/aggregate
  -> EventChannel
  -> data service
  -> use case
  -> Cubit
  -> selector-isolated UI
```

## Current Inventory

App-owned `MethodChannel` usage:

| Channel | Methods | Classification | Decision |
| --- | --- | --- | --- |
| `com.example.flutter_bloc_app/native` | `getPlatformInfo`, `hasGoogleMapsApiKey` | command/request-response | Keep. One-time calls only. |
| `com.example.flutter_bloc_app/native_showcase` | `invokeSwift`, `invokeKotlin` | command/request-response | Keep. Explicit native interop demo calls only. |

No app-owned `MethodChannel` currently carries continuous or high-frequency
native data. Vendored/plugin channels under `third_party/pub` are out of scope.

## Scope

In:

- Add one telemetry stream demo under `native_platform_showcase`.
- Register Android, iOS, and macOS `EventChannel` handlers.
- Keep web/unsupported platforms safe with an unavailable/no-op stream.
- Add tests and docs for the stream architecture and lifecycle.

Out:

- Do not migrate existing command `MethodChannel` calls to Pigeon in this
  slice.
- Do not add production sensor, BLE, audio, camera, market, or location
  features.
- Do not add new packages.
- Do not change third-party plugin platform channels.

## Dart Contracts

Add domain model:

```dart
enum NativeShowcaseTelemetryStatus { unavailable, streaming, failed }

@freezed
abstract class NativeShowcaseTelemetrySnapshot
    with _$NativeShowcaseTelemetrySnapshot {
  const factory NativeShowcaseTelemetrySnapshot({
    required NativeShowcaseTelemetryStatus status,
    required int sequence,
    required int sampleCount,
    required double averageValue,
    required int sourceRateHz,
    required int deliveredRateHz,
    required int droppedCount,
    required DateTime emittedAt,
    String? message,
  }) = _NativeShowcaseTelemetrySnapshot;
}
```

Add domain port:

```dart
abstract interface class NativeShowcaseTelemetryService {
  Stream<NativeShowcaseTelemetrySnapshot> watchTelemetry();
}
```

Add use case:

```dart
class WatchNativeShowcaseTelemetryUseCase {
  WatchNativeShowcaseTelemetryUseCase(this._service);
  final NativeShowcaseTelemetryService _service;

  Stream<NativeShowcaseTelemetrySnapshot> call() =>
      _service.watchTelemetry();
}
```

Update state:

```dart
const factory NativePlatformShowcaseState.loaded(
  PlatformShowcaseData data, {
  NativeShowcaseTelemetrySnapshot? telemetry,
}) = _Loaded;
```

Update Cubit constructor:

```dart
NativePlatformShowcaseCubit({
  required LoadNativePlatformShowcaseUseCase loadShowcase,
  required WatchNativeShowcaseTelemetryUseCase watchTelemetry,
})
```

Cubit behavior:

- `load()` still emits `loading` then `loaded(data)`.
- After successful load, Cubit starts telemetry subscription once.
- Telemetry updates only mutate the `telemetry` field while preserving loaded
  `data`.
- Duplicate or older `sequence` values are ignored.
- Stream errors emit a `failed` telemetry snapshot when current state is
  loaded; they do not replace the whole page with load error.
- `close()` cancels telemetry subscription before `super.close()`.

## Data Adapter

Add `EventChannelNativeShowcaseTelemetryService` in
`apps/mobile/lib/features/native_platform_showcase/data/`.

Channel name:

```dart
const String kNativeShowcaseTelemetryChannel =
    'com.example.flutter_bloc_app/native_showcase/telemetry';
```

Adapter constructor:

```dart
EventChannelNativeShowcaseTelemetryService({
  Stream<Object?> Function()? events,
})
```

Default `events` uses:

```dart
const EventChannel(kNativeShowcaseTelemetryChannel).receiveBroadcastStream()
```

Tests pass a `StreamController<Object?>.stream` through `events` instead of
mocking Flutter binary messages.

Payload contract from native to Dart:

| Key | Type | Rule |
| --- | --- | --- |
| `sequence` | `int` | Monotonic per listen session, starts at 1. |
| `sampleCount` | `int` | Number of raw samples aggregated into this event. |
| `averageValue` | `double` | Aggregate sample value for demo. |
| `sourceRateHz` | `int` | Native source sample rate, default 60. |
| `deliveredRateHz` | `int` | Flutter delivery rate, default 4. |
| `droppedCount` | `int` | Raw samples filtered/dropped before emit. |
| `emittedAtMillis` | `int` | Unix epoch millis from native event creation. |

Mapping rules:

- Non-map events are ignored.
- Missing or invalid numeric fields are ignored.
- `emittedAtMillis` maps to `DateTime.fromMillisecondsSinceEpoch(...,
  isUtc: true).toLocal()`.
- `MissingPluginException` and unsupported web/desktop targets return one
  `unavailable` snapshot then close.

## Native Implementation

Android:

- File: `android/app/src/main/kotlin/com/ilkersevim/blocflutter/MainActivity.kt`.
- Add `io.flutter.plugin.common.EventChannel`.
- Register `com.example.flutter_bloc_app/native_showcase/telemetry` in
  `configureFlutterEngine`.
- Use a `HandlerThread` or single-thread `ScheduledExecutorService` for source
  sampling and aggregation.
- Post `EventSink.success(map)` back through the main looper when emitting.
- Stop worker and clear sink in `onCancel`.

iOS:

- File: `ios/Runner/AppDelegate.swift`.
- Register `FlutterEventChannel` in `didInitializeImplicitFlutterEngine`.
- Add a small `NativeShowcaseTelemetryStreamHandler` class.
- Use a private `DispatchQueue` for sample generation and aggregation.
- Dispatch final `eventSink(payload)` to the main queue.
- Cancel timer/source and nil out sink in `onCancel`.

macOS:

- File: `macos/Runner/MainFlutterWindow.swift`.
- Register the same `FlutterEventChannel`.
- Add macOS-compatible stream handler using `DispatchSourceTimer` on a private
  queue.
- Emit final sink calls on the main queue.

Native defaults:

- Source rate: 60 Hz.
- Delivery window: 250 ms.
- Delivered rate: 4 Hz.
- Payload: aggregate map only; no raw sample arrays.
- Source value: deterministic demo waveform/counter, not device sensor data.

## UI

Add `NativePlatformShowcaseTelemetrySection`.

Display:

- Unavailable: "Native telemetry stream unavailable on this platform."
- Streaming: source rate, delivered rate, sample count, dropped count, latest
  average value.
- Failed: short error message and keep rest of showcase visible.

Rebuild rule:

- Static loaded content continues to render from `data`.
- Telemetry section uses `TypeSafeBlocSelector` or `selectState` to select only
  `NativeShowcaseTelemetrySnapshot?`.
- No full `ListView` rebuild on telemetry-only updates.

## DI And Routing

Update `registerNativePlatformShowcaseServices`:

- Register `NativeShowcaseTelemetryService` with
  `EventChannelNativeShowcaseTelemetryService`.
- Register `WatchNativeShowcaseTelemetryUseCase`.

Update `createNativePlatformShowcaseRoute`:

- Pass both `LoadNativePlatformShowcaseUseCase` and
  `WatchNativeShowcaseTelemetryUseCase` into `NativePlatformShowcaseCubit`.

## Tests

Data tests:

- `event_channel_native_showcase_telemetry_service_test.dart`
  - maps valid payload.
  - ignores non-map event.
  - ignores invalid numeric payload.
  - emits unavailable snapshot when injected event stream throws
    `MissingPluginException`.

Cubit tests:

- Update `native_platform_showcase_cubit_test.dart`.
- Assert successful load starts telemetry.
- Assert telemetry update changes only loaded telemetry field.
- Assert duplicate/older sequence is ignored.
- Assert stream error becomes failed telemetry while loaded data remains.
- Assert `close()` cancels telemetry stream.

Widget tests:

- Update `native_platform_showcase_page_test.dart`.
- Assert telemetry section appears when loaded.
- Assert streaming labels render.
- Assert unavailable/failed state keeps summary and interop sections visible.

Existing tests to keep green:

- `method_channel_native_showcase_host_language_service_test.dart`
- `native_platform_info_repository_impl_test.dart`
- `test/native_platform_service_test.dart`

## Build Todo

Check each item in this file as implementation completes.

- [x] Re-read [`AGENTS.md`](../../AGENTS.md), [`ai/context_loading.md`](../ai/context_loading.md),
  [`agent_project_context.md`](../agent_project_context.md), [`bloc_standards.md`](../bloc_standards.md), and this plan.
- [x] Confirm clean worktree status or record unrelated local changes before
  editing. (`docs/plans/native_communication_architecture.md` was untracked at start.)
- [x] Add `NativeShowcaseTelemetryStatus` and
  `NativeShowcaseTelemetrySnapshot` under
  `apps/mobile/lib/features/native_platform_showcase/domain/`.
- [x] Add `NativeShowcaseTelemetryService` domain port.
- [x] Add `WatchNativeShowcaseTelemetryUseCase`.
- [x] Add `EventChannelNativeShowcaseTelemetryService` with injectable event
  stream for tests.
- [x] Register telemetry service and use case in
  `registerNativePlatformShowcaseServices`.
- [x] Update `NativePlatformShowcaseCubit` constructor, stream subscription,
  duplicate-sequence guard, stream-error handling, and `close()`.
- [x] Update `createNativePlatformShowcaseRoute` to inject
  `WatchNativeShowcaseTelemetryUseCase`.
- [x] Add `NativePlatformShowcaseTelemetrySection` and selector-isolate it from
  static page content.
- [x] Register Android `EventChannel` and background aggregation worker.
- [x] Register iOS `FlutterEventChannel` and background aggregation handler.
- [x] Register macOS `FlutterEventChannel` and background aggregation handler.
- [x] Run build runner for Freezed output.
- [x] Add and update focused data, Cubit, and widget tests listed in
  [Tests](#tests).
- [x] Run validation commands listed in [Validation](#validation). Proof (2026-07-02):
  `flutter test test/features/native_platform_showcase/` (34 passed),
  `tool/check_feature_folder_contract.sh`, `tool/check_clean_architecture_imports.sh`,
  `tool/analyze.sh`, `flutter build apk --debug`, `flutter build ios --simulator --debug`,
  `flutter build macos --debug`. Android also required Gradle 9.5.1 (AGP 8.13 vs 9.6),
  plugin `compileSdk` alignment in `android/build.gradle`, and `META-INF` pickFirsts.
- [x] Update relevant docs listed in [Documentation Updates](#documentation-updates).
- [x] Mark this checklist complete only after code, tests, docs, and validation
  evidence are done.

## Documentation Updates

Update these docs in the implementation PR:

- [x] [`apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md) — add EventChannel
  telemetry flow, channel name, native rebuild note, and test commands.
- [x] `docs/changes/<yyyy-mm-dd>_native_showcase_event_channel_telemetry.md`
  — add feature brief/change note for the Dart/native implementation.
- [x] [`architecture/reference_features.md`](../architecture/reference_features.md) — update the
  `native_platform_showcase` row so it names command `MethodChannel`, streaming
  `EventChannel`, FFI, and Cubit/use-case boundaries.
- [x] [`feature_overview.md`](../feature_overview.md) — update native showcase summary to mention
  the EventChannel high-frequency stream reference.
- [x] [`CODEMAP.md`](../../CODEMAP.md) — update native interop entry if it still describes only
  `MethodChannel / FFI`.
- [x] [`agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md) — update only if the
  implementation creates a reusable operator preference or durable agent rule;
  otherwise leave unchanged. (No change required.)

## Validation

Before implementation:

```bash
git status --short
```

After Dart/codegen changes:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/native_platform_showcase/ test/native_platform_service_test.dart
bash tool/check_feature_folder_contract.sh
bash tool/check_clean_architecture_imports.sh
bash tool/analyze.sh
```

After native code changes:

```bash
flutter build apk --debug
flutter build ios --simulator --debug
flutter build macos --debug
```

If local toolchain cannot run one native build, record the exact command and
failure reason. Swift/Kotlin channel registration changes require full rebuild;
hot reload is insufficient.

## Acceptance Criteria

- Existing command `MethodChannel` behavior unchanged.
- New EventChannel demo streams on Android, iOS, and macOS.
- Unsupported platforms do not hang or crash.
- Native side sends at most 4 telemetry events per second by default.
- No raw high-frequency samples cross platform channel.
- Cubit owns and cancels stream subscription.
- UI telemetry updates do not rebuild static showcase content.
- Focused tests and analyzer pass.

## Pigeon And FFI Rules

Use Pigeon later when command APIs grow beyond tiny demo calls, when request or
response objects need compile-time safety, or when Android/iOS/macOS method
surfaces must stay in lockstep. Do not add Pigeon in this first slice.

Use `dart:ffi` only for C/C++ sources or performance-critical native libraries.
The existing C/C++ native showcase path remains the repo FFI example. Do not
use FFI for normal platform SDK callback streams.

## Performance Checklist

- Message rate: Flutter receives bounded aggregate events, default max 4 Hz.
- Main-thread work: sample and aggregate off main thread; only sink handoff on
  required platform thread.
- Serialization cost: compact primitive map only.
- Filtering: native side drops unchanged/low-signal samples before batching.
- Batching: native side emits aggregate windows, not individual callbacks.
- Cancellation: `onCancel` stops workers/timers and clears sink.
- Memory leaks: no long-lived native references after cancel; Cubit cancels in
  `close()`.
- UI frame stability: selector-isolated telemetry UI, distinct sequence updates,
  no full page rebuild for telemetry-only changes.

## Deferred Work

- Generate typed command APIs with Pigeon.
- Add a static guard that flags `MethodChannel` use in stream/sensor/BLE/audio/
  location/camera/native callback classes unless allowlisted.
- Promote EventChannel guidance into owning architecture docs after the demo
  implementation lands.
- Add platform performance probes only when a real SDK stream has measurable
  frame impact.
