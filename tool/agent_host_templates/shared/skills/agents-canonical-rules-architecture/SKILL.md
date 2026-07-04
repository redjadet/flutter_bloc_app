---
name: agents-canonical-rules-architecture
description: Canonical rules — feature layers, domain purity, cubit vs widget roles, DI entrypoints, Freezed. Part of agents-canonical-rules split.
---

# Architecture & state

Slice of **`agents-canonical-rules`**. Detail: `docs/clean_architecture.md`, `docs/feature_implementation_guide.md`, `docs/architecture/feature_structure_contract.md`, `docs/architecture/reference_features.md`, `docs/architecture/use_case_dto_policy.md`, `docs/bloc_standards.md`.

- No `package:flutter` under `apps/mobile/lib/features/*/domain/`.
- **Clean Architecture skeleton** for every feature:
  `Presentation -> Domain <- Data`. **MVVM only in presentation** — View =
  `pages/`/`widgets/`; ViewModel = `presentation/cubit/` (Cubit/BLoC =
  **presentation state management only**). No top-level `viewmodels/` or
  cross-layer MVVM folders; no Cubit/BLoC in `domain/` or `data/`.
- New cubits under `presentation/cubit/` only; copy gold layouts from
  `docs/architecture/reference_features.md`.
- Run `bash tool/check_clean_architecture_imports.sh` and
  `bash tool/check_feature_folder_contract.sh` before broad feature finish.
- Repositories implement domain interfaces; domain/use cases own business rules;
  Cubit/BLoC owns presentation state and flow orchestration.
- DI in `apps/mobile/lib/core/di/injector*.dart`.
- Prefer Freezed for new state/domain models; `build_runner` after `@freezed`.
- For Cubit/Bloc decisions, invoke `agents-bloc-standards`.
