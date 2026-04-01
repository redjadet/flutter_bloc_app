# Integration Journey Map

This map links must-have user journeys to executable integration targets and
tier expectations.

## J1 Auth/session lifecycle

- **Goal:** App launch + session-safe navigation behavior.
- **Primary target:** `integration_test/standard_flows_test.dart`
- **Negative path:** stale session behavior during navigation guarded by app
  state assertions.
- **Tier:** `standard`, `exhaustive`
- **Owner:** feature QA owner

## J2 Core CRUD flow

- **Goal:** Todo add/filter/completion end-to-end.
- **Primary target:** `integration_test/todo_list_flow_test.dart`
- **Negative path:** completed vs active filtering check.
- **Tier:** `smoke`, `standard`, `exhaustive`
- **Owner:** feature QA owner

## J3 Offline to online recovery

- **Goal:** state restoration/persistence continuity through app lifecycle.
- **Primary target:** `integration_test/counter_persistence_test.dart`
- **Negative path:** rebuild and restore verification.
- **Tier:** `standard`, `exhaustive`
- **Owner:** feature QA owner

## J4 Error + retry user path

- **Goal:** visible empty/error handling and user recovery path.
- **Primary target:** `integration_test/search_flow_test.dart`
- **Negative path:** empty-result state assertion.
- **Tier:** `standard`, `exhaustive`
- **Owner:** feature QA owner

## Aggregate mapping

- `smoke` -> `integration_test/smoke_flows_test.dart`
- `standard` -> `integration_test/standard_flows_test.dart`
  (`registerStandardIntegrationFlows`: smoke + extended; see `flow_scenarios.dart`)
- `exhaustive` -> `integration_test/all_flows_test.dart`
  (`registerAllIntegrationFlows`: standard plus `registerExhaustiveOnlyIntegrationFlows`,
  including deterministic GraphQL network error + **Try again** recovery)

## CI workflow shape

Integration jobs run only from **Actions → CI → Run workflow** (not on push/PR).
See [`validation_scripts.md`](validation_scripts.md) for the current GitHub Actions contract.

## Notes

- Keep aggregate suite as canonical gate.
- Add new integration tests by first attaching them to one journey and one tier.
