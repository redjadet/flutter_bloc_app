# Platforms teaching pack

**Audience:** Interviewers and engineers learning how this portfolio exercises
native iOS/Android interop without claiming every host API.
**Date:** 2026-09-24
**Pillar:** Native iOS & Android interop (Four pillars #3).
**Claim ledger:** [`../changes/2026-09-24_authority_phase_0_evidence_baseline.md`](../changes/2026-09-24_authority_phase_0_evidence_baseline.md).

This folder is the **canonical teaching home** for platform fidelity. Runnable
architecture detail stays in the gold feature README — do not duplicate it here.

| Doc | Owns |
| --- | --- |
| This README | Capability + fidelity matrices; non-goals; adaptive chrome pointer |
| [`ios.md`](ios.md) | iOS/Swift host surfaces for the showcase |
| [`android.md`](android.md) | Android/Kotlin host surfaces for the showcase |
| [`native_interop.md`](native_interop.md) | Bridge kinds, typed statuses, web/desktop stubs, layering |

**Code gold path:**
[`apps/mobile/lib/features/native_platform_showcase/README.md`](../../apps/mobile/lib/features/native_platform_showcase/README.md).

## Capability matrix

Static per-platform capability copy lives in code
([`platform_capability_catalog.dart`](../../apps/mobile/lib/features/native_platform_showcase/data/platform_capability_catalog.dart)).
Teaching summary:

| Capability | Android | iOS | macOS | Web | Linux/Windows |
| --- | --- | --- | --- | --- | --- |
| Native view embedding | Live banner (`AndroidView`) | Live banner (`UiKitView`) | Catalog only | Placeholder / HtmlElementView note | Catalog only |
| Package / tooling story | Gradle + Play | SPM | SPM | npm ecosystem (catalog) | Concept only |
| Host-language interop | Kotlin `MethodChannel` | Swift `MethodChannel` | Swift channel (subset) | Unavailable | FFI-oriented catalog |
| Low-level graphics story | Vulkan / Skia (catalog) | Metal (catalog) | Metal (catalog) | WebGL/WebGPU (catalog) | Vulkan/OpenGL (catalog) |
| Adaptive gestures story | Predictive back (catalog) | Edge swipe / haptics (catalog) | Trackpad (catalog) | Pointer (catalog) | Pointer (catalog) |

“Catalog” = educational text from the static matrix, not a live demo.

## Fidelity matrix (what actually runs)

Statuses come from `NativeInteropStatus` / telemetry / security enums
(`success` | `unavailable` | `failed` [+ domain-specific]). See
[`native_interop.md`](native_interop.md).

| Surface | iOS | Android | macOS | Web | Linux/Windows |
| --- | --- | --- | --- | --- | --- |
| MethodChannel host call | Live | Live | Live (`invokeSwift` / telemetry subset) | `unavailable` | N/A (no mobile host methods) |
| Haptic / share | Live | Live | Mobile-only → unavailable | `unavailable` | `unavailable` |
| EventChannel telemetry | Live (schema v1) | Live | Live | `unavailable` snapshot | `unavailable` |
| FFI C symbols | Swift `@_cdecl` exports | CMake `.so` | Swift exports (shared `.c` not dual-linked) | Stub | CMake-linked `.c` |
| PlatformView banner | Live | Live | Not registered | Placeholder | Not registered |

Contract for telemetry:
[`../performance/native_event_channel_telemetry.md`](../performance/native_event_channel_telemetry.md).
Rust FFI (separate demo):
[`../architecture/rust_ffi_secure_core_bridge.md`](../architecture/rust_ffi_secure_core_bridge.md).

## Adaptive chrome (showcase)

Presentation-only adaptive UI for the showcase:
[`native_platform_showcase_adaptive.dart`](../../apps/mobile/lib/features/native_platform_showcase/presentation/widgets/native_platform_showcase_adaptive.dart).

**What the code actually uses** (do not invent tokens here):

| Call site | Code truth |
| --- | --- |
| Family switch | `PlatformAdaptive.isCupertino(context)` (`packages/design_system`) |
| Capability rows | `PlatformAdaptive.listTile(...)` |
| Material summary | `CommonCard` + `context.responsiveGapS` + `ThemeData.textTheme` |
| Cupertino summary | `CupertinoListSection.insetGrouped` + `CupertinoListTile` |

Canonical design-system rules:
[`../design_system.md`](../design_system.md) (PlatformAdaptive + responsive gaps).
Visual brief: [`../../DESIGN.md`](../../DESIGN.md). Spine product screens use the
same shared helpers — they do **not** import the showcase adaptive helper.

## Non-goals (still)

| Item | Status | Artifact |
| --- | --- | --- |
| Background OS demo (WorkManager / BGTask) | Non-goal | [`../authority_scope_register.md`](../authority_scope_register.md) |
| Home-screen widgets | Non-goal | Same |
| Net-new native demos | Forbidden without Archive swap | [ADR-0005](../adr/0005-interview-showcase-scope.md) |

## Related

- Root README evidence table: [`../../README.md`](../../README.md#native-android-and-ios-engineering)
- Reference feature row: [`../architecture/reference_features.md`](../architecture/reference_features.md)
- CODEMAP native row: [`../../CODEMAP.md`](../../CODEMAP.md)
