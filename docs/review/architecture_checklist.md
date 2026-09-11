# Architecture Review Checklist

Use this before accepting Cursor/Codex feature code. Findings must cite files
and the violated rule.

Primary contracts: [Feature Structure](../architecture/feature_structure_contract.md)
and [Use Case / DTO Policy](../architecture/use_case_dto_policy.md).

## Layering

- Domain contains pure Dart contracts, models, and reusable business policies.
- Data implements domain contracts and owns SDK, HTTP, persistence, DTOs, and
  sync orchestration. Reusable pure business decisions live in domain policies;
  data invokes them on every I/O path that can violate the invariant.
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
- `apps/mobile/lib/app/` does not import `apps/mobile/lib/features/`.
- Cross-feature needs use app composition, package-owned ports, or shared DTOs.

## SOLID gate

- Each changed production type conforms to the mandatory
  [SOLID Principles](../architecture/solid_principles.md); reject violations before accepting
  agent-generated code.

## Feature Shape

- New or changed feature files sit under predictable `domain/`, `data/`, and
  `presentation/` folders.
- New cubit/state files live under `presentation/cubit/` (see
  [`reference_features.md`](../architecture/reference_features.md)); not at
  `presentation/` root, `presentation/cubits/`, or flow subfolders.
- DI registration lives in `apps/mobile/lib/app/composition/` and uses existing idempotent helpers.
- Route constants and route groups are updated together.
- Generated code, l10n, Hive schema fingerprints, or migrations are updated
  when their annotations or stored shapes change.

## Semantic Judgment

- Names at risky boundaries expose domain role and predicate meaning (types,
  commands, failures, eligibility predicates).
- External/storage shapes stay in DTO/mapper containment; tiny internal-only
  maps may skip a mapper when it adds churn without safety
  ([`use_case_dto_policy.md`](../architecture/use_case_dto_policy.md)).
- One pure policy owner for reusable decisions; every write, replay, and bypass
  path that can violate the rule invokes it.
- Policy proof is behavior-level / pure unit tests without repository mocks.
- Enforcement radius is stated; proof is behavior/adversarial coverage, not a
  single caller guard.

## Forbidden Patterns

- `package:flutter` in feature domain.
- `Hive.openBox` outside shared storage abstractions.
- `await getBox()` then write/`_save*`/`_deleteKeys` outside `runWithBox` on
  `HiveRepositoryBase` subclasses (lost updates under the per-box mutex; see
  #834 / `tool/check_hive_getbox_rmw.sh`; Known limitations in
  [`security/storage_rules.md`](../security/storage_rules.md)).
- Raw SDK/client calls from Cubit/BLoC or widgets.
- Repository construction inside widgets.
- Business filtering, grouping, counting, lookup-by-id, or default workflow
  windows inside widgets/pages; move derived view data to state getters/cubit
  methods and pure workflow rules to domain helpers.
- Navigation from domain/data.
- Shared utility buckets named only `Utils`, `Helper`, `Manager`, or `Base*`
  without a narrow capability.
- Public domain models/contracts exposing wire `Map<String, dynamic>` unless an
  intentional allowlisted dynamic bag exists (AP-18;
  `tool/check_domain_map_bags.sh`).

## Proof

Before accepting a boundary-sensitive feature, verify the protected rule,
single responsible owner, material partial-failure states, and enforcement
radius from
[`reduce_surprise_patterns.md`](../architecture/reduce_surprise_patterns.md)
§ Decision-first feature frame.

Minimum proof is the path-specific lane in
[`validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md).
Escalate to `./bin/checklist` for DI, routing, offline-first, lifecycle, shared
infrastructure, or cross-feature changes.
