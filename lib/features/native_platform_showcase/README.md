# Native Platform Showcase

Educational demo that explains how Flutter apps integrate with each host platform. The page loads a static capability catalog **and** runs live interop demos:

| Bridge | Mechanism | Host code |
| --- | --- | --- |
| Dart → Swift | `MethodChannel` `com.example.flutter_bloc_app/native_showcase` | `ios/Runner/NativeShowcaseBridge.swift`, `macos/Runner/NativeShowcaseBridge.swift` |
| Dart → Kotlin | Same channel | `android/.../MainActivity.kt` |
| Dart → C/C++ | `dart:ffi` | `native/native_showcase/native_showcase.c` |

On web, host bridges report **unavailable**; FFI uses a stub. Desktop Linux/Windows link `native_showcase.c` in CMake. **iOS and macOS** expose FFI via Swift `@_cdecl` in `NativeShowcaseBridge.swift` only (the shared `.c` file is a project reference, not compiled—avoid duplicate `native_showcase_*` symbols). macOS registers the MethodChannel in `MainFlutterWindow.swift`.

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
Repository (NativePlatformInfoRepository)
        ↓  loadShowcase() → catalog + interopResults
Platform service ports (domain)
        ↓
Data adapters
        ↓
MethodChannel / dart:ffi / host native code
```

### Folder layout

```text
lib/features/native_platform_showcase/
├── domain/
│   ├── native_platform_info_repository.dart
│   ├── native_showcase_host_language_service.dart   # Swift / Kotlin port
│   ├── native_showcase_native_code_service.dart     # C/C++ port
│   ├── use_cases/load_native_platform_showcase_use_case.dart
│   └── … models (PlatformShowcaseData, NativeInteropCallResult, …)
├── data/
│   ├── method_channel_native_showcase_host_language_service.dart
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

1. Route (`createNativePlatformShowcaseRoute` in `lib/app/router/routes_demos.part.dart`) builds `NativePlatformShowcaseCubit(loadShowcase: getIt<LoadNativePlatformShowcaseUseCase>())` and calls `load()`.
2. `LoadNativePlatformShowcaseUseCase` → `NativePlatformInfoRepository.loadShowcase()`.
3. `NativePlatformInfoRepositoryImpl` resolves `AppPlatformKind` via `RuntimePlatformProbe`, maps static catalog, then awaits host-language calls and invokes native-code service.
4. Cubit emits `loaded(PlatformShowcaseData)` including `interopResults` for the interop section.

### DI (`registerNativePlatformShowcaseServices`)

Registered from `lib/core/di/groups/register_demo_services.dart`:

| Registration | Implementation |
| --- | --- |
| `NativeShowcaseHostLanguageService` | `MethodChannelNativeShowcaseHostLanguageService` |
| `NativeShowcaseNativeCodeService` | `FfiNativeShowcaseNativeCodeService` |
| `NativePlatformInfoRepository` | `NativePlatformInfoRepositoryImpl` (injects both services + probe) |
| `LoadNativePlatformShowcaseUseCase` | wraps repository |

Cubit is **not** in GetIt; only the use case is injected at the route.

### Interop paths

| Path | Domain port | Data adapter today | Host code | Future swap |
| --- | --- | --- | --- | --- |
| Swift | `NativeShowcaseHostLanguageService.invokeSwift()` | MethodChannel `invokeSwift` | `ios/Runner/NativeShowcaseBridge.swift`, `macos/Runner/…` | SwiftGen / generated bindings |
| Kotlin | `…invokeKotlin()` | MethodChannel `invokeKotlin` | `android/.../MainActivity.kt` | JNI / codegen |
| C/C++ | `NativeShowcaseNativeCodeService.invokeCpp()` | `dart:ffi` via `native_showcase_ffi_io.dart` | `native/native_showcase/native_showcase.c` | Same FFI surface; optional JVM bridge |

Channel name: `com.example.flutter_bloc_app/native_showcase` (showcase-only; not `lib/shared/platform/native_platform_service.dart`).

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
- **Live interop section** (`native-platform-showcase-interop-<kind>`)
- Four lesson cards (`native-platform-showcase-lesson-0` … `3`)
- Five capability tiles (`native-platform-showcase-capability-<kind>`) in `showcaseCapabilityOrder`

Capability titles and summaries use l10n extensions keyed by `NativeCapabilityKind`. Lesson copy lives in ARB files. English `platformDetail` strings come from `platformCapabilityCatalog`.

Error state uses `CommonErrorView` with `retryButtonKey: native-platform-showcase-retry`.

## Native rebuild note

Changing Swift, Kotlin, or C/C++ requires a **full rebuild** (not hot reload). FFI and MethodChannel handlers are registered at app startup.

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

## Related docs

- Feature brief: [`docs/changes/2026-06-08_native_platform_showcase_feature_brief.md`](../../../docs/changes/2026-06-08_native_platform_showcase_feature_brief.md)
- Integration journey: [`docs/engineering/integration_journey_map.md`](../../../docs/engineering/integration_journey_map.md) (J6)
- Testing matrix: [`docs/testing/matrix_required_by_change.md`](../../../docs/testing/matrix_required_by_change.md) (Example demo showcase)
