# Testing Overview

This document describes the repo's testing layers, validation commands, and the
current integration suite layout. It complements the shell validators described
in [Validation Scripts](validation_scripts.md).

For the complete docs index, see [docs index](README.md).

## Source of truth

- Coverage report: [`coverage/coverage_summary.md`](../coverage/coverage_summary.md)
- Integration flow structure: [Integration Flow Guide](testing_integration_flows.md)
- Validation scripts: [Validation Scripts](validation_scripts.md)
- CI workflow: [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)

## Integration docs (policy and contracts)

If you are adding or changing integration coverage, these documents define the
expected structure and “ownership” contract:

- [Integration test policy](engineering/integration_test_policy.md)
- [Integration journey map](engineering/integration_journey_map.md)
- [Integration runner contract](engineering/integration_runner_contract.md)

## Quality gates

| Command | Purpose |
| --- | --- |
| `./tool/delivery_checklist.sh` / `./bin/checklist` | Full local sweep for formatting, analysis, validator scripts, tests, and coverage workflow (`delivery_checklist.sh` is canonical). |
| `./tool/check_pyright_python.sh` | Pyright on `demos/render_chat_api` and `tool/` Python (included in the full delivery gate; run alone when iterating on the Render FastAPI demo or shell tooling). |
| `./bin/integration_tests` | Runs integration flows on a supported non-web device. |
| `tool/test_coverage.sh` | Runs unit, bloc, widget, and other coverage-producing tests. |
| `dart run tool/update_coverage_summary.dart` | Refreshes [`coverage/coverage_summary.md`](../coverage/coverage_summary.md). |

CI runs `./bin/checklist` (same pipeline as `./tool/delivery_checklist.sh`) on push and pull request. For local work, prefer
targeted validation first and reserve the full delivery gate for broad or pre-ship
sweeps. The macOS integration job is manual-only through GitHub Actions
workflow dispatch and supports the
`smoke`, `standard`, and `exhaustive` rollout tiers defined in
`.github/workflows/ci.yml`.

## Coverage

- Coverage is tracked in [`coverage/coverage_summary.md`](../coverage/coverage_summary.md).
- CI enforces a line-coverage threshold using `coverage/lcov.info`.
- Generated files, localization output, simple data classes, and other
  low-signal artifacts are excluded from totals.

## Test layers

| Layer | Scope | Typical location |
| --- | --- | --- |
| Unit tests | Pure Dart logic, repositories, services, helpers | `test/**` |
| Bloc tests | Cubit/BLoC state transitions and side-effect boundaries | `test/**` |
| Widget tests | Screen and widget behavior, interaction, and layout | `test/**` |
| Golden tests | Visual regressions for deterministic UIs | `test/**` |
| Integration tests | End-to-end flows, navigation, persistence, and cross-feature behavior | `integration_test/**` |
| Performance traces | Focused integration/perf harnesses and traces | `integration_test/perf/**` |

## Integration suite layout

### Main entrypoints

| File | Purpose |
| --- | --- |
| `integration_test/pr_smoke_flows_test.dart` | Smallest high-signal smoke suite intended for PR-level confidence. |
| `integration_test/smoke_flows_test.dart` | Broader local smoke coverage. |
| `integration_test/standard_flows_test.dart` | Standard integration tier aligned with CI workflow dispatch. |
| `integration_test/extended_flows_test.dart` | Heavier persistence, refresh, and filter scenarios. |
| `integration_test/all_flows_test.dart` | Aggregates the full flow suite. |
| `integration_test/perf/perf_smoke_flows_test.dart` | Performance-oriented smoke harness. |

### Harness and helpers

- `integration_test/test_harness.dart`
- `integration_test/test_harness_fakes.dart`
- `integration_test/flow_scenarios*.dart`
- `integration_test/widget_tester_pumps.dart`

Use the helper methods in the harness instead of unbounded `pumpAndSettle()`
for integration flows.

## Common commands

```bash
# Run the standard local gate (canonical script; ./bin/checklist is equivalent when present)
./tool/delivery_checklist.sh

# Run all non-integration tests with coverage
tool/test_coverage.sh

# Run the full integration suite
./bin/integration_tests

# Run a specific integration entrypoint
./bin/integration_tests integration_test/pr_smoke_flows_test.dart

# Run a single test file
flutter test test/features/counter/presentation/counter_cubit_test.dart

# Regenerate golden files
flutter test --update-goldens
```

If multiple devices are attached, set:

```bash
CHECKLIST_INTEGRATION_DEVICE=<deviceId>
```

If you want integration flow validation without refreshing coverage output:

```bash
INTEGRATION_TESTS_RUN_COVERAGE=false ./bin/integration_tests
```

The integration runner is single-run by default: if another integration run is
already active in this repo, the second invocation exits early instead of
competing for the same device/simulator state. Stale lock directories are
auto-cleared when the recorded owner PID is gone.

## Repo testing conventions

- Use `FakeTimerService` for time-dependent behavior.
- Prefer route-scoped cubit testing over widget-driven state setup when the
  behavior is business logic, not rendering.
- Use temporary directories and initialized Hive services for local persistence
  tests.
- Prefer `pump()` and bounded helpers for network-image and async-heavy widget
  tests.
- Update goldens when rendering changes are intentional and review the image
  diff before committing.
- Extend an existing regression guard when fixing a bug instead of creating a
  parallel duplicate test.

## Related docs

- [Integration Flow Guide](testing_integration_flows.md)
- [Validation Scripts](validation_scripts.md)
- [New Developer Guide](new_developer_guide.md)
- [Code Generation Guide](code_generation_guide.md)
