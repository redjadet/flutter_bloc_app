# ADR 0001: Architecture and Layering

**Status:** Accepted

## Context

The app includes multiple feature areas (auth, chat, maps, settings, offline
data) and is expected to remain testable, maintainable, and extensible as
features grow. The team needed a scalable architecture pattern that enforces
separation of concerns and supports both unit testing of business logic and
widget-level testing of UI.

## Alternatives Considered

1. **Single-layer feature folders** (all code in one folder per feature).
   Simpler file structure but no enforced separation between business logic,
   data access, and UI — harder to test in isolation.
2. **Riverpod-based architecture** (providers replace DI + state management).
   Combines DI and state in one system but can blur layer boundaries and has a
   steeper learning curve. See
   [State Management Choice](../state_management_choice.md) for detailed
   comparison.
3. **MVC / MVVM without BLoC.** Familiar patterns but lack the explicit
   event-driven data flow and replay/debug tooling that BLoC provides.

## Decision

- Use a **feature-based layout** with **Domain → Data → Presentation** layers
  inside each feature (`lib/features/<feature>/domain|data|presentation/`).
- Keep the **domain layer Flutter-free** (pure Dart) for fast unit tests.
- Use **BLoC/Cubit** (via `flutter_bloc`) for state management.
- Centralize dependency wiring under `lib/core/di/` with **get_it** and
  feature-specific registration files.
- Cross-cutting concerns (storage, sync, HTTP, responsive helpers) live in
  `lib/shared/` and `lib/core/`.

## Consequences

### Benefits

- Clear ownership of responsibilities per layer — easy to find where logic
  lives.
- Domain contracts are testable with pure Dart; data-layer implementations are
  substitutable via DI.
- Cubits depend on abstractions, making bloc tests fast and deterministic.
- Adding a new feature follows a repeatable pattern (domain contract → data
  impl → cubit → widgets → DI → route).

### Costs

- Increased boilerplate: every feature requires at minimum a domain interface,
  a data implementation, a cubit, a page widget, a DI registration, and a
  route entry.
- Developers must understand the layering rules and DI conventions before
  contributing; onboarding cost is higher than a flat architecture.
- Runtime DI (`get_it`) means missing registrations are caught at test time, not
  compile time.
