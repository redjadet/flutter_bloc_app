# iOS platform notes (showcase)

**Audience:** Readers following the native pillar who need iOS host pointers.  
**Canonical interop rules:** [`native_interop.md`](native_interop.md).  
**Feature architecture:** [`../../apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md).

## What this page owns

iOS/Swift **host file map** and mobile-only caveats for the native showcase.
Capability/fidelity tables live in [`README.md`](README.md) — do not copy them.

## Host surfaces

| Concern | Path |
| --- | --- |
| MethodChannel registration | `apps/mobile/ios/Runner/AppDelegate.swift` |
| Bridge / FFI `@_cdecl` exports | `apps/mobile/ios/Runner/NativeShowcaseBridge.swift` |
| EventChannel telemetry | `apps/mobile/ios/Runner/NativeShowcaseTelemetryStreamHandler.swift` |
| PlatformView banner | `apps/mobile/ios/Runner/NativeShowcaseBannerPlatformView.swift` |
| Security demo handler | `apps/mobile/ios/Runner/NativeSecurityShowcaseHandler.swift` |

Channel names and method tables: feature README (single source).

## Fidelity notes (iOS)

- Live: MethodChannel host calls, haptic, share sheet, EventChannel telemetry,
  PlatformView banner, Swift-exported FFI symbols.
- The shared `native/native_showcase/native_showcase.c` is a **project
  reference only** on Apple targets — compiling it alongside Swift `@_cdecl`
  duplicates symbols. Prefer the Swift exports documented in the feature README.
- Full rebuild required after changing Swift handlers or PlatformView factories
  (hot reload is insufficient).

## Tooling

- Prefer Swift Package Manager for native deps (see
  [`../new_developer_guide.md`](../new_developer_guide.md)).
- CocoaPods remains available for existing Podfiles / plugin fallback.

## Related

- macOS subset: MethodChannel + telemetry in `MainFlutterWindow.swift`; haptic,
  share, and PlatformView are mobile-only.
- Android twin: [`android.md`](android.md).
