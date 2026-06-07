# Feature Structure Contract

Canonical folder contract for Cursor and Codex agents. Use with
[Feature Delivery Guide](../feature_implementation_guide.md) and
[Clean Architecture](../clean_architecture.md).

## Standard Shape

Start with `bash tool/scaffold_feature_contract.sh --name <feature>` to preview
the expected folders and feature brief. Add `--apply` only after the feature
name is final.

```text
lib/features/<feature>/
  domain/
    <feature>_repository.dart
    <domain_model>.dart
  data/
    <feature>_repository_impl.dart
    <feature>_dto.dart
    <feature>_mapper.dart
  presentation/
    cubit/
      <feature>_cubit.dart
      <feature>_state.dart
    pages/
      <feature>_page.dart
    widgets/
      <feature>_*.dart
```

Small features may omit unused folders. Do not create alternative top-level
layer names such as `application/`, `infrastructure/`, `viewmodels/`, or
`providers/` without an accepted ADR.

## Naming

| Concern | Preferred name |
| --- | --- |
| Repository contract | `<Feature>Repository` in `domain/` |
| Repository implementation | `<StorageOrRemote><Feature>Repository` or `<Feature>RepositoryImpl` in `data/` |
| DTO | `<Feature><Thing>Dto` in `data/` |
| Mapper | `<feature>_<thing>_mapper.dart` in `data/` unless mapping state to view data |
| Cubit | `<Feature><Flow>Cubit` in `presentation/cubit/` |
| Page | `<Feature><Flow>Page` in `presentation/pages/` |
| Reusable widget | Feature-owned widget first; move to `shared/widgets/` only after reuse is real |

**New code rule:** use `presentation/cubit/` (singular) only. Do not add new
Cubits at `presentation/` root or under `presentation/cubits/`.

Existing folders with `cubits/`, `helpers/`, `utils/`, or domain subfolders may
remain while touched code follows the closest local convention. New features
should use the standard shape above.

Example filled brief: [`feature_brief_scaffold_example.md`](feature_brief_scaffold_example.md).
In-repo gold layouts: [`reference_features.md`](reference_features.md).

## Placement Rules

- Domain models expose business language and remain Flutter/SDK-free.
- Data models/DTOs never escape into presentation state.
- Presentation view data stays in `presentation/` or `core/diagnostics` when
  app composition needs it.
- App-level composition lives in `lib/app/` or `lib/core/di/`.
- Shared utilities accept narrow capabilities, not feature cubits/repos.
- Cross-feature imports require an explicit exception in
  [Modularity](../modularity.md) or a core/shared port.

## Review Questions

- Could another agent predict the destination for each new file?
- Does every cross-layer import match `Presentation -> Domain <- Data`?
- Is new shared code justified by real second use?
- Are route constants, route groups, DI, l10n, and generated code updated
  together when touched?

## Validation

Run `bash tool/check_clean_architecture_imports.sh`,
`bash tool/check_feature_folder_contract.sh` (use `--strict` for new features),
and `bash tool/check_feature_modularity_leaks.sh` for boundary-sensitive changes.
Use `./bin/router_feature_validate` when app routes or gates changed; use
`./bin/checklist` for cross-feature, DI, or shared infrastructure changes.
