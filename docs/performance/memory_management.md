# Memory management (Wave A)

Ownership and lifecycle principles for preventing memory leaks. Prefer
automation (`memory_lint`, tagged `leak_tracker` tests, checklist) over
manual review alone.

## Canon primitives

| Primitive | Location | Use |
| --- | --- | --- |
| `DisposableBag` | `packages/utilities` | Track subscriptions / disposables for widgets and services |
| `CubitSubscriptionMixin` | `apps/mobile/lib/app/utils/bloc/` | Cancel registered stream subscriptions and timers on `close()` |
| `SubscriptionManager` / `TimerHandleManager` | `packages/utilities` | Repository/service delayed-restart and subscription facades |
| Repository dispose | [`docs/REPOSITORY_LIFECYCLE.md`](../REPOSITORY_LIFECYCLE.md) | When DI-owned repos must implement `dispose()` |

## Controllers (widget State)

Own `TextEditingController`, `AnimationController`, `ScrollController`,
`PageController`, `TabController`, and `FocusNode` in `State`. Create in
`initState` (or `late final` assigned there); call `.dispose()` in `dispose()`
before `super.dispose()`. Enforced by `memory_state_controller_missing_dispose`.

## Cubits / Blocs

Register every `stream.listen` with `registerSubscription` (or cancel in
`close()`). Register timer handles with `registerTimer`. Always call
`super.close()` last. See [`docs/bloc_standards.md`](../bloc_standards.md).

## Repositories / services

If the type owns `StreamController`, subscriptions, WebSockets, or timers,
implement `dispose()`/`close()` and wire it through DI dispose callbacks.
See [`REPOSITORY_LIFECYCLE.md`](../REPOSITORY_LIFECYCLE.md). Enforced partly by
`memory_stream_controller_missing_close` and existing `close_sinks` /
`cancel_subscriptions` analyzer errors.

## WidgetsBindingObserver

Every `addObserver(this)` needs `removeObserver(this)` in teardown. Enforced by
`memory_widgets_binding_observer_missing_remove`.

## BuildContext retention

Do not store `BuildContext` in `static` fields. Enforced by
`memory_static_build_context`.

## Related docs

- [`memory_testing.md`](memory_testing.md) — leak_tracker tagged suite
- [`memory_lints.md`](memory_lints.md) — rule IDs
- [`memory_ci.md`](memory_ci.md) — checklist / CI
- [`memory_checklist.md`](memory_checklist.md) — reviewer questions
- Historical audit: [`../memory_leaks_analysis.md`](../memory_leaks_analysis.md)

## Wave B backlog

- Flip global `withIgnoredAll` after measured allowlists
- Timer / listener / `ChangeNotifier` / GetIt+context AST rules
- Broader tagged journeys (auth cycles, infinite scroll)
- Evaluate retiring shell `check_memory_*.sh` heuristics after AST coverage
