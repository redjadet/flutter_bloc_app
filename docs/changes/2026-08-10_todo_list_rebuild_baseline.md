# Todo list rebuild baseline — 2026-08-10

## Feature: TODO-REBUILD-01 (measurement-gated presentation split)

### Device

- Name: iPhone 17 Pro (simulator)
- UDID: `3439532F-5E88-4860-A9E8-A020EACA656C`
- Runtime: iOS 26.5 (`com.apple.CoreSimulator.SimRuntime.iOS-26-5`)
- Profile attempt: `cd apps/mobile && flutter run --profile -d 3439532F-5E88-4860-A9E8-A020EACA656C` — unsupported on iOS Simulator.
- Item count for measurement: **120** (widget rebuild harness; no in-repo Hive seed)

### Evidence

1. **Structural (pre-fix):** `TodoListViewData.fromState` included `selectedItemIds` and called `state.filteredItems` on every Cubit emission; `_TodoListBody` used one wide `ViewStatusSwitcher`, so selection rebuilt header + list shell.
2. **Rebuild counts (widget harness):** nested `TodoListListProjection` / `TodoListSelectionData` selectors — selection-only emit keeps `listBuildCount == 1` and increments selection builder only (`todo_list_rebuild_isolation_test.dart`).
3. **Device check:** simulator booted and listed via `flutter devices` before implementation. Flutter rejected `--profile` on the simulator; GO used structural rebuild evidence instead.

### Interaction matrix (expected hotspot pre-fix)

| Interaction | Hot? |
| --- | --- |
| Single-row select / deselect | Yes — wide body + filteredItems |
| Search / filter / sort | Expected list change |
| Completion toggle | Row + stats |
| Manual reorder | Expected |
| Pull-to-refresh | Expected |

### Decision

**GO** — selection-only emissions rebuilt unrelated Todo presentation and recomputed filtered rows via the wide selector (plan criterion 2). Proceed with narrow projections.

### Proof commands

```bash
cd apps/mobile
flutter test test/features/todo_list/presentation/pages/todo_list_rebuild_isolation_test.dart
xcrun simctl list devices available | rg "iPhone 17 Pro"
flutter devices
```
