# Native interop contracts

**Audience:** Engineers implementing or reviewing Flutter ↔ host bridges.  
**Date:** 2026-09-24  
**Layering preference:** [`../agent_kb/operator_preferences_durable.md`](../agent_kb/operator_preferences_durable.md)
(Native interop layering).  
**Gold feature:**
[`../../apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md).

## Layering (must)

```text
Presentation (Cubit / widgets)
  → use cases
  → repository
  → domain platform-service ports
  → data adapters (MethodChannel / EventChannel / dart:ffi)
  → host Swift / Kotlin / C
```

Never import `MethodChannel`, `EventChannel`, or FFI bindings in Cubit or
widgets. PlatformView widgets may embed a viewType; they still must not own
channel I/O.

## Bridge kinds

| Kind | Dart adapter | Typical host |
| --- | --- | --- |
| Host language | `method_channel_native_showcase_host_language_service.dart` | Swift / Kotlin |
| Native code | `ffi_native_showcase_native_code_service.dart` (+ `*_io` / `*_stub`) | C / Swift `@_cdecl` |
| Telemetry stream | `event_channel_native_showcase_telemetry_service.dart` | Stream handlers |
| Platform view | viewType `.../native_showcase_banner` | UiKitView / AndroidView factories |

Fidelity by OS: [`README.md`](README.md#fidelity-matrix-what-actually-runs).

## Typed results (web / desktop stubs)

Interop calls return Freezed `NativeInteropCallResult` with:

- `NativeInteropBridgeKind` — which bridge was exercised  
- `NativeInteropStatus` — `success` | `unavailable` | `failed`  
- `message` — human-readable detail (never a raw platform exception dump in UI)

Related typed statuses:

| Surface | Type |
| --- | --- |
| Telemetry | `NativeShowcaseTelemetryStatus` (`unavailable` \| `streaming` \| `failed`) |
| Security demo | `NativeSecurityStatus` (`success` \| `unavailable` \| `denied` \| `failed`) |
| Page load error | `NativePlatformShowcaseFailureKind.loadFailed` |

**Web / unsupported:** adapters report `unavailable` (or a single unavailable
telemetry snapshot). FFI uses an io/stub split so web compiles against the stub
without linking C. Do not fake `success` on unsupported hosts.

Policy backdrop: typed errors / DTO boundaries in
[`../architecture/use_case_dto_policy.md`](../architecture/use_case_dto_policy.md).

## Adaptive presentation

Showcase chrome uses `NativePlatformShowcaseAdaptive` + real design-system
APIs only:

- `PlatformAdaptive.isCupertino` / `PlatformAdaptive.listTile`
- Material: `CommonCard`, `context.responsiveGapS`, theme text styles
- Cupertino: `CupertinoListSection` / `CupertinoListTile`

No new spacing/color tokens are introduced by this pack. Owner docs:
[`../design_system.md`](../design_system.md), [`../../DESIGN.md`](../../DESIGN.md).

## Tests

Focused coverage:
`apps/mobile/test/features/native_platform_showcase/`  
Channel mocks registered once via `registerNativeShowcaseChannelMock()` in
`test/flutter_test_config.dart` — do not re-register per file.

## Contrast: Rust secure core

Secure messaging uses a separate Rust FFI package
([`../architecture/rust_ffi_secure_core_bridge.md`](../architecture/rust_ffi_secure_core_bridge.md)).
Keep teaching narratives distinct: showcase C/Swift FFI ≠ secure_core_bridge.
