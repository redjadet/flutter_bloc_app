# Architecture Review Checklist

Use this before accepting Cursor/Codex feature code. Findings must cite files
and the violated rule.

Primary contracts: [Feature Structure](../architecture/feature_structure_contract.md)
and [Use Case / DTO Policy](../architecture/use_case_dto_policy.md).

## Layering

- Domain contains pure Dart contracts/models only.
- Data implements domain contracts and owns SDK, HTTP, persistence, DTOs, and
  sync.
- Presentation owns Cubit/BLoC, pages, widgets, route-level user flow, and
  visible state. **MVVM applies here only:** View = `pages/`/`widgets/`; ViewModel
  = `presentation/cubit/` — **presentation state management only** (see
  [`clean_architecture.md`](../clean_architecture.md) § Architecture skeleton).
- App/router/core compose features from above; feature code does not import
  another feature unless an explicit exception exists in [Modularity](../modularity.md).

## Dependency Direction

- Presentation imports domain/core/shared contracts, not data-layer
  implementations.
- Data imports domain/core/shared infrastructure, not presentation.
- `lib/shared/` does not import `lib/features/`.
- Cross-feature needs use app composition, `lib/core/` ports, or shared DTOs.

## Feature Shape

- New or changed feature files sit under predictable `domain/`, `data/`, and
  `presentation/` folders.
- New cubit/state files live under `presentation/cubit/` (see
  [`reference_features.md`](../architecture/reference_features.md)); not at
  `presentation/` root, `presentation/cubits/`, or flow subfolders.
- DI registration lives in `lib/core/di/` and uses existing idempotent helpers.
- Route constants and route groups are updated together.
- Generated code, l10n, Hive schema fingerprints, or migrations are updated
  when their annotations or stored shapes change.

## Forbidden Patterns

- `package:flutter` in feature domain.
- `Hive.openBox` outside shared storage abstractions.
- Raw SDK/client calls from Cubit/BLoC or widgets.
- Repository construction inside widgets.
- Navigation from domain/data.
- Shared utility buckets named only `Utils`, `Helper`, `Manager`, or `Base*`
  without a narrow capability.

## Proof

Minimum proof is the path-specific lane in
[`validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md).
Escalate to `./bin/checklist` for DI, routing, offline-first, lifecycle, shared
infrastructure, or cross-feature changes.
