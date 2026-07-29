# Native EventChannel telemetry: contract and hardening plan

**Status:** Implemented (schema v1 render contract); physical-device latency
report still required before any latency headline.

## Implementation locks

- `render` only; hosts reject `latencyCritical` with `invalid_config`.
- `maxDeliveryHz` clamp `4..15`; Cubit default `4`.
- Wire schema v1 is a breaking demo contract (no dual-key compatibility).
- macOS uses the same `makeBackgroundTaskQueue` EventChannel constructor as iOS.

## Goal

Turn the existing native telemetry showcase into a measurable, bounded
real-time stream contract: continuous data uses `EventChannel`, expensive
native work stays off the platform main thread, and native code drops or
aggregates samples before the Flutter bridge.

## Research trigger and conclusion

The source graphic in [the reviewed article](https://blog.devgenius.io/a-team-just-published-why-they-deleted-all-their-flutter-code-for-kotlin-multiplatform-9deac0803bf3)
contrasts `150ms` Flutter sensor latency via a default `MethodChannel` with
`5ms native`, and proposes `EventChannel`, background work, and native-side
throttling. The diagnosis is directionally useful, but it is not a benchmark
for this app.

Flutter documents `EventChannel` as an asynchronous event stream and exposes
an Android task-queue constructor. Flutter also documents background task
queues for platform handler execution, while platform/UI-bound work and
channel delivery still require an explicit main-thread handoff when the host
API requires it. See [Platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)
and [Android EventChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/EventChannel.html).

This repository already has the intended basic topology:

```text
Android HandlerThread / Apple DispatchQueue (60 Hz source work)
  -> native aggregate + duplicate filtering (250 ms / 4 Hz)
  -> EventChannel compact map
  -> Dart adapter -> use case -> Cubit selector-isolated UI
```

The host stream handlers contain the worker queues and native throttling
today. The remaining gap is a production-quality performance contract:
handler-dispatch policy, configurable bounded delivery, complete accounting,
and physical-device evidence. The current 250 ms aggregation window is an
intentional rendering trade-off; it cannot support a truthful sub-10 ms
end-to-end freshness claim.

## Boundaries

- Keep one-shot commands on their existing `MethodChannel`; do not use a
  method call per sensor sample.
- Keep continuous telemetry on the existing
  `com.example.flutter_bloc_app/native_showcase/telemetry` `EventChannel`.
- Preserve Clean Architecture: presentation and domain use a stream port;
  channel types stay in `data/` and host code.
- Do not move UIKit/Android UI-bound sensor registration or the required
  event-sink handoff off the main thread. Move only handler setup and
  non-UI capture, filtering, aggregation, and serialization off it.
- No Kotlin Multiplatform migration, new plugin, Pigeon migration, or
  unmeasured `<10ms` marketing claim.

## Target contract

### Stream setup

Pass a versioned, typed `TelemetryStreamConfig` through
`EventChannel.receiveBroadcastStream(arguments)` rather than introducing a
per-sample control `MethodChannel`.

| Field | Rule |
| --- | --- |
| `schemaVersion` | Required; initially `1` |
| `mode` | `render` or `latencyCritical` |
| `maxDeliveryHz` | Required, clamped to an explicit host-supported range |
| `aggregation` | `latest` or `mean`; host rejects unknown values |
| `sessionId` | Opaque correlation value; no PII |

`render` starts with a conservative 4-15 Hz budget and selector-isolated UI.
`latencyCritical` exists only for a proven product need: it carries the latest
sample with a separately agreed latency budget and must not trigger one full
Flutter rebuild per source sample.

### Event payload

Retain the current required fields and add only versioned, compact counters:

| Field | Meaning |
| --- | --- |
| `sourceReceivedCount` | Samples observed from the native source in this window |
| `acceptedCount` | Samples retained after native filtering |
| `droppedBeforeBridgeCount` | Samples removed by native de-duplication, decimation, or latest-only replacement |
| `bridgeEventSequence` | Strictly increasing event sequence for the session |
| `nativeWindowStartedAt` / `nativeEmittedAt` | Same-clock native timestamps for source-to-emit timing |

Do not compare unrelated Dart wall-clock and native wall-clock timestamps as
latency. Publish end-to-end p50/p95 only from an on-device trace with a
defensible common-clock correlation.

## Execution plan

### 1. Freeze a baseline before changing behavior

- Record source rate, bridge event rate, UI rebuild rate, queue/backlog signal,
  native source-to-emit p50/p95, and frame timing on one Android and one iOS
  physical device.
- Capture the source type, build mode, device/OS, 60-second duration, and
  foreground/background state with every result.
- Treat the existing 60 Hz -> 4 Hz demo as a rendering baseline, not a
  latency claim. Preserve its behavior unless a benchmark disproves it.

### 2. Make handler dispatch explicit

- **Android:** construct the telemetry `EventChannel` with
  `binaryMessenger.makeBackgroundTaskQueue()` and the task-queue constructor;
  keep platform/UI work and `EventSink` delivery on the documented required
  thread.
- **iOS:** create the `FlutterEventChannel` with the registrar messenger's
  background task queue when the pinned Flutter API supports it; retain
  `DispatchQueue.main.async` only for the sink/UI handoff.
- **macOS:** verify the pinned constructor/API separately. Keep its current
  worker queue if task queues are unavailable; do not copy iOS syntax blindly.
- Keep the generation token and stop-before-relisten behavior. Prove no stale
  event survives cancellation or a new listener.

### 3. Extract and test native pre-bridge policy

- Extract a small host-owned accumulator/decimator from each stream handler so
  sample collection, de-duplication, aggregation, cadence, and reset are
  independently testable.
- Apply the policy before constructing the channel map. Use bounded
  latest-only replacement or aggregation; never let an unbounded native or
  Dart queue accumulate.
- Validate stream arguments, clamp delivery rate, and report one sanitized
  stream error for invalid configuration. Unknown schema versions fail closed.
- Make `droppedBeforeBridgeCount` mean all source samples discarded before
  channel serialization, not only near-duplicate samples.

### 4. Preserve Dart and presentation isolation

- Add typed config/payload mappers in `data/`; reject malformed, fractional,
  stale-session, and sequence-regressing events.
- Keep the domain stream port free of Flutter channel imports. Extend the
  snapshot only with presentation-safe metrics.
- Keep one Cubit subscription, cancellation in `close()`, and the existing
  selector boundary. Coalesce any UI-facing updates to the agreed render
  budget.

### 5. Prove the device contract

- Add Dart mapper tests for configuration and every invalid payload class;
  retain the sequence and cancellation Cubit tests.
- Add native unit tests for the accumulator/decimator and session replacement
  semantics. Add Android/iOS integration coverage that starts, cancels, and
  re-listens without leaked workers or duplicate events.
- Repeat the physical-device trace. Approve only if delivery stays within the
  configured budget, no backlog grows, frame pacing remains healthy, and the
  latency result is reproducible. Otherwise retain the existing profile and
  document the measured limit.

## File map

| Area | Planned files |
| --- | --- |
| Dart stream contract | `apps/mobile/lib/features/native_platform_showcase/domain/native_showcase_telemetry_{service,snapshot}.dart`, new config/value types, and `data/event_channel_native_showcase_telemetry_service.dart` |
| Dart tests | `apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart`, Cubit tests, and focused widget selector proof |
| Android | `apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/{MainActivity,NativeShowcaseTelemetryStreamHandler}.kt` plus host tests |
| Apple | `apps/mobile/ios/Runner/{AppDelegate,NativeShowcaseTelemetryStreamHandler}.swift`, macOS equivalent only after API verification, plus host tests |
| Documentation | Feature README, a dated change note after implementation, and this contract/plan |

## Acceptance criteria

- [x] Continuous samples never use `MethodChannel` calls.
- [x] Source collection, filtering, aggregation, and serialization are off the
  platform main thread unless a host API explicitly requires main-thread work.
- [x] Every bridge event is bounded by an explicit native delivery policy and
  reports unambiguous pre-bridge drop accounting.
- [x] Stop/relisten invalidates old workers and events on Android, iOS, and
  supported macOS.
- [x] Dart rejects invalid schema/config/payload values and never rebuilds the
  static showcase for every source tick.
- [ ] A reproducible physical-device report records p50/p95 and frame impact;
  no latency headline is published without that evidence.

## Validation after implementation

```bash
cd apps/mobile && flutter test test/features/native_platform_showcase/
bash tool/check_feature_folder_contract.sh
bash tool/check_clean_architecture_imports.sh
./tool/analyze.sh
flutter build apk --debug
flutter build ios --simulator --debug
flutter build macos --debug
./bin/checklist
```

Use `./bin/integration_tests` when the device lifecycle test is registered in
the integration journey map. Native builds prove compilation, not sensor
latency; retain the physical-device trace as the performance proof.

## Explicit deferrals

- Replacing all existing command `MethodChannel`s.
- A global telemetry abstraction for unrelated features.
- A sub-10 ms target before a product owner identifies the latency-critical
  signal and physical-device evidence supports it.
