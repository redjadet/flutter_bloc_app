# Verifiable portfolio evidence

Start with **case 1**: a late remote response must not overwrite newer local state.
Follow its design decision to the named regression and the recorded verification.
The other cases cover Flutter boundaries and native interop. Use the
[30-minute interview showcase](interview_showcase.md) for the full walkthrough.

## Recorded verification

[![CI on main](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/redjadet/flutter_bloc_app/actions/workflows/ci.yml?query=branch%3Amain)

The badge is rolling status. The records below identify the executed proof on
**2026-10-09**, tested commit
[`5aa04771392fccf77dd3ea7fd0f11bb4a2cb6372`](https://github.com/redjadet/flutter_bloc_app/commit/5aa04771392fccf77dd3ea7fd0f11bb4a2cb6372).

| Proof | Result and scope |
| --- | --- |
| Linked regressions, local Flutter tests | **115 passed** across all ten test files linked below; [exact command and local gates](changes/2026-10-08_verifiable_evidence_page.md#proof-commands). |
| [Hosted app tests and coverage](https://github.com/redjadet/flutter_bloc_app/actions/runs/37902949216/job/113729610021) | **3,095 passed, 1 skipped**; coverage **85.76%**, app-shell coverage **79.88%**, both above their 75% floors. The log records the stale-response and queue-replay regressions passing. |
| [Hosted iOS smoke integration](https://github.com/redjadet/flutter_bloc_app/actions/runs/37902949216/job/113730219449) | **21 passed** on **iPhone 17e simulator**, including `Native platform showcase flow opens showcase from Example and renders platform summary`. Artifact: exit **0**, `retried: false`, target `integration_test/smoke_flows_test.dart`, tier `smoke`. |

Hosted app tests use the existing Linux lane, which excludes `golden` and
`skip-checklist` tags; `error_snackbar_test.dart` is the reported skipped suite.
This record does not claim every test or native handler executed. Commands and
proof limits follow; setup once from the repository root:

```bash
bash tool/workspace_pub_get.sh
```

Every command block below starts from the repository root and returns there.
Toolchain versions are pinned in [toolchain_versions.env](toolchain_versions.env).
PR #1012's result-recording follow-up changes documentation only; app/native
sources, tests, dependency locks, and CI inputs match the tested commit. This is
dated proof; later implementation or toolchain changes need fresh verification.

---

## 1. Offline-first counter: local persistence and queue replay

**Problem:** A remote read can finish after the user changes the local counter.
Applying that stale response would replace newer local work. Offline mutations
also need a persisted queue that can flush when connectivity returns.

**Design decision:** `OfflineFirstCounterRepository` stores the local snapshot,
enqueues pending synchronization, and re-reads local state immediately before
saving a remote snapshot. Timestamp/conflict rules protect newer local state;
`BackgroundSyncCoordinator` owns replay. Trade-off: explicit queue and conflict
handling add complexity. This is snapshot reconciliation, not a distributed
counter or an exactly-once delivery guarantee.

**Named regression:** `pullRemote re-checks local before save when local advances`
starts with local count 3, receives remote count 5, then advances local count to 4
with a later timestamp during the second local read. It asserts that count 4 and
its unsynchronized state survive the late remote response. The queue flow test
uses real Hive storage and a fake remote repository to assert that replay drains
the pending queue.

**Source (start here):**

- [`apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart`](../apps/mobile/lib/features/counter/data/offline_first_counter_repository.dart)
- [`apps/mobile/lib/features/counter/data/hive_counter_repository.dart`](../apps/mobile/lib/features/counter/data/hive_counter_repository.dart)
- [`packages/networking/lib/src/sync/background_sync_coordinator.dart`](../packages/networking/lib/src/sync/background_sync_coordinator.dart) (coordinator)
- Guide: [offline_first adoption guide](offline_first/adoption_guide.md)

**Regression / unit tests (verified in repo):**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart`](../apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart) | `pullRemote re-checks local before save when local advances` |
| [`apps/mobile/test/features/counter/data/background_sync_counter_flow_test.dart`](../apps/mobile/test/features/counter/data/background_sync_counter_flow_test.dart) | `coordinator flushes queued operations end-to-end` |
| [`apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart`](../apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart) | `processOperation updates remote and local state` |
| [`apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart`](../apps/mobile/test/features/counter/data/offline_first_counter_repository_test.dart) | `pullRemote applies newer snapshot` |

**Run:**

```bash
(cd apps/mobile && flutter test \
  test/features/counter/data/background_sync_counter_flow_test.dart \
  test/features/counter/data/offline_first_counter_repository_test.dart)
```

**Proof limits:** These tests cover the encoded reconciliation and replay cases.
They do not exercise real Firebase/RTDB or Supabase endpoints, all multi-client
conflicts, or OS background execution on physical devices.

---

## 2. BLoC boundary and Clean Architecture (counter spine)

**Problem:** UI and state logic must not depend on Hive, channels, or transport details so features stay testable and swappable.

**Design decision:** `CounterCubit` accesses persistence through the
`CounterRepository` port, with separate sync-diagnostics and timer/time
dependencies. Storage and remote adapters implement the port. Trade-off: more
interfaces and wiring, but Cubit tests can control persistence, time, and sync
without depending on Hive or transport implementations.

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
(cd apps/mobile && flutter test test/counter_cubit_test.dart)
bash tool/check_feature_folder_contract.sh
```

**Proof limits:** Cubit tests exercise state transitions with controlled
dependencies. The folder-contract script checks structure; it does not prove
every architectural dependency is correct.

---

## 3. MethodChannel: Swift / Kotlin host bridges

**Problem:** Demonstrate typed, defensive calls into iOS Swift and Android Kotlin (greeting, haptic, share, native security crypto) with graceful degradation on unsupported hosts.

**Design decision:** Thin Dart services (`MethodChannelNativeShowcaseHostLanguageService`, `MethodChannelNativeSecurityShowcaseService`) map platform replies through explicit mappers (schema version, status, reason codes) instead of passing raw maps to Cubits. Trade-off: verbose mapping code versus predictable failure modes in UI.

**Source:**

- [`apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service.dart)
- [`apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_security_showcase_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/method_channel_native_security_showcase_service.dart)
- [`apps/mobile/lib/features/native_platform_showcase/data/native_security_channel_reply_mapper.dart`](../apps/mobile/lib/features/native_platform_showcase/data/native_security_channel_reply_mapper.dart)
- Native handlers: [`NativeShowcaseBridge.swift`](../apps/mobile/ios/Runner/NativeShowcaseBridge.swift), [`MainActivity.kt`](../apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/MainActivity.kt)
- Security handlers: [`NativeSecurityShowcaseHandler.swift`](../apps/mobile/ios/Runner/NativeSecurityShowcaseHandler.swift), [`NativeSecurityShowcaseHandler.kt`](../apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/NativeSecurityShowcaseHandler.kt)
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
(cd apps/mobile && flutter test \
  test/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service_test.dart \
  test/features/native_platform_showcase/data/method_channel_native_security_showcase_service_test.dart \
  test/features/native_platform_showcase/data/native_security_channel_reply_mapper_test.dart)
```

**Proof limits:** These Dart tests use `TestDefaultBinaryMessenger` mocks. They
prove arguments and reply mapping, not Swift/Kotlin execution, biometric prompts,
Keychain/Keystore hardware behavior, or real share sheets. The
[native reviewer guide](platforms/reviewer_guide.md) distinguishes host tests and
the opt-in iOS integration lane.

---

## 4. EventChannel: native telemetry stream

**Problem:** A telemetry stream can deliver malformed payloads, events from an
old session, or duplicate/out-of-order sequences. UI state needs validated data
and a recoverable stream-failure state.

**Design decision:** `EventChannelNativeShowcaseTelemetryService` validates
schema, session id, and monotonic sequence before emitting domain snapshots;
invalid events are dropped. Stream errors become failed telemetry state while
loaded data remains available. Trade-off: strict filtering rejects invalid
payloads but requires producer-side diagnostics to explain rejected events.

**Source:**

- [`apps/mobile/lib/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart)
- Cubit consumption: [`apps/mobile/lib/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart`](../apps/mobile/lib/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart)

**Tests:**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart) | `maps valid schema-v1 payload` |
| [`apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart) | `ignores stale session id` |
| [`apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart`](../apps/mobile/test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart) | `ignores sequence regression` |
| [`apps/mobile/test/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit_test.dart`](../apps/mobile/test/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit_test.dart) | `stream error becomes failed telemetry while loaded data remains` |

**Run:**

```bash
(cd apps/mobile && flutter test \
  test/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service_test.dart \
  test/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit_test.dart)
```

**Proof limits:** Service tests inject Dart streams. They do not measure native
producer timing, UI frame performance, or device lifecycle/background delivery.
macOS supports a subset of the showcase capabilities (see the showcase README).

---

## 5. FFI and PlatformView (native code interop)

**Problem:** Native interop must keep unsupported hosts usable: web cannot load
`dart:ffi`, and the mobile PlatformView has no desktop/web implementation.

**Design decision:** Conditional imports (`native_showcase_ffi_io.dart` /
`native_showcase_ffi_stub.dart`) keep FFI out of web builds. Android loads the
bundled native library; iOS and macOS resolve exported symbols from the process.
The PlatformView section shows a placeholder off mobile. Trade-off: separate
platform entry points and native build/link requirements.

**Source:**

- FFI: [`apps/mobile/lib/features/native_platform_showcase/data/ffi_native_showcase_native_code_service.dart`](../apps/mobile/lib/features/native_platform_showcase/data/ffi_native_showcase_native_code_service.dart), [`native/native_showcase/native_showcase.c`](../native/native_showcase/native_showcase.c), [`NativeShowcaseBridge.swift`](../apps/mobile/ios/Runner/NativeShowcaseBridge.swift)
- PlatformView UI: [`apps/mobile/lib/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section.dart`](../apps/mobile/lib/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section.dart)
- Related FFI demo (secure messaging): [`apps/mobile/lib/features/secure_messaging_demo/data/ffi_secure_core_repository.dart`](../apps/mobile/lib/features/secure_messaging_demo/data/ffi_secure_core_repository.dart)

**Tests and what they establish:**

| File | Test name |
| --- | --- |
| [`apps/mobile/test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart`](../apps/mobile/test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart) | `round trip maps UTF-8 and base64` |
| [`apps/mobile/test/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section_test.dart`](../apps/mobile/test/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section_test.dart) | `shows unavailable placeholder off mobile` |

The first test belongs to the **separate secure-messaging adapter** and uses an
injected native gateway. It proves UTF-8/base64 mapping, not loading or calling
the showcase's native library. The widget test proves the unsupported-host
placeholder, not actual UIKit/Android view rendering.

**Run:**

```bash
(cd apps/mobile && flutter test \
  test/features/secure_messaging_demo/data/ffi_secure_core_repository_test.dart \
  test/features/native_platform_showcase/presentation/widgets/native_platform_showcase_platform_view_section_test.dart)
```

**Live native verification:** The passing iOS smoke job above includes
[`native_platform_showcase_flow_test.dart`](../apps/mobile/integration_test/native_platform_showcase_flow_test.dart)
through the smoke suite. It uses the app's registered native services, runs the
P-256, AES-GCM, and secure-storage demo operations, and asserts
`Hello from Apple native FFI (21 + 21 = 42)` after running security operations.
Backend/auth dependencies remain controlled by the integration harness. This
proves the encoded native simulator flow; it does not establish native view pixel
rendering, telemetry producer timing, hardware-backed keys, biometric prompts,
or real share sheets. The
[native reviewer guide](platforms/reviewer_guide.md) documents how to run it.
Physical-device behavior and Android native execution require their own runs.

---

## Scope and limits

This repository is a **portfolio reference app** for interviews and technical review. It is **not** evidence of production scale, employer-specific tenure, or live user counts. Backend demos may require local configuration documented in [`.env.example`](../.env.example) and [feature scope](feature_overview.md).
