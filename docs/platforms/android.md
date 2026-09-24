# Android platform notes (showcase)

**Audience:** Readers following the native pillar who need Android host pointers.  
**Canonical interop rules:** [`native_interop.md`](native_interop.md).  
**Feature architecture:** [`../../apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md).

## What this page owns

Android/Kotlin **host file map** and packaging notes for the native showcase.
Capability/fidelity tables live in [`README.md`](README.md) — do not copy them.

## Host surfaces

| Concern | Path |
| --- | --- |
| MethodChannel registration | `apps/mobile/android/app/src/main/kotlin/com/ilkersevim/blocflutter/MainActivity.kt` |
| EventChannel telemetry | `.../NativeShowcaseTelemetryStreamHandler.kt` |
| PlatformView banner | `.../NativeShowcaseBannerPlatformView.kt` |
| Security demo handler | `.../NativeSecurityShowcaseHandler.kt` |
| FFI CMake wiring | `apps/mobile/android/app/src/main/cpp/CMakeLists.txt` |
| Shared C sources | `native/native_showcase/native_showcase.{c,h}` |

Channel names and method tables: feature README (single source).

## Fidelity notes (Android)

- Live: MethodChannel host calls, haptic, share chooser, EventChannel telemetry
  (HandlerThread aggregation), PlatformView banner, CMake-linked FFI library.
- Telemetry uses a background task queue; contract and schema:
  [`../performance/native_event_channel_telemetry.md`](../performance/native_event_channel_telemetry.md).
- Full rebuild required after changing Kotlin handlers or PlatformView factories.

## Tooling

- Open `apps/mobile/android` (Gradle **9.6.x**), not vendored Screengrab samples.
- JDK **17 or 21** (not system Java 25) — see
  [`../new_developer_guide.md`](../new_developer_guide.md).

## Related

- iOS twin: [`ios.md`](ios.md).
- Play release SOP (ops, not interop teaching):
  [`../engineering/android_play_store_release_sop.md`](../engineering/android_play_store_release_sop.md).
