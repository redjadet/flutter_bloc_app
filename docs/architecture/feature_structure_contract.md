# Feature Structure Contract

Canonical folder contract for AI agents. Codex and Cursor are the primary
validated hosts. Use with [Feature Delivery Guide](../feature_implementation_guide.md)
and [Clean Architecture](../clean_architecture.md).

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
apps/mobile/lib/features/<feature>/
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

## Folder Growth Rule

Architecture responds to complexity; it does not predict it with empty trees.
Keep the `domain/`, `data/`, and `presentation/` layer boundaries, but do not
pre-create nested folders or add a folder that will contain only one file. Add
a nested folder when two or more related, distinct things need a home separate
from their siblings. Until then, keep the file at the nearest established layer
and split it later when the boundary becomes useful.

Renaming and splitting are routine maintenance: modern IDE refactors and Git
history make a later, evidence-based move safer than carrying speculative
structure from day one.

## Naming

| Concern | Preferred name |
| --- | --- |
| Repository contract | `<Feature>Repository` in `domain/` |
| Repository implementation | `<StorageOrRemote><Feature>Repository` or `<Feature>RepositoryImpl` in `data/` |
| DTO | `<Feature><Thing>Dto` in `data/` |
| Mapper | `<feature>_<thing>_mapper.dart` in `data/` unless mapping state to view data |
| Cubit | `<Feature><Flow>Cubit` in `presentation/cubit/` |
| Page | `<Feature><Flow>Page` in `presentation/pages/` |
| Reusable widget | Feature-owned first; move generic UI to `packages/design_system` only after reuse is real |
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
- **Do not** embed business rules, derived list logic, repository calls, or
  aggregation/counting in reusable widgets or `build()` methods.
- **Do** expose filtered/grouped/derived data via cubit state getters (or cubit
  methods for async/repository work) so widgets only render ready-to-display
  values.
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
- Data models/DTOs never escape into presentation state. Hand-written DTOs,
  domain field bags, DI bags, and leaf widgets use Dart 3.13 primary
  constructors (`class const Foo({required final String id})`) — see
  [`CODE_QUALITY.md`](../CODE_QUALITY.md).
- Presentation view data stays in `presentation/`; cross-feature diagnostics
  use a package-owned port only when app composition needs the contract.
- App-level composition lives in `apps/mobile/lib/app/`, especially
  `app/composition/` for DI.
- Shared utilities accept narrow capabilities, not feature cubits/repos.
- Cross-feature imports require an explicit exception in
  [Modularity](../modularity.md) or a package-owned port.

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
