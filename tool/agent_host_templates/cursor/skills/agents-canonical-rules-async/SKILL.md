---
name: agents-canonical-rules-async
description: Canonical rules — cubit lifecycle, subscriptions, timers, stream safety, widget async/mounted, coordinators. Part of agents-canonical-rules split.
---

# Lifecycle & async safety

Slice of **`agents-canonical-rules`**. **Patterns:** `agents-shared-patterns`. **Checklist:** `agents-common-pitfalls`, `agents-validation-testing`.

## Cubits & repos

- `CubitExceptionHandler` + `isAlive: () => !isClosed`.
- After every `await`/callback: `if (isClosed) return` before `emit()`.
- `CubitSubscriptionMixin` + `registerSubscription`; cancel in `close()`.
- `TimerService.runOnce` (not `Future.delayed`); dispose handles in `close()`.
- `RequestIdGuard` (cubits), `InFlightCoalescer` / `KeyedInFlightCoalescer` (repos).
- `SubscriptionManager`: check `isDisposed`, owner `dispose()`, careful `unregister`.
- Restart listeners: `cancelOnError: true`; cancel prior on error restart.
- `stream.listen`: include `onError` + `AppLogger.error`.
- `StreamControllerSafeEmit` / `StreamControllerLifecycle` for shared controllers.
- Coordinators: serialize in-flight work; coalesce triggers; unawaited wrappers catch `on Object`.
- Repos/services/widgets: re-check closed/disposed/mounted before delayed side effects.

## Widgets & UI async

- Inherited state in `build()`/`didChangeDependencies()` (one-shot flag for startup), not `initState()`.
- Optional providers: guard before `context.cubit` / typed selectors; degrade safely.
- After `await`: `if (!context.mounted) return`; before `setState`: `if (!mounted) return` (incl. `finally`).
- Dialog `TextEditingController`: dialog `StatefulWidget` owns create/dispose.
- Snackbars: `ErrorHandling.hideCurrentSnackBar` / `clearSnackBars`.
- Auth UI: `StreamBuilder` with `initialData: auth.currentUser` to avoid sign-out flicker.
