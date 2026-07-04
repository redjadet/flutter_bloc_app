# Modular architecture plan — implementation notes (2026-05-12)

## Agent session summary

- **Goal:** Enforce modular monolith boundaries without Melos split.
- **Delivered:** Leak script, DI group parts, memory-service decoupling, domain surface tests, feasibility docs.
- **Verify:** `bash tool/check_feature_modularity_leaks.sh`, targeted `flutter test`, checklist-fast lane.
- **Interview use:** Cite this change log in [interview_showcase.md](../interview_showcase.md) §9 as an AI plan→implement→verify example.

## What shipped

- **`tool/modular_metrics.sh`** — read-only baseline; `--cross-feature-only` for import inventory.
- **Modular baseline audit** — captured output under ignored `docs/audits/` during the implementation session; recreate with `tool/modular_metrics.sh` when a fresh snapshot is needed.
- **`tool/check_feature_modularity_leaks.sh`** — declarative pairwise rules + universal **shared→features** + **domain import purity** (with `rg`; grep fallback for pairwise only).
- **`AppMemoryService`** — removed `shared` → `chart` import; chart trim wired via `onChartMemoryTrim` from [`apps/mobile/lib/core/di/injector_registrations.dart`](../../apps/mobile/lib/core/di/injector_registrations.dart).
- **DI orchestration** — [`injector_registrations.dart`](../../apps/mobile/lib/core/di/injector_registrations.dart) split into `part` files under [`apps/mobile/lib/core/di/groups/`](../../apps/mobile/lib/core/di/groups/): `register_core_services.dart`, `register_feature_services.dart`, `register_demo_services.dart` (`registerCoreServices`, `registerFeatureServices`, `registerDemoServices`).
- **Tests** — [`test/shared/services/app_memory_service_test.dart`](../../test/shared/services/app_memory_service_test.dart); domain surface tests under [`test/domain_public_surface/`](../../test/domain_public_surface/).
- **`tool/check_feature_barrel_exports.sh`** — report-only deep-import list from `apps/mobile/lib/app/`.
- **Docs** — [`modularity.md`](../modularity.md), [`validation_scripts.md`](../validation_scripts.md); feasibility: [`plans/dependency_validator_feasibility.md`](../plans/dependency_validator_feasibility.md), [`plans/feature_scoped_di_feasibility.md`](../plans/feature_scoped_di_feasibility.md), [`plans/melos_package_split_feasibility.md`](../plans/melos_package_split_feasibility.md); sweep: [`engineering/ports_adapters_modular_sweep_2026-05-12.md`](../engineering/ports_adapters_modular_sweep_2026-05-12.md).

## Deferred / backlog

- **`dependency_validator`** — not added to `pubspec` / checklist (noisy); see feasibility doc.
- **Oversized `.part.dart` splits** — audit list unchanged; `secret_config` already uses [`secret_config_chat_orchestration.dart`](../../apps/mobile/lib/core/config/secret_config_chat_orchestration.dart). Further splits remain test-first per hotspot audit.
- **Feature-to-feature default-deny** — use metrics report + classify before failing CI ([`modularity.md`](../modularity.md) Phase 1B).
- **get_it scopes** — feasibility only.

## Churn snapshot (post-change, `lib` + `test`, excludes generated + l10n)

Top paths (commit count, approximate):

| Count | Path |
| ----- | ---- |
| 58 | `apps/mobile/lib/features/counter/presentation/pages/counter_page.dart` |
| 43 | `apps/mobile/lib/core/di/injector.dart` |
| 40 | `apps/mobile/lib/app.dart` |
| 39 | `apps/mobile/lib/core/di/injector_registrations.dart` |
| 38 | `apps/mobile/lib/features/counter/presentation/cubit/counter_cubit.dart` (migrated 2026-06) |

Re-run quarterly after large refactors.

## Validation run (local)

- `bash -n tool/modular_metrics.sh tool/check_feature_modularity_leaks.sh tool/check_feature_barrel_exports.sh`
- `bash tool/check_feature_modularity_leaks.sh`
- `bash tool/validate_validation_docs.sh`
- `flutter test test/shared/services/app_memory_service_test.dart test/domain_public_surface/`
- `./tool/analyze.sh` (full package)
