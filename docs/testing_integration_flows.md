# Integration tests for app flows

This document explains how integration flows are structured and how to add new ones.

## Files and harness

- Entrypoints:
  - `integration_test/all_flows_test.dart` registers every flow.
  - `integration_test/smoke_flows_test.dart` registers the PR smoke suite.
  - `integration_test/extended_flows_test.dart` registers heavier persistence, refresh, and filter scenarios.
- Flow registration and helpers:
  - `integration_test/flow_scenarios.dart`
  - `integration_test/flow_scenarios_primary.dart`
  - `integration_test/flow_scenarios_secondary.dart`
  - `integration_test/flow_scenarios_helpers.dart`

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
     - Uses helpers from `flow_scenarios_helpers.dart` (for example `_openExampleDestination`, `_openOverflowDestination`, `tapAndPump`, `pumpUntilFound`) to navigate.
     - Performs a small number of interactions (1–2 key actions).
     - Asserts on visible text/widgets using `find.text`, `find.byTooltip`, or stable keys/types.

3. **Wire it into the entrypoint**

   - Ensure `all_flows_test.dart` (via `flow_scenarios.dart`) calls your new `registerXIntegrationFlow()` so it runs as part of the full suite.
   - Decide whether it belongs in the PR smoke suite, the extended suite, or both.

4. **Run tests locally**

   - Use a specific device:

     ```bash
     flutter test -d <deviceId> integration_test/all_flows_test.dart
     ```

   - Or run a single flow’s test file (for example `integration_test/todo_list_flow_test.dart`) as described in `docs/testing_overview.md`.

## Runtime and CI notes

- Integration tests should remain short and focused; prefer multiple small flows over one very long scenario.
- Keep PR smoke coverage in `smoke_flows_test.dart`; move heavier persistence, refresh, filter, or multi-navigation scenarios to `extended_flows_test.dart`.
