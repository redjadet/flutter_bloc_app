# Maintainability Slice 3 — presentation app config/bootstrap injection

**Date:** 2026-07-10  
**PR seam:** Rank 3 of [`docs/plans/2026-07-10_maintainability_program.md`](../plans/2026-07-10_maintainability_program.md)

## Goal

Remove remaining presentation imports of `app/config` / `app/bootstrap` that read static/singleton values. Router/composition resolves flags; presentation receives injected bools or feature-local types. `BackendAvailability` type imports stay (Slice 1 injected values).

## Changes

| Call site | Before | After |
| --- | --- | --- |
| `CounterPage` | `FlavorManager.I.flavor != Flavor.prod` | `showFlavorBadge` from router |
| `SettingsPage` | `FlavorManager.I.isDev \|\| isQa` | `showQaExtras` from router |
| `ExamplePage` | `FirebaseBootstrapService.isFirebaseInitialized` | `isFirebaseInitialized` from router |
| `FirebaseFunctionsTestPage` | same bootstrap static | `isFirebaseReady` from router |
| `CalculatorPage` | `AppConstants.compactHeightBreakpoint` | `LayoutBreakpoints.compactHeightBreakpoint` (design_system) |
| `IotBleCubit` | type from `app/config/iot_ble_runtime_config.dart` | type moved to `features/iot/domain/iot_ble_runtime_config.dart` |

## Proof

```bash
rg -n "package:flutter_bloc_app/app/(config|bootstrap)/" apps/mobile/lib/features --glob '**/presentation/**/*.dart'
# Expect: BackendAvailability only (chat + iot_demo_cloud_tab)
```

Focused tests + `./tool/analyze.sh` + modularity scripts as in plan.
