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

### Physical device `--profile` + DevTools (operator)

- Device: **İlker iPhone Pro** `00008120-001144943C83C01E` / iOS 26.6
- Launch: `flutter run --profile --no-pub -d 00008120-001144943C83C01E --dart-define=SEED_TODO_COUNT=120 --dart-define=PROFILE_INITIAL_ROUTE=/todo-list`
- Session: VM Service + DevTools connected after prior hang (Xcode/lldb cleared); Impeller; `arm64 ios`
- Operator exercised Todo List interactions on-device; post-session DevTools Performance review:
  - Flutter frames average ~**119 FPS** (120Hz budget line at 8ms)
  - Visible UI+Raster bars mostly **&lt;3ms**; no jank bars in the reviewed frame window
  - Timeline Events showed dense PipelineItem/POST_FRAME activity then settle; sparse SceneDisplayLag marks only
  - DTD `get_runtime_errors`: **none**
  - Console log: clean install/launch; no app exceptions recorded in `flutter run` log
- Throwaway `SEED_TODO_COUNT` / `PROFILE_INITIAL_ROUTE` were compile-time only for the session binary; not retained in `lib/`.

### Acceptance

**Accept** — selection isolation holds in harness + simulator Hive≥100 Timeline; physical-device profile DevTools after operator testing shows no frame-budget distress on Impeller/iOS.
