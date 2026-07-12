# SOLID Principles in flutter_bloc_app

Canonical SOLID guidance for humans and AI agents. Apply it strictly to every
new or changed production type. A violation blocks acceptance; do not defer it
as cleanup.

SOLID works inside this repository's Clean Architecture shape, not beside it:
`Presentation -> Domain <- Data`. `apps/mobile/lib/app/` composes features and
workspace packages; it is not another feature layer. See
[Clean Architecture](clean_architecture.md) for layer ownership and
[Modularity](modularity.md) for package and cross-feature boundaries.

## Operating rule

Before adding or changing a type, answer these questions:

1. Which layer owns this responsibility?
2. Which stable capability does its consumer need?
3. Does a real variation or second use justify an abstraction?
4. What test proves the contract independently of its implementation?

If these answers are unclear, stop and inspect the closest
[reference feature](architecture/reference_features.md). Do not compensate with
a generic `Helper`, `Manager`, `Utils`, `Base*`, service bag, or extra
application/infrastructure layer.

## Repository architecture map

| Area | Owns | Must not own |
| --- | --- | --- |
| `features/*/domain/` | Pure Dart models, business contracts, domain use cases/policy | Flutter, SDK, storage, DTO, router, DI imports |
| `features/*/data/` | Contract implementations, SDK/HTTP/storage access, DTO mapping, offline sync | Widgets, Cubit/BLoC, navigation |
| `features/*/presentation/` | Pages/widgets, Cubit/BLoC state, user-flow orchestration, view data | Concrete repositories, DTOs, direct SDK/storage access |
| `app/composition/` | Interface-to-implementation bindings and feature registration | Feature business rules or visible UI policy |
| `packages/*` | Reusable, app-independent capabilities | `apps/mobile` or a feature import |

Repository contracts belong in `domain/`; their implementations belong in
`data/`; bindings belong in `app/composition/`. For workflow and DTO placement,
follow [Use Case and DTO Policy](architecture/use_case_dto_policy.md).

## Single Responsibility Principle

One type has one reason to change, owned by one layer.

| When change concerns | Owner |
| --- | --- |
| Business invariant, reusable workflow policy, domain language | Domain model, use case, or domain service |
| HTTP/SDK/storage protocol, DTO shape, cache/retry/sync merge | Data repository, source, mapper, or data collaborator |
| User intent, visible loading/error state, request freshness | Cubit/BLoC and presentation state |
| Rendering, layout, accessible interaction | Page or widget |
| Binding contracts to implementations | App composition |

Split a type when it mixes rows. Keep cohesion: a small private collaborator
that serves one owner is better than a new cross-feature abstraction. For
Cubit/BLoC-specific boundaries, use [BLoC Standards](bloc_standards.md).

## Open/Closed Principle

Extend a stable seam; do not edit unrelated consumers to support a new variant.

- Add storage, transport, or platform variants by implementing an existing
  domain contract, then bind the chosen implementation in composition.
- Add a use case or narrow domain service when a reusable business workflow
  spans ports; do not put it in a widget or repository merely because it calls
  more than one dependency.
- Use a typed strategy or capability port when variation is real and named.
  Keep a one-off feature concern local.
- Do not introduce base classes, optional interface methods, flag-heavy APIs,
  or generic factories before a demonstrated variation requires them.

The counter feature's `CounterRepository` contract and its data implementations
are a current example of a data implementation varying behind a domain-facing
API. Copy structure only from the gold references, not legacy layout.

## Liskov Substitution Principle

Every implementation of a contract must preserve its caller-visible behavior.

Contract tests must cover, where applicable:

- returned domain values and typed failures;
- nullability, empty-state, and initial stream-emission semantics;
- retry, cancellation, ordering, and lifecycle behavior;
- persistence and offline-sync consistency guarantees.

Never make callers branch on an implementation type, special sentinel, or
implementation-only error. Move that distinction behind the contract, map it
in data, or expose a stable domain failure. Fakes and test doubles must obey
the same contract; a test-only shortcut is not a valid substitute.

## Interface Segregation Principle

Give each consumer the smallest named capability it needs.

- Cubits depend on a feature domain contract or narrow use case, never a
  concrete repository or multi-purpose service bag.
- Reusable widgets receive state and typed callbacks/capabilities, not a Cubit,
  repository, page, or service locator.
- Cross-feature and app-level capabilities use a package-owned port only when
  multiple consumers need the boundary. Keep feature-only contracts local.
- Prefer behavior names such as `AuthTokenReader` over containers such as
  `Helper`, `Manager`, or `Utils`.

See [Modularity](modularity.md#capability-boundaries) for extraction and
cross-feature ownership rules.

## Dependency Inversion Principle

High-level policy depends on stable abstractions; low-level details implement
them.

```text
presentation Cubit/BLoC  --> domain contract/use case <-- data implementation
                                                ^
                           app/composition binds implementation
```

- Domain remains pure Dart and defines domain-language contracts.
- Presentation imports domain contracts, not data implementations, DTOs, or
  SDK types.
- Data imports domain contracts and package infrastructure, not presentation.
- `app/composition/**` is the only binding point for concrete feature data or
  platform implementations.
- Packages must not import `apps/mobile` or `package:flutter_bloc_app`.

Constructor injection is the default. Resolve dependencies at established
composition boundaries; do not call `getIt` from leaf widgets or hide new
concrete allocations in production code.

## Required agent workflow

1. Locate owner layer and closest gold reference.
2. Define or reuse a narrow domain/capability contract only when the boundary
   is real.
3. Place implementation, mapper, Cubit/BLoC, and composition binding in their
   owning locations.
4. Add focused tests proving contract behavior, mapping, state transitions, or
   rendering at the changed layer.
5. Review with [Architecture Checklist](review/architecture_checklist.md) and
   run the validation lane from
   [Validation Routing](engineering/validation_routing_fast_vs_full.md).

## Proof and stop conditions

Reject or revise generated code when any condition holds:

- a domain type imports Flutter, SDK, DI, DTO, or presentation/data code;
- a widget or Cubit/BLoC imports/constructs a data implementation or SDK client;
- a repository contract exposes DTO, SDK, router, storage, or transport types;
- a caller needs an implementation-type check or special-case behavior;
- a shared abstraction has no demonstrated variation, second use, or stable
  boundary;
- a new cross-feature dependency bypasses app composition or a package-owned
  port.

Run the architecture guards for boundary-sensitive feature changes:

```bash
bash tool/check_clean_architecture_imports.sh
bash tool/check_feature_folder_contract.sh
bash tool/check_feature_modularity_leaks.sh
bash tool/check_package_dependency_dag.sh
```

Use `./bin/checklist` for DI, shared infrastructure, cross-feature, or other
broad architecture changes. Narrow docs-only changes follow the docs lane.

## Related documentation

- [Clean Architecture](clean_architecture.md)
- [Feature Structure Contract](architecture/feature_structure_contract.md)
- [Reference Features](architecture/reference_features.md)
- [Use Case and DTO Policy](architecture/use_case_dto_policy.md)
- [BLoC Standards](bloc_standards.md)
- [Architecture Checklist](review/architecture_checklist.md)
- [Modularity](modularity.md)
