# Integration tests for app flows

This document explains how integration flows are structured and how to add new ones.

## Files and harness

- Entrypoints:
  - `integration_test/all_flows_test.dart` registers every flow.
  - `integration_test/pr_smoke_flows_test.dart` registers the smaller PR CI smoke suite.
  - `integration_test/smoke_flows_test.dart` registers the broader local smoke suite.
  - `integration_test/extended_flows_test.dart` registers heavier persistence, refresh, and filter scenarios.
- Flow registration and helpers:
  - `integration_test/flow_scenarios.dart`
  - `integration_test/flow_scenarios_primary.dart`
  - `integration_test/flow_scenarios_secondary.dart`
  - `integration_test/flow_scenarios_helpers.dart`
- Pump helpers (re-exported from `test_harness.dart` for flow code):
  - `integration_test/widget_tester_pumps.dart` — `pumpUntilFound`, `pumpUntilAbsent`, bounded `pumpSettleWithin` (prefer over unbounded `pumpAndSettle()`), `tapAndPump`, and after a `WidgetTester.fling` use `pumpAfterScrollFling` / `pumpUntilScrollIdle` so the next gesture does not stack on in-flight scroll physics.

Each flow is registered via:

```dart
registerIntegrationFlow(
  groupName: 'Feature flow',
  testName: 'describes the scenario',
  body: (final tester) async {
    // Launch app, navigate, interact, assert
  },
);
```

## Anchor flows

The anchor features (`settings`, `todo_list`) have multiple integration scenarios:

- **Settings**
  - `registerSettingsIntegrationFlow`: opens settings and applies theme + locale changes.
  - `registerSettingsThemePersistenceIntegrationFlow`: verifies theme + locale persist after navigating away and back.
- **Todo list**
  - `registerTodoListIntegrationFlow`: opens todo list, adds a todo, and verifies it appears in the list.
  - `registerTodoListFilterIntegrationFlow`: adds todos, completes one, and verifies active/completed filters.

Use these flows as templates when adding new feature flows.

## Adding a new integration flow

1. **Choose a file**
   - For navigation or cross-feature flows, use `flow_scenarios_primary.dart`.
   - For feature-specific flows, use `flow_scenarios_secondary.dart`.

2. **Register the flow**

   - Create a new `registerXIntegrationFlow()` function that:
     - Calls `launchTestApp(tester)` to start the app.
     - Uses helpers from `flow_scenarios_helpers.dart` (for example `_openExampleDestination`, `_openOverflowDestination`) plus `tapAndPump` / `pumpUntilFound` / `pumpUntilAbsent` / `pumpSettleWithin` from `widget_tester_pumps.dart` (via `test_harness.dart`) to navigate and wait without unbounded settles.
     - Performs a small number of interactions (1–2 key actions).
     - Asserts on visible text/widgets using `find.text`, `find.byTooltip`, or stable keys/types.

3. **Wire it into the entrypoint**

   - Ensure `all_flows_test.dart` (via `flow_scenarios.dart`) calls your new `registerXIntegrationFlow()` so it runs as part of the full suite.
   - Decide whether it belongs in the PR smoke suite, the broader local smoke suite, the extended suite, or multiple entrypoints.

4. **Run tests locally**

   - Use a specific device:

     ```bash
     flutter test -d <deviceId> integration_test/all_flows_test.dart
     ```

   - Or run a single flow’s test file (for example `integration_test/todo_list_flow_test.dart`) as described in `docs/testing_overview.md`.

## Policy constraints (don’t skip)

- New integration scenarios should map to a named journey in
  [`docs/engineering/integration_journey_map.md`](engineering/integration_journey_map.md).
- New flows should declare an intended tier (`smoke`, `standard`, `exhaustive`).
  See [`docs/engineering/integration_test_policy.md`](engineering/integration_test_policy.md).
- Runner behavior, tiers, and artifacts are defined in
  [`docs/engineering/integration_runner_contract.md`](engineering/integration_runner_contract.md).

## Runtime and CI notes

- Integration tests should remain short and focused; prefer multiple small flows over one very long scenario.
- Keep the smallest high-signal PR checks in `pr_smoke_flows_test.dart`.
- Keep the broader local smoke suite in `smoke_flows_test.dart`.
- Move heavier persistence, refresh, filter, or multi-navigation scenarios to `extended_flows_test.dart`.
