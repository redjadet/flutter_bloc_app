# Memory / lifecycle review checklist

Use when a change owns controllers, streams, timers, observers, or long-lived
services. Docs-only PRs may mark N/A.

**Rule:** Every created disposable object's life-cycle must be explicitly ended
(`dispose` / `close` / cancel / `removeListener` / `removeObserver`) on the
same ownership path that created it. No orphaned controllers, subscriptions,
timers, observers, or sinks. GC only collects unreachable objects; it does not
replace this cleanup
([`dart_memory_under_the_hood.md`](dart_memory_under_the_hood.md)).

- [ ] Disposable resources disposed (`dispose` / `close`) — ownership path clear
- [ ] Stream subscriptions cancelled (or registered via `CubitSubscriptionMixin` / `DisposableBag`)
- [ ] `StreamController`s closed
- [ ] Timers cancelled / handles disposed
- [ ] Listeners removed (`removeListener` / `removeObserver`)
- [ ] No retained `BuildContext` / `Widget` / `State` in statics, singletons, or long-lived closures
- [ ] Static / global caches bounded or cleared on `AppMemoryService` trim (not `Finalizer`-only)
- [ ] Tagged leak test added or existing suite still covers the surface
- [ ] Proof: `bash tool/run_memory_lint.sh` and/or `bash tool/run_memory_leak_tests.sh` when lifecycle changed
- [ ] Suspected leak: reproduce → snapshot/diff → retaining paths; separate heap vs external vs RSS (allocation/GC frequency alone ≠ leak)

See [`memory_management.md`](memory_management.md).
