# Todo list rebuild remeasure — 2026-08-10

## Feature: TODO-REBUILD-01

### Device (same as baseline)

- iPhone 17 Pro simulator `3439532F-5E88-4860-A9E8-A020EACA656C` / iOS 26.5

### After narrow selectors

- `TodoListLifecycleData` / `TodoListListProjection` / `TodoListSelectionData` nest under the Todo page/body.
- Widget harness: selection-only emit keeps list-projection build count stable; selection builder increments (`todo_list_rebuild_isolation_test.dart`).
- Focused page + cubit tests green; shrinkWrap / non-builder / widget-identity / lifecycle / unnecessary-rebuild scripts pass.

### Acceptance

**Accept** — rebuild evidence improves vs baseline wide `TodoListViewData` path for selection-only updates; behavior tests green.

Interactive DevTools Timeline on a signed-in 100+ Hive store remains optional follow-up (no durable seed harness).
