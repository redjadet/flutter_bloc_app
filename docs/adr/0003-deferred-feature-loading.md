# ADR 0003: Deferred Feature Loading

| Field | Value |
| --- | --- |
| Status | Accepted |
| Date | 2026-01-16 |
| Scope | Routing, startup time, bundle size |
| Source docs | [Architecture Details](../architecture_details.md), [Lazy Loading Review](../lazy_loading_review.md) |

## Context

Some features are heavy, infrequently used, or demo-oriented. Examples include
maps, charts, markdown editing, and WebSocket demos. Loading those screens and
their dependencies during app startup increases initial bundle size and startup
work even when users never open them.

The app needs fast common-path startup while keeping these features available
through normal routes.

## Decision Drivers

- Keep the initial app bundle focused on common flows.
- Keep route definitions explicit and easy to inspect.
- Avoid loading heavy feature code until navigation requires it.
- Keep user-facing loading and failure states consistent for deferred screens.
- Keep core screens and app shell eagerly available.
- Keep deferred boundaries visible in route code so startup optimizations remain
  reviewable.

## Decision

Use Dart deferred imports for heavy or infrequently used routed features.

Deferred routes use:

- `deferred as` imports in route files;
- `DeferredPage` to call `loadLibrary()`;
- a route-local builder function from the deferred library;
- shared loading and error UI while the library loads.

Core app shell, auth, settings, and frequently used screens stay eagerly loaded.
Only feature code with meaningful startup or bundle-size impact should be
deferred.

Deferred loading is a routing decision. It should not be used to hide
incomplete dependency wiring, slow synchronous initialization, or missing
feature cleanup.

## Alternatives Considered

| Alternative | Why not |
| --- | --- |
| Eagerly load every feature | Simplest routing, but increases startup work and initial bundle size. |
| Dynamic feature plugins | More complex platform setup than this app needs for current feature boundaries. |
| Hide heavy demos behind build flags only | Reduces some builds, but removes normal route-level access and makes QA coverage harder. |
| Lazy DI without deferred imports | Delays service construction, but still ships feature code in the initial bundle. |

## Consequences

### Benefits

- Common startup path stays smaller and faster.
- Heavy feature boundaries are visible in router files.
- Loading and retry UI are centralized through `DeferredPage`.
- Feature code can still be reached through normal GoRouter routes.

### Costs

- Deferred pages need explicit builder functions and route wiring.
- Route entry must handle loading and load failures.
- Deferred libraries must avoid assumptions that eager initialization already
  ran.
- Developers need to keep deferred boundaries intentional during refactors.

## Implementation Notes

- Keep deferred route wrappers in `apps/mobile/lib/app/router/`.
- Keep deferred page entrypoints in `apps/mobile/lib/app/router/deferred_pages/`.
- Use `DeferredPage` rather than ad hoc `FutureBuilder` wrappers for route
  loading.
- Register services lazily where possible; deferred imports and lazy DI solve
  different problems and can be used together.
- Do not defer small or core user flows without a measured or obvious startup
  benefit.

## Review Triggers

Revisit this ADR when:

- bundle-size or startup profiling changes which features are heavy;
- a core route becomes deferred;
- deferred routes need prefetching or route-level preload policy;
- platform deployment changes how deferred imports are packaged.

## Verification

- Architecture lazy-loading overview: [Architecture Details — lazy loading](../architecture_lazy_loading_and_flow.md#lazy-loading-patterns)
- Implementation review: [Lazy Loading Review](../lazy_loading_review.md)
- Targeted tests: `flutter test test/shared/widgets/deferred_page_test.dart`
