# Native Platform Showcase

Educational demo that explains how Flutter apps integrate with each host platform. The page loads a static capability catalog **and** runs live interop demos:

| Bridge | Mechanism | Host code |
| --- | --- | --- |
| Dart → Swift | `MethodChannel` `com.example.flutter_bloc_app/native_showcase` (`invokeSwift`, `triggerHaptic`, `shareText`) | `ios/Runner/AppDelegate.swift`, `NativeShowcaseBridge.swift` |
| Dart → Kotlin | Same channel (`invokeKotlin`, `triggerHaptic`, `shareText`) | `android/.../MainActivity.kt` |
| Dart → C/C++ | `dart:ffi` | `native/native_showcase/native_showcase.c` |
| Native telemetry stream | `EventChannel` `com.example.flutter_bloc_app/native_showcase/telemetry` | `NativeShowcaseTelemetryStreamHandler` on Android / iOS / macOS |
| Native platform view | `UiKitView` / `AndroidView` viewType `com.example.flutter_bloc_app/native_showcase_banner` | `NativeShowcaseBannerPlatformView` (iOS/Android) |

On web, host bridges report **unavailable**; FFI uses a stub; PlatformView shows a placeholder. Desktop Linux/Windows link `native_showcase.c` in CMake. **iOS and macOS** expose FFI via Swift `@_cdecl` in `NativeShowcaseBridge.swift` only (the shared `.c` file is a project reference, not compiled—avoid duplicate `native_showcase_*` symbols). macOS registers the MethodChannel in `MainFlutterWindow.swift` for `invokeSwift` / telemetry only — haptic, share, and PlatformView are mobile-only.

## Entry points

- Example page button (`example-native-platform-showcase-button`)
- Route: `/native-platform-showcase` (`AppRoutes.nativePlatformShowcase`)
- Deep link segment: `native-platform-showcase`
- Counter Explore → Example tab (same button; no platform guard on route or entry)

## Architecture

Native access stays out of UI and Cubit. Presentation and domain depend on **ports** only; data supplies MethodChannel / FFI today and can swap to JNI, SwiftGen, or regenerated bindings without changing cubit or use case signatures.

```text
Presentation (Page, Cubit)
        ↓  LoadNativePlatformShowcaseUseCase
        ↓  WatchNativeShowcaseTelemetryUseCase
        ↓  TriggerNativeShowcaseHapticUseCase / ShareNativeShowcaseTextUseCase
Repository (NativePlatformInfoRepository)
        ↓  loadShowcase() → catalog + interopResults
Platform service ports (domain)
        ↓
Data adapters
        ↓
MethodChannel / EventChannel / dart:ffi / host native code
(+ PlatformView widget → native factory; no Cubit)
```

### Folder layout

```text
lib/features/native_platform_showcase/
├── domain/
│   ├── native_platform_info_repository.dart
│   ├── native_showcase_host_language_service.dart   # Swift / Kotlin port
│   ├── native_showcase_native_code_service.dart     # C/C++ port
│   ├── native_showcase_telemetry_service.dart       # EventChannel port
│   ├── use_cases/load_native_platform_showcase_use_case.dart
│   ├── use_cases/watch_native_showcase_telemetry_use_case.dart
│   ├── use_cases/trigger_native_showcase_haptic_use_case.dart
│   └── use_cases/share_native_showcase_text_use_case.dart
├── data/
│   ├── method_channel_native_showcase_host_language_service.dart
│   ├── event_channel_native_showcase_telemetry_service.dart
│   ├── ffi_native_showcase_native_code_service.dart
│   ├── native_showcase_ffi_{io,stub,bindings}.dart
│   ├── native_platform_info_repository_impl.dart
│   ├── platform_capability_catalog.dart
│   ├── platform_showcase_mapper.dart
│   ├── runtime_platform_probe.dart
│   └── simulated_native_platform_info_repository.dart   # catalog-only tests
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

| Layer | Key types | Notes |
| --- | --- | --- |
| `presentation/` | `NativePlatformShowcaseCubit`, page, interop section | Cubit calls use case only; no `MethodChannel` / FFI imports |
| `domain/` | `LoadNativePlatformShowcaseUseCase`, repository + platform ports | Pure Dart; defines interop contracts |
| `data/` | `NativePlatformInfoRepositoryImpl`, channel + FFI services | Merges `mapShowcase(probe)` with live interop calls |

### Load flow

1. Route (`createNativePlatformShowcaseRoute` in `lib/app/router/routes_demos.part.dart`) builds `NativePlatformShowcaseCubit` with load, telemetry, haptic, and share use cases, then calls `load()`.
2. `LoadNativePlatformShowcaseUseCase` → `NativePlatformInfoRepository.loadShowcase()`.
3. `NativePlatformInfoRepositoryImpl` resolves `AppPlatformKind` via `RuntimePlatformProbe`, maps static catalog, then awaits host-language calls and invokes native-code service.
4. Cubit emits `loaded(PlatformShowcaseData)` including `interopResults` for the interop section.
5. After successful load, Cubit subscribes once to `WatchNativeShowcaseTelemetryUseCase` and updates only the `telemetry` field on the loaded state (preserving any action feedback).
6. Haptic / share buttons call Cubit actions that update `lastAction` / `lastActionResult` without restarting telemetry.
7. PlatformView section embeds the native banner on iOS/Android via viewType `com.example.flutter_bloc_app/native_showcase_banner`.

### Mobile MethodChannel commands

| Method | Args | Success |
| --- | --- | --- |
| `triggerHaptic` | none | acknowledgement `String` |
| `shareText` | `{ "text": String }` | acknowledgement after sheet/chooser presented |

### Telemetry stream (EventChannel)

Channel: `com.example.flutter_bloc_app/native_showcase/telemetry`

Native side samples at 60 Hz on a background worker, aggregates into compact maps every 250 ms (4 Hz), and emits via `EventChannel`. Dart maps payloads in `EventChannelNativeShowcaseTelemetryService`. Unsupported platforms receive one `unavailable` snapshot. UI uses `NativePlatformShowcaseTelemetrySection` with `TypeSafeBlocSelector` so telemetry ticks do not rebuild static showcase content.

**Full rebuild required** after changing Swift/Kotlin handlers or PlatformView factories (hot reload is not enough).

### DI (`registerNativePlatformShowcaseServices`)

Registered from `lib/app/composition/groups/register_demo_services.dart` via
`lib/app/composition/features/register_native_platform_showcase_services.dart`:

| Registration | Implementation |
| --- | --- |
| `NativeShowcaseHostLanguageService` | `MethodChannelNativeShowcaseHostLanguageService` |
| `NativeShowcaseNativeCodeService` | `FfiNativeShowcaseNativeCodeService` |
| `NativePlatformInfoRepository` | `NativePlatformInfoRepositoryImpl` (injects both services + probe) |
| `LoadNativePlatformShowcaseUseCase` | wraps repository |
| `NativeShowcaseTelemetryService` | `EventChannelNativeShowcaseTelemetryService` |
| `WatchNativeShowcaseTelemetryUseCase` | wraps telemetry service |
| `TriggerNativeShowcaseHapticUseCase` | wraps host language service |
| `ShareNativeShowcaseTextUseCase` | wraps host language service |

Cubit is **not** in GetIt; use cases are injected at the route.

### Interop paths

| Path | Domain port | Data adapter today | Host code | Future swap |
| --- | --- | --- | --- | --- |
| Swift | `NativeShowcaseHostLanguageService.invokeSwift()` | MethodChannel `invokeSwift` | `ios/Runner/NativeShowcaseBridge.swift`, `macos/Runner/…` | SwiftGen / generated bindings |
| Kotlin | `…invokeKotlin()` | MethodChannel `invokeKotlin` | `android/.../MainActivity.kt` | JNI / codegen |
| C/C++ | `NativeShowcaseNativeCodeService.invokeCpp()` | `dart:ffi` via `native_showcase_ffi_io.dart` | `native/native_showcase/native_showcase.c` | Same FFI surface; optional JVM bridge |

Channel name: `com.example.flutter_bloc_app/native_showcase`; this bridge is
showcase-specific and not a general platform-service abstraction.

### `RuntimePlatformProbe`

Maps Flutter runtime signals to `AppPlatformKind`:

- Optional ctor overrides: `isWeb`, `platform` (initializing formals; used in unit tests)
- Defaults: `kIsWeb`, `defaultTargetPlatform`
- Production DI uses `const RuntimePlatformProbe()` with no overrides

### Test doubles

- **Global widget/unit harness:** `test/flutter_test_config.dart` calls `registerNativeShowcaseChannelMock()` so any test that pumps the showcase route does not hang on the live channel. Do not register the mock again in individual test files.
- **Repository unit tests:** mock `NativeShowcaseHostLanguageService` and `NativeShowcaseNativeCodeService`.
- **Catalog-only:** `SimulatedNativePlatformInfoRepository` (no live interop; mapper + probe only; **not** wired in production DI).
- **Cubit / page tests:** mock `LoadNativePlatformShowcaseUseCase` or inject full stack with fakes.

## UI

- `CommonPageLayout` shell
- Platform summary card (`native-platform-showcase-summary`)
- **Telemetry stream section** (`native-platform-showcase-telemetry`, selector-isolated)
- **Live interop section** (`native-platform-showcase-interop-<kind>`)
- Four lesson cards (`native-platform-showcase-lesson-0` … `3`)
- Five capability tiles (`native-platform-showcase-capability-<kind>`) in `showcaseCapabilityOrder`

Capability titles and summaries use l10n extensions keyed by `NativeCapabilityKind`. Lesson copy lives in ARB files. English `platformDetail` strings come from `platformCapabilityCatalog`.

Error state uses `CommonErrorView` with `retryButtonKey: native-platform-showcase-retry`.

## Native rebuild note

Changing Swift, Kotlin, or C/C++ requires a **full rebuild** (not hot reload). FFI, MethodChannel, and EventChannel handlers are registered at app startup.

## Tests

### Unit / widget

```bash
flutter test test/features/native_platform_showcase/
```

Also covered: `app_routes_test`, `routes_demos_includes_iap_test`, deep link parser/extensions, Example page body.

### Integration (device)

- Flow: `registerNativePlatformShowcaseIntegrationFlow()` in `integration_test/flow_scenarios_secondary.dart`
- Registered in smoke tier (`registerSmokeIntegrationFlows`)
- Dedicated target: `integration_test/native_platform_showcase_flow_test.dart`
- Selective map: rule `native_platform_showcase` in `tool/integration_selective_map.json`
- Path: launch app → Example → showcase button → summary, live interop tiles (swift/kotlin/cpp), lesson 0, platform label, Material/Cupertino family

```bash
./tool/run_integration_tests.sh integration_test/native_platform_showcase_flow_test.dart
```

### Web (preflight lane)

`integration_test` does not run on web. Browser coverage lives in `test/integration_preflight/web_bootstrap_smoke_test.dart` (included in `./bin/integration_preflight`). Prefer the preflight script over ad-hoc `-d chrome` runs when `kIsWeb` is unreliable on the host.

```bash
./bin/integration_preflight
# or narrow:
flutter test test/integration_preflight/web_bootstrap_smoke_test.dart
```

Test `opens native platform showcase from Example on web` asserts title, summary, runtime/UI labels, and lesson 0. It does **not** assert a specific host OS string (widget-test web often reports the host desktop platform).

## Native security showcase (nested, no new route)

A second `NativeSecurityShowcaseCubit` is nested (via `MultiBlocProvider`) under the
same `/native-platform-showcase` route and renders a five-card section
(`NativeSecurityShowcaseSection`) after the platform summary card. It demonstrates
native crypto, TLS pin policy, secure storage, App Check attestation, and biometric
gating **without ever surfacing key material, tokens, ciphertext, or certificates**.

| Card (key `native-security-card-…`) | Demonstrates | Native call |
| --- | --- | --- |
| `crypto` | P-256 sign/verify **and** AES-GCM round trip (two separate buttons: `native-security-run-crypto`, `native-security-run-aes`) | `p256SignVerify`, `aesGcmRoundTrip` |
| `certificate` | Reads existing `CertificatePinningConfig` → mode/hash/host/total-pin counts only (no inferred primary/backup role); opens the mutable pinning demo (`native-security-open-certificate-demo`) only when `!kReleaseMode && !FlavorManager.I.isProd` | none (local mapping) |
| `storage` | Secure storage write → read → delete lifecycle (`native-security-run-storage`) | `secureStorageLifecycle` |
| `app-check` | Cached Firebase App Check token acquisition evidence only (`native-security-run-app-check`). Missing Console registration → calm **Setup needed** panel with guidance (expected demo state, not a crash). Token never shown. | `FirebaseAppCheck.instance.getToken(false)` |
| `biometric` | Biometric-gated native operation (`native-security-run-biometric`) | `biometricProtectedOperation` |

### Channel + wire format

Channel: `com.example.flutter_bloc_app/native_security_showcase` (separate from the
`native_showcase` interop channel above). Methods: `p256SignVerify`,
`aesGcmRoundTrip`, `secureStorageLifecycle`, `biometricProtectedOperation`. Every
reply is a `Map` with `schemaVersion: 1`; anything else (non-map, missing/unsupported
version, unknown `status`) is rejected by `NativeSecurityChannelReplyMapper` and
mapped to `failed`/`malformed_reply`. Statuses: `success | unavailable | denied |
failed`. Off Android/iOS the Dart adapter (`MethodChannelNativeSecurityShowcaseService`)
short-circuits to `unavailable`/`mobile_only` **before** invoking the channel.
Non-interactive crypto/storage calls use a **2s** client timeout; biometric uses a
**60s** timeout so Face ID / fingerprint prompts are not falsely mapped to
`unavailable`/`timeout` while the OS dialog is still open.

### Security stack

```text
Presentation (NativeSecurityShowcaseCubit, section widgets)
        ↓  RunNativeSecurityOperationUseCase / ProbeAppCheckAttestationUseCase
        ↓  LoadCertificatePinPolicySummaryUseCase
domain/ ports: NativeSecurityShowcaseService, FirebaseAppCheckAttestationService
        ↓
data/ adapters: MethodChannelNativeSecurityShowcaseService,
        FirebaseAppCheckAttestationServiceImpl, CertificatePinPolicySummaryMapper
        ↓
MethodChannel `native_security_showcase` / Firebase App Check SDK / CertificatePinningConfig
```

`LoadCertificatePinPolicySummaryUseCase` takes a `CertificatePinPolicySummaryBuilder`
function (typedef) rather than importing the data-layer mapper directly; the
composition root injects `CertificatePinPolicySummaryMapper.fromConfig`.

The Cubit tracks a shared busy gate (`inFlight` for native ops + `appCheckInFlight`
for App Check) so all run buttons disable together while any probe is active.
Duplicate `run*` / App Check calls while busy are ignored. Each card's result is
stored on its own state field so running one operation never clears another card's
prior outcome, and the Cubit never emits after `isClosed`.

### DI additions (`registerNativePlatformShowcaseServices`)

| Registration | Implementation |
| --- | --- |
| `NativeSecurityShowcaseService` | `MethodChannelNativeSecurityShowcaseService` |
| `FirebaseAppCheckAttestationService` | `FirebaseAppCheckAttestationServiceImpl` |
| `RunNativeSecurityOperationUseCase` | wraps `NativeSecurityShowcaseService` |
| `ProbeAppCheckAttestationUseCase` | wraps `FirebaseAppCheckAttestationService` |
| `LoadCertificatePinPolicySummaryUseCase` | wraps `CertificatePinPolicySummaryMapper.fromConfig` |

`NativeSecurityShowcaseCubit` itself is **not** in GetIt; it is built at the route
(`createNativePlatformShowcaseRoute`) alongside the parent
`NativePlatformShowcaseCubit`, both provided via `MultiBlocProvider`.

### No-secrets guarantee

The reply mapper only copies allowlisted keys (status, reason code, platform,
booleans, counts, algorithm/residency labels); raw key bytes, ciphertext, tokens, and
certificates never cross the channel. `FirebaseAppCheckAttestationServiceImpl` calls
`getToken(false)` (never `forceRefresh: true`), discards the token string
immediately, and only reports `issued`/`unavailable`/`failed` + a configured-provider
label. The
certificate card exposes counts and mode names from `CertificatePinningConfig`, never
raw pin hashes.

### Native host modules (Tasks 5–6)

Android and iOS handlers are wired on channel
`com.example.flutter_bloc_app/native_security_showcase`:

| Host | File | Primitives |
| --- | --- | --- |
| Android | `NativeSecurityShowcaseHandler.kt` | Keystore P-256 + AES-GCM, Keystore-backed sentinel prefs, `BiometricPrompt` (`BIOMETRIC_STRONG`); host is `FlutterFragmentActivity` |
| iOS | `NativeSecurityShowcaseHandler.swift` | Secure Enclave P-256 (else `secure_enclave_unavailable`), Keychain AES-GCM + sentinel, `LAContext` + `.biometryCurrentSet` |

Expected non-device outcomes (valid, not crashes): iOS Simulator may return
`unavailable`/`secure_enclave_unavailable` for P-256; biometrics may be
`unavailable`/`denied` without enrollment. Physical-device biometric + hardware-backed
crypto proof remains Follow-up.

## Related docs

- Feature brief: [`docs/changes/2026-06-08_native_platform_showcase_feature_brief.md`](../../../../../docs/changes/2026-06-08_native_platform_showcase_feature_brief.md)
- Native security showcase change note: [`docs/changes/2026-07-15_native_security_showcase.md`](../../../../../docs/changes/2026-07-15_native_security_showcase.md)
- Integration journey: [`docs/engineering/integration_journey_map.md`](../../../../../docs/engineering/integration_journey_map.md) (J6)
- Testing matrix: [`docs/testing/matrix_required_by_change.md`](../../../../../docs/testing/matrix_required_by_change.md) (Example demo showcase)
