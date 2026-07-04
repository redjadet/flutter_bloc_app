---
name: agents-feature-delivery
description: Cursor/Codex feature delivery contract for folder shape, use cases, DTO mapping, testing matrix, DI/routes, and validation.
---

# Feature delivery

Use before adding or changing `apps/mobile/lib/features/**`.

Read:

- `docs/ai/ai_failure_risks.md` (Pre-Flight + applicable risk rows)
- `agents-common-pitfalls`
- `docs/feature_implementation_guide.md`
- `docs/architecture/feature_structure_contract.md`
- `docs/architecture/reference_features.md`
- `docs/architecture/use_case_dto_policy.md`
- `docs/testing/matrix_required_by_change.md`
- `docs/bloc_standards.md` when Cubit/BLoC touched

Do:

- Preview new feature layout with
  `bash tool/scaffold_feature_contract.sh --name <feature>`; use `--apply`
  only after the name is final.
- Fill feature brief tests first for non-trivial work.
- Keep `Presentation -> Domain <- Data` (CA skeleton). MVVM only in
  presentation — View = `pages/`/`widgets/`; ViewModel = `presentation/cubit/`.
  Domain = entity + repository interface (+ use cases when policy requires).
  Data = repository impl + datasource + DTO.
- Place DTO/mappers in data; view-data mappers in presentation/core diagnostics.
- Extract **reusable leaf widgets** for preview, widget test, and design iteration —
  [`docs/design_system.md`](../../../../../docs/design_system.md) § Reusable widgets;
  mirror tests under `test/features/<feature>/presentation/widgets/`.
- Prove **mobile, tablet, web, desktop** for shared UI —
  [`docs/design_system.md`](../../../../../docs/design_system.md) § Cross-platform form factors;
  `flutter-cross-platform-modern`.
- Add use case only for reusable multi-repository/domain workflow.
- Wire DI/routes/l10n/codegen in same change when touched.

Proof:

- `bash tool/check_clean_architecture_imports.sh`
- `bash tool/check_feature_folder_contract.sh` (`--strict` for new features)
- `bash tool/check_feature_brief_linked.sh`
- Focused `flutter test <paths>`
- `./tool/analyze.sh`
- Escalate via `docs/engineering/validation_routing_fast_vs_full.md`.
