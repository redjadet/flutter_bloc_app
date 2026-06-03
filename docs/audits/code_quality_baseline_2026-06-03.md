# Code quality baseline — 2026-06-03

- **Commit:** `3228d800` (baseline snapshot); program deliverables verified with `./bin/checklist` exit 0 on dirty tree before merge
- **Auditor:** Cursor agent (code quality baseline program)
- **Program:** [code quality baseline and gate promotion](../plans/code_quality_baseline_and_gate_promotion_2026-06.md)

## Checklist snapshot

| Command | Exit | Notes |
| --- | ---: | --- |
| `git status --short` | — | Uncommitted program deliverables at snapshot time |
| `./bin/checklist` | 0 | Passed after doc link normalization and QG-D05/QG-D07 wiring |
| `./bin/checklist-fast` | 1 | Initial doc-gardening block before audit file existed; not rerun after app/`lib/` diff |
| `bash tool/validate_validation_docs.sh` | 0 | Passed after CHECK_SCRIPTS update in PR2 |

**Resolved pre-fix failure block:** `violation|docs/audits/README.md: missing md token docs/audits/code_quality_baseline_YYYY-MM-DD.md`

**Artifacts:** local log `/tmp/checklist_baseline_2026-06-03.log` (initial partial run); terminal proof from final `./bin/checklist` run (passed).

**Re-snapshot after PR1:** use `./bin/checklist-fast` only on a docs/tooling-only branch; current mixed workspace proof is full `./bin/checklist`.

## Modularity

`bash tool/modular_metrics.sh` (2026-06-03T11:49:16Z):

- Fan-in heuristic: `shared/` ~501 files, `core/` ~168 files, `app/` ~10 files
- **Shared → feature imports:** none
- **Domain importing app/router or core/di:** none

`bash tool/modular_metrics.sh --cross-feature-only`:

- **Cross-feature imports:** none (baseline count = 0)

## Coverage by layer

Source: [`coverage/coverage_summary.md`](../../coverage/coverage_summary.md) (generated LCOV rollup).

| Layer | Coverage | vs 85% target | Note |
| --- | ---: | --- | --- |
| **Total** | 71.49% | Below | Demo/integration carve-outs documented in summary |
| `lib/shared/` (aggregate) | 80.08% | Near | Primary shared contract surface |
| `lib/core/` (aggregate) | 65.10% | Below | DI/bootstrap paths; P2 unless slice touches |
| `lib/features/counter/` | 86.81% | Met | Representative offline-first feature |
| `lib/features/todo_list/` | 72.97% | Below | Sync banner + offline-first tests exist |

**Stop rule:** Contract tests on fragile seams (future plan Phase 5) trump global % for this program.

## Regression guards

| Seam (future plan) | In `ALL_TESTS`? | Test path |
| --- | --- | --- |
| Background sync / FCM trigger | Yes | `test/shared/sync/background_sync_coordinator_test.dart` |
| FCM payload contract | Partial | `test/shared/sync/fcm_sync_trigger_contract_test.dart` |
| Auth token / HTTP | Yes | `test/shared/http/auth_token_interceptor_test.dart`, `register_http_services_test.dart` |
| Inherited widget lifecycle | Yes | `test/shared/inherited_widget_lifecycle_regression_test.dart` |
| Offline-first counter | Yes | `test/features/counter/data/offline_first_counter_repository_test.dart` |
| Graphql exception mapping | Yes | `test/features/graphql_demo/data/graphql_demo_exception_mapper_test.dart` |

**P1:** Extend coordinator tests for `BackgroundSyncTrigger` telemetry if Phase 2 sync slice proceeds.

## Validation honesty matrix

| Lane | Command | Proves | Required before merge? | Known local gaps |
| --- | --- | --- | --- | --- |
| Fast sanity | `./bin/checklist-fast` | Docs/tooling only | No (lib changes) | Fails if doc placeholders break gardening |
| Scoped router/auth | `./bin/router_feature_validate` | Router/auth paths | When router globs match | — |
| Full ship | `./bin/checklist` | Static gates + analyze + tests policy | Yes (pre-merge / pre-release) | Runtime, machine RAM |
| Integration preflight | `./bin/integration_preflight` | Web/bootstrap/import drift | CI on PR | — |
| iOS integration exhaustive | `./bin/integration_tests` | `all_flows_test.dart` | Pre-release / manual when CI skipped | Sim AssetCatalog, CocoaPods OOM, `pod` exit 137; pod shim when locks match |

**Integration preflight (2026-06-03):** exit 0 — log-filter regression + web bootstrap smoke passed.

## Future-plan next target (PR3)

**Chosen:** Option 3 — structured error adoption for **Graphql demo** (`GraphqlDemoCubit` / page), next named surface after Chart, Counter, and shared `ErrorHandling`.

Owner quote ([`future_architecture_code_quality_improvement_plan.md`](../plans/future_architecture_code_quality_improvement_plan.md) § Current Recommended Next Step):

> pick the next named high-value error surface after `ChartPage`, `ErrorHandling`, and `CounterPage` (for example another cubit flow or a reusable status/error component)

## Backlog

| ID | Priority | Item | Proof | Owner doc |
| --- | --- | --- | --- | --- |
| B-01 | P0 | None undocumented after final checklist pass | `./bin/checklist` exit 0 | This audit |
| B-02 | P1 | Promote QG-D07 lifecycle observer gate (warn-first) | 0 violations on `main` inventory | [`checklist_quality_gates_deferred.md`](../plans/checklist_quality_gates_deferred.md) |
| B-03 | P1 | Promote QG-D05 deferred routes gate (warn-first) | Allowlist matches baseline appendix | [`checklist_quality_gates_baseline.md`](../plans/checklist_quality_gates_baseline.md) |
| B-04 | P1 | Graphql `AppError` adoption + tests | PR3 slice | [`future_architecture_code_quality_improvement_plan.md`](../plans/future_architecture_code_quality_improvement_plan.md) |
| B-05 | P2 | `lib/core/` coverage below 85% | coverage table | [`CODE_QUALITY.md`](../CODE_QUALITY.md) |
| B-06 | P2 | D03/D04/D01/D02 gate spikes | Phase 0b spikes doc | deferred gates doc |

## Next action

Program slice (2026-06-03): PR1 audit + PR2 gates (D07, D05 warn-first) + PR3 Graphql `AppError` shipped in one delivery branch per user request; split into separate PRs on replay if review prefers plan WIP limits.

Post-merge: re-run Phase 0a snapshot on clean `main`; flip D05/D07 to `fail` when ready.
