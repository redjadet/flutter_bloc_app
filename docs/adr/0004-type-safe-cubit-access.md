# ADR 0004: Type-Safe Cubit Access

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-01-16 |
| Scope | Presentation state access |
| Source docs | [Compile-Time Safety](../architecture/compile_time_safety.md), [State Management Choice](../architecture/state_management_choice.md) |

## Context

Flutter BLoC APIs such as `context.read<T>()`, `context.watch<T>()`, and
`BlocProvider.of<T>()` are flexible, but they are easy to use inconsistently in
large widget trees. Missing providers still fail at runtime, and direct generic
usage can produce less helpful errors when a route or test forgets to provide a
Cubit/BLoC.

The repo needs a consistent presentation-layer access pattern that keeps state
types explicit and diagnostics readable.

## Decision Drivers

- Make Cubit/BLoC access self-documenting in UI code.
- Preserve rebuild control through selectors.
- Improve missing-provider error messages.
- Keep direct BLoC APIs available when the wrapper does not fit a specific
  integration point.
- Avoid moving business state into widgets.
- Keep rebuild boundaries explicit for performance-sensitive UI.

## Decision

Use the shared type-safe BLoC access helpers for routine presentation code:

- `context.cubit<T>()` / `context.bloc<T>()` for required access;
- `context.tryCubit<T>()` / `context.tryBloc<T>()` for optional access;
- `context.state<C, S>()` and `context.watchState<C, S>()` for typed state
  reads;
- `context.selectState<C, S, T>()` for selected rebuilds;
- `TypeSafeBlocSelector`, `TypeSafeBlocBuilder`, `TypeSafeBlocListener`, and
  `TypeSafeBlocConsumer` for typed widget composition.

Prefer `TypeSafeBlocSelector` when a widget needs a small slice of state and
can avoid rebuilding for unrelated state changes. Direct `BlocBuilder`,
`BlocListener`, or `context.read<T>()` remains acceptable for narrow cases where
it is clearer, required by an API, or already well-contained.

This decision improves consistency and diagnostics; it does not make provider
availability a compile-time guarantee. Route and widget tests still need to
provide the required Cubits/BLoCs.

## Alternatives Considered

| Alternative | Why not |
| --- | --- |
| Raw `context.read/watch/select` everywhere | Works, but gives less consistent diagnostics and makes access conventions harder to scan. |
| Global Cubit lookup through `get_it` | Hides widget-tree ownership and weakens route/test isolation. |
| Always use `BlocBuilder` for state | Simple, but often rebuilds more UI than necessary. |
| Custom state management layer | Adds abstraction without replacing the repo's existing BLoC/Cubit investment. |

## Consequences

### Benefits

- UI access patterns become easier to scan and review.
- Missing providers produce clearer `StateError` messages from shared helpers.
- Selectors make rebuild boundaries explicit.
- Tests can assert helper behavior directly.

### Costs

- Presentation code must import the shared extensions/widgets.
- Some wrappers add a small amount of generic boilerplate.
- The rule is a preference, not a blanket ban; reviewers still need judgment
  for direct BLoC API use.

## Implementation Notes

- Extension helpers live in `apps/mobile/lib/app/extensions/type_safe_bloc_access.dart`.
- Typed widgets live in `apps/mobile/lib/app/widgets/type_safe_bloc_selector.dart`.
- Keep Cubit/BLoC instances route-scoped unless app-wide state is intentional.
- Do not use type-safe access helpers to bypass constructor injection for
  reusable widgets that should receive dependencies explicitly.

## Review Triggers

Revisit this ADR when:

- the app changes primary state-management library;
- generated provider wiring or route-scoped dependency checks become available;
- direct BLoC API use grows enough that the preferred convention is no longer
  representative;
- selector usage causes readability or rebuild-debugging problems.

## Verification

- Helper tests: `cd apps/mobile && flutter test test/shared/extensions/type_safe_bloc_access_test.dart`
- Widget tests: `cd apps/mobile && flutter test test/shared/widgets/type_safe_bloc_selector_test.dart`
- Broader guidance: [Compile-Time Safety](../architecture/compile_time_safety.md)
