# State Management Choice: BLoC/Cubit

Rationale for the app-state decision accepted by
[`ADR 0001`](../adr/0001-architecture-and-layering.md). Implementation rules live in
[`bloc_standards.md`](../bloc_standards.md); architecture boundaries live in
[`clean_architecture.md`](../clean_architecture.md).

## Decision

Use Cubit by default. Use BLoC when explicit events, event transforms, or event
auditability add value. Do not add Riverpod, BlocSignal (`bloc_signals` /
`bloc_signals_flutter`), or another state-management system without an accepted
ADR. See [`ADR 0007`](../adr/0007-blocsignal-evaluation.md) for the BlocSignal
evaluation.

Reasons:

- explicit immutable state transitions
- strong `bloc_test` support
- predictable dependency injection and lifecycle
- clean presentation/domain boundary
- scoped rebuilds through `BlocSelector` and `buildWhen`
- mature Flutter tooling and existing repo investment

This is a consistency decision, not a claim that BLoC is universally superior.
Riverpod may fit smaller apps, provider-heavy dependency graphs, or teams already
standardized on it; those conditions do not outweigh migration cost here.

BlocSignal offers BLoC-shaped APIs on a synchronous signals foundation (fine
rebuild granularity, streamless concurrency transformers, primary-constructor
friendly ceremony). That does not outweigh this repo’s Cubit-first stack,
type-safe helpers, and `bloc_test` investment. Steal the *practices* below;
do not steal the package stack.

## Placement

| Concern | Owner |
| --- | --- |
| Widgets/pages | Render state and send intent; no business rules |
| Cubit/BLoC | Presentation state, user-flow orchestration, cancellation |
| Domain | Pure models, invariants, use cases, repository contracts |
| Data | Repository implementations, DTO mapping, SDK/storage/network access |
| App shell | DI, routes, app-scope providers/listeners |

Canonical path:
`apps/mobile/lib/features/<feature>/presentation/cubit/`. Cubit/BLoC never
lives in `domain/` or `data/`. Presentation depends on domain abstractions, not
data implementations.

## Cubit vs BLoC

Use Cubit when commands map directly to state transitions:

- load/refresh/save flows
- settings and form state
- route-scoped feature state
- simple async orchestration

Use BLoC when events themselves matter:

- concurrent event policy (`restartable`, `droppable`, sequential)
- multiple event sources share one state machine
- event ordering or replay needs explicit tests
- debounced/throttled input is central behavior

Do not choose BLoC only to create ceremony. Do not choose Cubit when hidden
concurrency policy would make behavior ambiguous.

## Practices aligned with BlocSignal claims (without adopting it)

| Claim / practice | Repo equivalent |
| --- | --- |
| Low ceremony from one cubit to many | Cubit default; almost all features use Cubit, not Bloc |
| Dart 3.13 primary constructors | [`CODE_QUALITY.md`](../CODE_QUALITY.md) for DTOs and optional Cubit shortening; Freezed state stays generated |
| Fine-grained rebuilds | `TypeSafeBlocSelector` / `buildWhen` (ADR 0004) |
| Avoid state hanging on data types | Never put Cubit/Bloc (or signal mixins) on repositories — presentation only |

## Required state properties

- Immutable, preferably Freezed for new state/models.
- Exhaustive states or fields that cannot form invalid combinations.
- Typed failures; no raw SDK exceptions in presentation state.
- Stable equality for selector output.
- No allocating list getters used directly by selectors.
- Request identity or cancellation where stale async results can arrive.

Compile-time access uses repo extensions such as `context.cubit<T>()`; see
[`compile_time_safety.md`](compile_time_safety.md). Never use dynamic state,
string event names, or untyped service lookup to bypass analyzer checks.

## Lifecycle and error contract

- Cancel subscriptions/timers in `close()` or use repo lifecycle helpers.
- Guard emissions after async gaps (`isClosed` / request identity as suitable).
- Guard `BuildContext` after `await` with `context.mounted`.
- Map infrastructure errors before state emission.
- Log through `AppLogger`; expose user-safe messages through typed failures.
- Keep navigation and UI side effects in presentation listeners, not domain/data.

Owners: [`bloc_standards.md`](../bloc_standards.md),
[`reliability_error_handling_performance.md`](../reliability_error_handling_performance.md),
and [`review/bloc_checklist.md`](../review/bloc_checklist.md).

## Performance contract

- Select minimal stable view data.
- Prefer `BlocSelector` / `buildWhen` for expensive subtrees.
- Keep state collections immutable.
- Preserve stable widget keys for dynamic rows.
- Measure before adding caching or custom equality complexity.

Performance rules and guards: [`review/performance_checklist.md`](../review/performance_checklist.md)
and [`validation_scripts/catalog.md`](../validation_scripts/catalog.md).

## Testing and proof

For behavior changes:

1. Unit-test pure domain rules.
2. Use `bloc_test` for state sequences, failures, cancellation, and stale-result paths.
3. Use widget tests for rendering, listeners, and interaction wiring.
4. Run `./tool/analyze.sh` plus focused tests.
5. Route broad proof through [`engineering/validation_routing_fast_vs_full.md`](../engineering/validation_routing_fast_vs_full.md).

Minimum review:

- state represents loading/success/empty/error honestly
- no repository/SDK construction in presentation
- no business logic in widgets
- lifecycle cleanup proven
- selectors return stable values
- denial/failure paths tested when applicable

## Related

- [`bloc_standards.md`](../bloc_standards.md)
- [`clean_architecture.md`](../clean_architecture.md)
- [`architecture/feature_structure_contract.md`](feature_structure_contract.md)
- [`compile_time_safety.md`](compile_time_safety.md)
- [`testing_overview.md`](../testing_overview.md)
- [`ADR 0007 — BlocSignal evaluation`](../adr/0007-blocsignal-evaluation.md)
