# Folder structure — Codex architecture follow-ups

**Date:** 2026-07-06  
**Scope:** `apps/mobile/lib/`, `apps/mobile/test/`, `tool/`, canonical `docs/`

## Why

Codex architecture review flagged drift: flat `core/di/` registrars, `shared/` Melos
shims, feature subfolders (`presentation/helpers`, nested `domain/entities`), and
stale `core/auth` re-exports. Goal: align with
[`feature_structure_contract.md`](../architecture/feature_structure_contract.md)
without behavior change.

## What changed

- **DI:** Feature registrars → `apps/mobile/lib/core/di/features/`; groups unchanged
  under `core/di/groups/`.
- **Auth:** Removed `core/auth` contract shims; use `package:auth` + feature
  `AuthRepository` extension. Kept `SessionLifecycleCoordinator`, `TokenRepository`.
- **Shared:** Removed Melos compatibility re-exports; imports → `package:design_system`,
  `package:networking`, `package:storage` (app barrels kept where still useful).
- **Feature layout:** Dialogs/helpers/utils → `presentation/widgets/` or
  `presentation/cubit/`; flat `domain/` entities; `remote_config` repo at `data/`;
  `case_study_demo` video platform helpers → `presentation/platform/`.
- **Barrels:** `features.dart` completeness gate (`tool/check_features_barrel.sh`).
- **Tests:** Mirror lib layout (staff cubit tests, calculator formatters, auth widgets).

## Validation

```bash
bash tool/check_features_barrel.sh
bash tool/check_feature_folder_contract.sh
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_modularity_leaks.sh
cd apps/mobile && dart analyze lib test
```

## Docs

- [`CODEMAP.md`](../../CODEMAP.md), [`clean_architecture.md`](../clean_architecture.md),
  [`modularity.md`](../modularity.md), [`authentication.md`](../authentication.md)
