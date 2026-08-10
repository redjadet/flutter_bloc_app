# Todo list rebuild remeasure — 2026-08-10

## Feature: TODO-REBUILD-01

### Device (same as baseline)

- iPhone 17 Pro simulator `3439532F-5E88-4860-A9E8-A020EACA656C` / iOS 26.5

### After narrow selectors

- `TodoListLifecycleData` / `TodoListListProjection` / `TodoListSelectionData` nest under the Todo page/body.
- Widget harness: selection-only emit keeps list-projection build count stable; selection builder increments (`todo_list_rebuild_isolation_test.dart`).
- Focused page + cubit tests green; shrinkWrap / non-builder / widget-identity / lifecycle / unnecessary-rebuild scripts pass.

### Hive ≥100 simulator Timeline (DevTools Performance channel)

Flutter **does not support `--profile` on iOS Simulator** (`Profile mode is not supported by iPhone 17 Pro`). Closest DevTools-equivalent capture on the plan device:

```bash
cd apps/mobile
flutter test --no-pub -d 3439532F-5E88-4860-A9E8-A020EACA656C \
  integration_test/perf/todo_list_hive_selection_profile_test.dart
```

- Store: real `HiveTodoRepository` (`hive_ios_debug`), seeded to **≥100** (target 120) before open.
- Interactions: open Todo List → select → deselect → 8× select toggle → scroll×4.
- Binding: `IntegrationTestWidgetsFlutterBinding.traceAction` Timeline (same events DevTools Performance uses).
- Frame spans (paired `Frame` begin/end): **n=22**, min 1.79ms, p50 4.14ms, p95 9.37ms, max **14.68ms**; **0** frames >16.67ms / >33.33ms.
- Local gitignored artifacts: `artifacts/perf/todo_list_hive_selection_profile_20260810.txt` + `_summary.json`.

Physical-device `--profile` attempt on `İlker iPhone Pro` built/installed but Dart VM Service discovery hung (device unlock / Xcode Automation prompt) — no interactive DevTools session completed there.

### Acceptance

**Accept** — rebuild evidence improves vs baseline wide `TodoListViewData` path for selection-only updates; behavior tests green; simulator Hive≥100 Timeline shows no frame-budget misses on selection/scroll after isolation.
