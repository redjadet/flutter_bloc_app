# ADR 0001: Architecture and Layering

Status: Accepted

## Context

The app includes multiple feature areas (auth, chat, maps, settings, offline data) and is expected to remain testable and maintainable as features grow.

## Decision

- Use a feature-based layout with Domain -> Data -> Presentation layers.
- Keep the domain layer Flutter-free for testability.
- Use BLoC/Cubit for state management.
- Centralize dependency wiring under `lib/core/di/`.

## Consequences

- Increased boilerplate and more files per feature.
- Clear ownership of responsibilities and improved test isolation.
- Easy to swap data implementations behind domain contracts.
