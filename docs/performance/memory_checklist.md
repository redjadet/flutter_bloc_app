# Memory / lifecycle review checklist

Use when a change owns controllers, streams, timers, observers, or long-lived
services. Docs-only PRs may mark N/A.

**Rule:** Every created disposable object's life-cycle must be explicitly ended
(`dispose` / `close` / cancel / `removeListener` / `removeObserver`) on the
same ownership path that created it. No orphaned controllers, subscriptions,
timers, observers, or sinks.

- [ ] Disposable resources disposed (`dispose` / `close`) — ownership path clear
- [ ] Stream subscriptions cancelled (or registered via `CubitSubscriptionMixin` / `DisposableBag`)
- [ ] `StreamController`s closed
- [ ] Timers cancelled / handles disposed
- [ ] Listeners removed (`removeListener` / `removeObserver`)
- [ ] No retained `BuildContext` / `Widget` / `State` in statics or singletons
- [ ] Tagged leak test added or existing suite still covers the surface
- [ ] Proof: `bash tool/run_memory_lint.sh` and/or `flutter test --tags memory_leak` when lifecycle changed

See [`memory_management.md`](memory_management.md).
