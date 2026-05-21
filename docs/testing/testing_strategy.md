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
| Presentation | Widget tests (`WidgetTester.view`) |
| E2E | Integration / Patrol (when enabled) |

## AI test rules

1. Test behavior, not private implementation details.
2. One primary assertion per scenario when possible.
3. Use existing fakes under `test/` before new mocks.
4. Widget tests: set viewport via `WidgetTester.view`.
5. Link Feature Brief test section before skipping coverage.

## Flaky prevention

1. Avoid `pumpAndSettle` without timeout on animated/async flows.
2. Stub time via injectable `TimerService` where used.
3. Do not depend on live network in unit/widget tests.

## Validation

- Fast lane: [`docs/engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md)
- Commands: [`docs/agents_quick_reference.md`](../agents_quick_reference.md)
