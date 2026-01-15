# ADR 0004: Type-Safe Cubit Access

Status: Accepted

## Context

`context.read<T>()` and `BlocProvider.of<T>()` are runtime-only checks and can produce hard-to-debug provider errors in larger widget trees.

## Decision

- Use type-safe accessors and selectors from `lib/shared/extensions/type_safe_bloc_access.dart`.
- Prefer `TypeSafeBlocSelector` over direct `BlocBuilder` access.

## Consequences

- Small amount of boilerplate for type-safe extensions.
- Improved diagnostics and more explicit access patterns in UI code.
