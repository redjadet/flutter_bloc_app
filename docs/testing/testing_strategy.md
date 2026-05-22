# Testing strategy (router)

TDD workflow index for agents. **Detail:** [`docs/testing_overview.md`](../testing_overview.md).

## RED → GREEN → REFACTOR

| Step | Action |
| --- | --- |
| RED | Write failing test for desired behavior |
| GREEN | Minimal code to pass |
| REFACTOR | Simplify; keep tests green |

## Layer → test type

| Layer | Prefer |
| --- | --- |
| Domain | Unit (pure logic, parsers) |
| Data | Unit with fakes; contract tests |
| Presentation | Widget tests; set viewport/size on layout-sensitive screens ([`widget_test_playbook.md`](widget_test_playbook.md)) |
| E2E | Integration / Patrol (when enabled) |

## AI test rules

1. Test behavior, not private implementation details.
2. One primary assertion per scenario when possible.
3. Use existing fakes under `test/` before new mocks.
4. Layout-sensitive widget tests: use `tester.view` sizing or overflow validators ([`widget_test_playbook.md`](widget_test_playbook.md)); do not add viewport setup to every widget test until a harness exists.
5. Non-trivial feature: fill [`FEATURE_TEMPLATE.md`](../plans/FEATURE_TEMPLATE.md) **Tests** section before broad implementation; done = those rows satisfied or documented N/A.
6. Feature-defined policy: [`testing_overview.md`](../testing_overview.md) § Feature-defined testing.

## Flaky prevention

1. Avoid `pumpAndSettle` without timeout on animated/async flows.
2. Stub time via injectable `TimerService` where used.
3. Do not depend on live network in unit/widget tests.

## Validation

- Fast lane: [`docs/engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
- Commands: [`docs/agents_quick_reference.md`](../agents_quick_reference.md)
