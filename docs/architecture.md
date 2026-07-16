# Architecture (entry hub)

> **Do not duplicate** — this page links to canonical docs. Edit the targets, not this hub.

Thin map for structure, layering, and modularity. For day-to-day implementation, start with [clean_architecture.md](clean_architecture.md) and [architecture_details.md](architecture_details.md).

## Start here

- [clean_architecture.md](clean_architecture.md) — layer rules, dependency flow, Cubit placement
- [architecture_details.md](architecture_details.md) — app shell, routing, DI, bootstrap
- [architecture/feature_structure_contract.md](architecture/feature_structure_contract.md) — feature folder contract
- [architecture/use_case_dto_policy.md](architecture/use_case_dto_policy.md) — use cases, DTOs, mappers
- [architecture/MOBILE_BACKEND_BOUNDARIES.md](architecture/MOBILE_BACKEND_BOUNDARIES.md) — six mobile/backend failure modes
- [backend/API_CONTRACT_GUIDE.md](backend/API_CONTRACT_GUIDE.md) — mobile/backend contract + future pagination
- [adr/README.md](adr/README.md) — accepted architecture decisions (ADR index)
- [modularity.md](modularity.md) — feature barrels, cross-feature import guards
- [system_design_showcase.md](system_design_showcase.md) — interview/portfolio talk track (claims → proof)
- [bloc_standards.md](bloc_standards.md) — Cubit/BLoC conventions
- [plugin_failure_mode_strategy.md](plugin_failure_mode_strategy.md) — plugin wrappers, `Result`/`Failure`, presentation mapping
- [storage_rules.md](storage_rules.md) — prefs vs secure storage vs Hive

## Verification

- `bash tool/check_clean_architecture_imports.sh`
- `bash tool/check_feature_modularity_leaks.sh`
- `bash tool/modular_metrics.sh`
