# Feature Structure Contract

Canonical folder contract for Cursor and Codex agents. Use with
[Feature Delivery Guide](../feature_implementation_guide.md) and
[Clean Architecture](../clean_architecture.md).

## Skeleton (non-negotiable)

**Clean Architecture** is the feature skeleton. **MVVM is presentation-only**
(View + ViewModel); domain and data are not MVVM layers. **Cubit/BLoC is
presentation state management only** — never place Cubit/BLoC under `domain/`
or `data/`.

```text
presentation/                 ← MVVM lives here only
  pages/, widgets/            ← View
  cubit/                      ← ViewModel (Cubit / BLoC)

domain/
  <entity>.dart               ← Entity / domain model
  use_cases/                  ← Use case (optional; see use_case_dto_policy)
  <feature>_repository.dart   ← Repository interface

data/
  <feature>_repository_impl   ← Repository implementation
  *_remote_*, *_local_*, …    ← Data source
  *_dto.dart                  ← DTO
  *_mapper.dart
```

Do not add parallel skeletons (`application/`, `infrastructure/`, top-level
`viewmodels/`, `providers/`) — Cubit/BLoC **is** the ViewModel under
`presentation/cubit/`.

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
| Widget preview | Optional co-located `*_preview.dart` or top-level `@Preview` in `presentation/widgets/` |
| Widget test (component) | `test/features/<feature>/presentation/widgets/<name>_test.dart` mirrors `presentation/widgets/` |

**New code rule:** use `presentation/cubit/` (singular) only. Do not add new
Cubits at `presentation/` root or under `presentation/cubits/`.

Existing folders with `cubits/`, `helpers/`, `utils/`, or domain subfolders may
remain while touched code follows the closest local convention. New features
should use the standard shape above.

Example filled brief: [`feature_brief_scaffold_example.md`](feature_brief_scaffold_example.md).
In-repo gold layouts: [`reference_features.md`](reference_features.md).

## Reusable presentation widgets

Extract widgets when a screen block is reused, has multiple visual states, or
needs isolated preview/test/iteration. Full contract:
[`design_system.md`](../design_system.md) § Reusable widgets (preview, test,
design iteration).

- **Leaf widgets** take data + callbacks; **pages** own cubit lookup and routing.
- **Do not** embed business rules or repository calls in reusable widgets.
- **Do** add `@Preview` + a matching widget test for non-trivial new widgets when
  the feature brief or testing matrix calls for UI proof.
- **Do** use responsive layout — avoid fixed sizes on reflowable UI; prefer
  `context.responsive*` then `LayoutBuilder` / `MediaQuery` when suitable
  ([`design_system.md`](../design_system.md) § Responsive layout).

## Cross-platform form factors

Shared widgets must work on **mobile, tablet, web, and desktop (macOS)** — see
[`design_system.md`](../design_system.md) § Cross-platform form factors and
[`tech_stack.md`](../tech_stack.md) § Supported platforms.

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
