# CODEMAP — task → paths

Short router for agents. Canon remains in [`docs/`](docs/README.md). Plan: [`PLAN.md`](PLAN.md).

| Task | Start here |
| --- | --- |
| Onboard / loop | [`AGENTS.md`](AGENTS.md), [`docs/agent_knowledge_base.md`](docs/agent_knowledge_base.md) |
| Add or change feature | [`docs/feature_implementation_guide.md`](docs/feature_implementation_guide.md), `lib/features/<feature>/` |
| Routes / deep links | [`lib/core/router/app_routes.dart`](lib/core/router/app_routes.dart), [`lib/app/router/`](lib/app/router/) |
| DI registration | [`lib/core/di/`](lib/core/di/), `register_*_services.dart` |
| UI / theme / Mix | [`DESIGN.md`](DESIGN.md), [`docs/design_system.md`](docs/design_system.md), [`lib/shared/`](lib/shared/) |
| Offline-first / sync | [`docs/offline_first/adoption_guide.md`](docs/offline_first/adoption_guide.md), [`lib/shared/sync/`](lib/shared/sync/) |
| HTTP / retries | [`lib/shared/http/`](lib/shared/http/), [`docs/reliability_error_handling_performance.md`](docs/reliability_error_handling_performance.md) |
| Native interop (MethodChannel / EventChannel / FFI) | [`lib/features/native_platform_showcase/`](lib/features/native_platform_showcase/), [`README`](lib/features/native_platform_showcase/README.md), [`docs/architecture/reference_features.md`](docs/architecture/reference_features.md) (`native_platform_showcase` row) |
| Tests | [`docs/testing_overview.md`](docs/testing_overview.md), [`test/`](test/) |
| Validation commands | [`docs/agents_quick_reference.md`](docs/agents_quick_reference.md), `./bin/checklist` |
| Feature catalog | [`docs/feature_overview.md`](docs/feature_overview.md) |
| Architecture | [`docs/architecture_details.md`](docs/architecture_details.md), [`ai/reports/architecture_overview.md`](ai/reports/architecture_overview.md) |
| Modularity / deps | [`docs/modularity.md`](docs/modularity.md), [`ai/reports/dependency_map.md`](ai/reports/dependency_map.md) |
| AI engineering | [`PLAN.md`](PLAN.md), [`docs/plans/2026-05-21_ai_first_engineering_plan.md`](docs/plans/2026-05-21_ai_first_engineering_plan.md) (runtime; build spec archived) |
| Discovery evidence | [`ai/reports/README.md`](ai/reports/README.md) |
| Ranked tech debt | [`docs/audits/ai_architecture_audit.md`](docs/audits/ai_architecture_audit.md) |
| Agent governance | [`docs/ai/governance.md`](docs/ai/governance.md) |
| Contracts (pilots) | [`CONTRACTS.md`](CONTRACTS.md) |

## Feature modules

`lib/features/<name>/` — see [`ai/reports/feature_map.md`](ai/reports/feature_map.md) for per-feature paths and minimal context sets.

Standard shape: [`docs/architecture/feature_structure_contract.md`](docs/architecture/feature_structure_contract.md). New Cubits go in `presentation/cubit/` only.

**Legacy — do not copy:** `counter` keeps Cubit at `presentation/` root and predates the folder contract. Gold layouts: [`docs/architecture/reference_features.md`](docs/architecture/reference_features.md) (`remote_config`, `profile`, `todo_list`) or scaffold output.

## Do not

- Treat `ai/reports/` as behavior canon—refresh evidence, link `docs/` for rules.
- Expand [`AGENTS.md`](AGENTS.md) with long prose—use Map bullets only.
