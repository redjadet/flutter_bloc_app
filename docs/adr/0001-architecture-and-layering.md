# ADR 0001: Architecture and Layering

| Field | Value |
| --- | --- |
| Status | Accepted |
| Scope | App-wide architecture |
| Source docs | [Clean Architecture](../clean_architecture.md), [Architecture Details](../architecture_details.md) |

## Context

The app contains several independent feature areas, including authentication,
chat, maps, settings, offline data, and demo workflows. These areas need to
stay testable and maintainable as the codebase grows.

The architecture must support:

- pure business contracts that can be tested without Flutter;
- replaceable data implementations for local, remote, and offline-first flows;
- route-scoped state management for user workflows;
- centralized dependency wiring so feature composition remains visible;
- clear review rules for code that belongs in app shell, feature layers, shared
  infrastructure, or core infrastructure.

## Decision Drivers

- Preserve clear dependency direction: `Presentation -> Domain <- Data`.
- Keep domain code free of Flutter, SDK, storage, HTTP, and navigation details.
- Make business logic easy to test with unit and bloc tests.
- Keep shared infrastructure reusable without making it an extra feature layer.
- Make new feature delivery repeatable.
- Keep app shell composition separate from feature business logic.

## Decision

Use feature-based Clean Architecture with three feature layers:

- **Domain**: pure Dart contracts, models, and value objects.
- **Data**: implementations of domain contracts, including storage, HTTP/SDK
  adapters, offline-first composition, and merge policies.
- **Presentation**: pages, widgets, Cubits/BLoCs, and route-specific workflow
  orchestration.

Use these supporting areas around the feature layers:

- `apps/mobile/lib/app/` for the app shell, router, and app-scope composition.
- `apps/mobile/lib/core/` for bootstrap, DI, constants, theme, app-wide contracts, and
  platform-level helpers.
- `apps/mobile/lib/shared/` for reusable storage, sync, widgets, design tokens, and
  utilities used by multiple features.

Use `flutter_bloc` Cubits/BLoCs for state management and `get_it` for
dependency injection. Register feature dependencies through `apps/mobile/lib/core/di/`
using feature-specific factories or registration helpers.

The governing rule is dependency direction, not folder count. Small features
may stay compact, but code still follows the same ownership boundaries.

## Alternatives Considered

| Alternative | Why not |
| --- | --- |
| Flat feature folders | Simpler at first, but business logic, UI, and data access become harder to test and reason about independently. |
| Riverpod-only architecture | Combines DI and state management, but this repo already optimizes around explicit Cubit/BLoC flows and separate DI. See [State Management Choice](../state_management_choice.md). |
| MVC/MVVM without BLoC | Familiar patterns, but they do not give this repo the same explicit state transitions, selectors, and bloc-test surface. |
| Widget-level service locator lookups | Convenient, but hides dependencies and makes UI tests more fragile. Widgets should use Cubits/BLoCs or explicit constructor inputs. |

## Consequences

### Benefits

- Responsibilities are easy to locate by layer and feature.
- Domain contracts remain fast to test and stable across data implementation
  changes.
- Cubits depend on abstractions, which keeps bloc tests deterministic.
- Feature delivery follows a repeatable path: domain contract, data
  implementation, Cubit/BLoC, widgets, DI, route, tests.
- Offline-first repositories fit in the data layer without leaking queue or
  merge policy into widgets.

### Costs

- More files and boilerplate than a flat feature structure.
- Contributors must understand layer rules and DI conventions before making
  larger changes.
- Missing `get_it` registrations fail at runtime or test time, not compile
  time.
- Shared/core boundaries need review discipline so reusable helpers do not
  become feature-specific dumping grounds.

## Implementation Notes

- Domain files must not import Flutter or presentation packages.
- Presentation should depend on domain contracts, not concrete repositories.
- Data implementations should satisfy domain contracts and hide local/remote
  details.
- App shell code composes features; it should not own feature business logic.
- New persistent stores should use shared storage abstractions such as
  `HiveRepositoryBase` or `HiveSettingsRepository<T>`.

## Review Triggers

Revisit this ADR when:

- a new state-management or DI strategy is proposed;
- feature modules move into separate packages;
- app shell code starts owning feature-specific business rules;
- domain code needs Flutter, platform, HTTP, storage, or router imports.

## Verification

- Architecture overview: [Architecture Details](../architecture_details.md)
- Layer rules and examples: [Clean Architecture](../clean_architecture.md)
- Quality gates: [Code Quality](../CODE_QUALITY.md)
- Targeted command for Hive boundary drift: `./tool/check_no_hive_openbox.sh`
