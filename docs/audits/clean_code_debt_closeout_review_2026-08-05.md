# Clean-code debt closeout — 2026-08-05

Fresh current-state evidence after extracting shared FCM contracts into
`package:utilities`. Historical Aug 4 remeasure audit is **not** rewritten.

## Meta

| Field | Value |
| --- | --- |
| Branch | `chore/fcm-shared-contract-extraction` |
| Baseline HEAD | `92c17c80` on `origin/main` |
| Date (UTC) | 2026-08-05 |
| Scope | Modularity honesty only (FCM shared ports) |

## Baseline → final

| Signal | Baseline | Final |
| --- | ---: | ---: |
| Cross-feature `from_feature=` rows | **8** (`production_readiness` → `fcm_demo`) | **0** |
| Legacy `features/fcm_demo/domain/` imports under `apps/mobile` | present | **none** (`rg` empty) |

Baseline eight imports (Task 1):

- `production_readiness_cubit.dart` → `fcm_demo_mode`, `fcm_messaging_service`, `fcm_simulation_controller`, `push_message`
- `production_readiness_state.dart` → `fcm_demo_mode`, `fcm_permission_state`
- `production_readiness_page.dart` → `fcm_demo_mode`, `fcm_permission_state`

## Migration list

| From | To |
| --- | --- |
| `apps/mobile/lib/features/fcm_demo/domain/*` (6 files deleted) | `packages/utilities/lib/src/fcm/*` |
| Consumers/tests listed in change note | `package:utilities/utilities.dart` |

Change note:
[`docs/changes/2026-08-05_fcm_shared_contract_extraction.md`](../changes/2026-08-05_fcm_shared_contract_extraction.md)

## Debt disposition (unchanged this PR)

| Item | Action |
| --- | --- |
| QG-D04 | Already fail-default — **no change** |
| MQ-B2 FocusNode / TodoListPage teardown | Already landed — **no change** |
| QG-D03 | Report-only warn inventory — **no fail-flip** |
| Coverage / deferred hotspots | **no change** |

## Doc honesty

`docs/modularity.md` Phase 1B table previously claimed `None` while metrics still
reported eight FCM edges (stale). After this migration the table correctly
matches **0** report rows. Policy remains report-only (not default-deny CI).

## Proof commands (reproduce)

```bash
bash tool/modular_metrics.sh --cross-feature-only
rg -n 'package:flutter_bloc_app/features/fcm_demo/domain/' apps/mobile/lib apps/mobile/test
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/check_package_dependency_dag.sh
bash tool/check_engineering_quality_scorecard_gate.sh
```

Scorecard gate is separate from modularity metrics; cite `modular_metrics`
for the zero-edge claim.

## Residual risk

`modular_metrics --cross-feature-only` remains **report-only** by policy.
