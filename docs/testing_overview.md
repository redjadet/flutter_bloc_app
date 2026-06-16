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
- RTL + localization regression guards: `test/rtl/` (e.g. Arabic `Locale('ar')` directionality + spacing checks)

## Integration docs (policy and contracts)

If you are adding or changing integration coverage, these documents define the
expected structure and “ownership” contract:

- [Integration test policy](engineering/integration_test_policy.md)
- [Integration journey map](engineering/integration_journey_map.md)
- [Integration runner contract](engineering/integration_runner_contract.md)

## Quality gates

| Command | Purpose |
| --- | --- |
| `./tool/delivery_checklist.sh` / `./bin/checklist` | Primary local quality gate. Broad/pre-ship runs still take the full sweep; narrow local docs/tooling work can use built-in fast paths while CI keeps the full bar (`delivery_checklist.sh` is canonical). |
| `./bin/checklist-fast` | Local-only sanity shortcut for clean trees or narrow docs/tooling work. Refuses CI and broader app/runtime diffs. |
| `./tool/check_pyright_python.sh` | Pyright on `demos/render_chat_api` and `tool/` Python (included in the full delivery gate; run alone when iterating on the Render FastAPI demo or shell tooling). |
| `bash tool/check_flutter_layout_overflows.sh` | Runs a small high-signal test set with a **global fail-fast guard** for layout overflows (e.g. `RenderFlex overflow`). Included in the full checklist. |
| `./bin/integration_tests` | Runs integration flows on a supported non-web device. |
| `tool/test_coverage.sh` | Runs unit, bloc, widget, and other coverage-producing tests. |
| `dart run tool/update_coverage_summary.dart` | Refreshes [`coverage/coverage_summary.md`](../coverage/coverage_summary.md). |

CI runs `./bin/checklist` (same pipeline as `./tool/delivery_checklist.sh`) on push and pull request and still keeps the full checklist bar. For local work, prefer
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
| `integration_test/pr_smoke_flows_test.dart` | Smallest high-signal suite for explicit PR-level confidence (manual/explicit target; PR CI runs preflight only). |
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
flutter test test/counter_cubit_test.dart

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

## Regression test anchors

When fixing a bug class, extend these paths (or register in `tool/check_regression_guards.sh`) instead of duplicating coverage:

| Area | Test path(s) |
| --- | --- |
| Background sync races | `test/shared/sync/background_sync_coordinator_test.dart` |
| Repo in-flight coalesce | `test/features/search/data/offline_first_search_repository_test.dart`, `test/features/profile/data/...`, `test/features/remote_config/data/...` |
| Don't-overwrite local | `test/features/counter/data/offline_first_counter_repository_test.dart` (+ `tool/check_offline_first_remote_merge.sh`) |
| RequestIdGuard supersession | `test/features/online_therapy_demo/edge_cases_test.dart::reports success when superseded`, `test/features/chat/presentation/cubit/chat_cubit_send_supersession_test.dart` (+ `tool/check_mutation_success_after_guard.sh`) |
| HTTP error mapping | 401/429/503, unmapped fallback, `Retry-After` parsing |
| Auth refresh single-flight | one forced refresh on 401 retry with new bearer |

Lifecycle script lists: [`validation_scripts.md`](validation_scripts.md) catalog + `tool/check_regression_guards.sh`. Mix/goldens: skill `agents-validation-testing` (pointer only).

## Feature-defined testing

For non-trivial features, tests are the **definition of done**—not a post-merge
cleanup step. They guard **behaviour contracts** during refactors (compile checks
stay with `dart analyze`). Fill the executable contract in
[`docs/plans/FEATURE_TEMPLATE.md`](plans/FEATURE_TEMPLATE.md) before broad
implementation.

### Layer mix (guidance, not quotas)

| Layer | ~Share | When | Location |
| --- | --- | --- | --- |
| Unit + cubit | ~60% | Domain rules, repository logic, cubit transitions | `test/**` |
| Widget | ~30% | Screen contracts: taps, validation, loading/success/error UI | `test/**` |
| Integration | ~10% | Named cross-screen journeys only | `integration_test/**` |

This is priority guidance, not a coverage target. CI line-coverage thresholds are
unchanged.

### Priority matrix

| Priority | Examples in this app | Minimum contract |
| --- | --- | --- |
| P0 | Auth, payments/calculator/IAP demos, core navigation/shell | ≥1 behaviour + ≥1 state widget test per changed screen; cubit tests for new transitions |
| P1 | Todo, counter, search, chat, offline-first banners | Cubit + widget for changed UX; integration only when journey map requires it |
| P2 | Demos, showcase, low-traffic samples | Unit/cubit for logic; widget smoke optional |

### Non-goals

- Widget-test every leaf component.
- Live network in unit or widget tests (use fakes under `test/`).
- New aggregate integration suites when an existing journey (J1 auth session,
  payment/calculator paths in standard flows) can be extended instead. See
  [Integration test policy](engineering/integration_test_policy.md) and
  [Integration journey map](engineering/integration_journey_map.md).

### How-to

- Widget tests (BLoC): [`testing/widget_test_playbook.md`](testing/widget_test_playbook.md)
- RED→GREEN loop: [`testing/testing_strategy.md`](testing/testing_strategy.md)
- Async pumps: follow **Repo testing conventions** above (bounded `pump()`, not
  unbounded `pumpAndSettle` on heavy animation).

## Related docs

- [Widget test playbook](testing/widget_test_playbook.md)
- [Testing strategy (router)](testing/testing_strategy.md)
- [Integration Flow Guide](testing_integration_flows.md)
- [Validation Scripts](validation_scripts.md)
- [New Developer Guide](new_developer_guide.md)
- [Code Generation Guide](code_generation_guide.md)
