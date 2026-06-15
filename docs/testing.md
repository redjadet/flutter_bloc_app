# Testing (entry hub)

> **Do not duplicate** — this page links to canonical docs. Edit the targets, not this hub.

Routing for unit, widget, golden, and integration validation. For matrix-by-change-type, see [testing/matrix_required_by_change.md](testing/matrix_required_by_change.md).

## Start here

- [testing_overview.md](testing_overview.md) — policy, layers, when to add tests
- [testing/matrix_required_by_change.md](testing/matrix_required_by_change.md) — required tests by change type
- [testing/widget_test_playbook.md](testing/widget_test_playbook.md) — widget test patterns
- [engineering/integration_test_policy.md](engineering/integration_test_policy.md) — integration scope and tiers
- [engineering/integration_runner_contract.md](engineering/integration_runner_contract.md) — `./bin/integration_tests` contract
- [engineering/validation_routing_fast_vs_full.md](engineering/validation_routing_fast_vs_full.md) — fast vs full checklist routing
- [validation_scripts.md](validation_scripts.md) — script catalog and delivery gate

## Common commands

- Narrow: `flutter test <path>` + `./tool/analyze.sh`
- Docs/tooling sanity: `./bin/checklist-fast --no-reuse`
- Pre-ship: `./bin/checklist` / `./tool/delivery_checklist.sh`
