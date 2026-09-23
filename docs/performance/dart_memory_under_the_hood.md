# Dart memory under the hood: heap, GC, and object lifetimes

Canonical mental model for how Dart manages Flutter objects in this repo.
Ownership and dispose rules still live in
[`memory_management.md`](memory_management.md); this page explains **why** those
rules matter and how to investigate without confusing GC noise for leaks.

Upstream:

- [Flutter memory management](https://docs.flutter.dev/perf/memory)
- [DevTools Memory view](https://docs.flutter.dev/tools/devtools/memory)
- [Don’t fear the garbage collector](https://flutter.dev/blog/flutter-dont-fear-the-garbage-collector)
- [Dart `Finalizer`](https://api.dart.dev/stable/dart-core/Finalizer-class.html)
- [AnimationController disposal](https://api.flutter.dev/flutter/animation/AnimationController-class.html)

## Takeaway

Dart collects **unreachable** objects. Application code must still end ownership,
release resources, and avoid retaining objects longer than needed. GC does not
replace `dispose` / `close` / cancel / `removeListener`.

## Heap and object lifetime

Dart objects created with constructors live in a **managed heap**. The runtime
allocates at creation and may reclaim memory only after nothing reachable from
the program still refers to the object.

| Fact | Implication |
| --- | --- |
| Eligibility ≠ collection | An object becomes *eligible* when all retaining paths are gone; collection is **eventual**, not immediate |
| Generational GC (native) | Short-lived objects are usually cheap; long-lived retainers cost more than “lots of allocation” alone |
| Reachability is truth | If a global cache, DI singleton, listener, timer, or closure still points at an object, GC correctly keeps it |

Flutter creates many short-lived objects during normal UI work. That is expected.
Prefer ending ownership over micro-optimizing allocation volume.

## Why “leaks” still happen

The collector is not wrong when an unused object stays alive: something still
**reaches** it. Common retainers in Flutter apps:

| Retainer | Example in this repo’s rules |
| --- | --- |
| Global / static cache | Feature static caches must participate in `AppMemoryService` trim (chart points, locale `NumberFormat`s) |
| Long-lived service / singleton | DI-owned repos with open `StreamController`s or subscriptions — see [`REPOSITORY_LIFECYCLE.md`](../engineering/REPOSITORY_LIFECYCLE.md) |
| Listener / subscription / timer | Cubit `registerSubscription` / `registerTimer`; widget `DisposableBag` |
| Closure capture | Async callback or long-lived listener that closes over a short-lived `BuildContext`, `State`, or large model |
| Forgotten dispose | Controllers / `FocusNode` owned by `State` — enforced by `memory_state_controller_missing_dispose` |

A classic Flutter case: a closure retains a **short-lived `BuildContext`**.
Static `BuildContext` fields are linted (`memory_static_build_context`);
closure capture is still a **manual** review item (Wave B backlog — see
[`memory_lints.md`](memory_lints.md)).

## GC does not replace cleanup

Cancel subscriptions and dispose controllers when their owner’s lifecycle ends.
Native buffers, images, GPU, and other **external** memory also affect the
process footprint: a small Dart heap does **not** guarantee low resident memory.

| Resource | Required cleanup | Fallback |
| --- | --- | --- |
| `AnimationController`, `TextEditingController`, scroll/page/tab/`FocusNode` | `.dispose()` in `State.dispose()` before `super.dispose()` | None — ownership path |
| `StreamSubscription` / `StreamController` | Cancel / `close()` on cubit `close()` or service `dispose()` | None |
| `WidgetsBindingObserver` | `removeObserver` in teardown | None |
| Image / SVG / feature static caches | Trim via `AppMemoryService` | None |
| Native / FFI / plugins | Explicit release APIs on the ownership path | `Finalizer` only as last resort |

A [`Finalizer`](https://api.dart.dev/stable/dart-core/Finalizer-class.html) is
**only a fallback**: its callback is not guaranteed to run (or to run promptly).
Do not use it as the primary disposal strategy for controllers or subscriptions.

Repo primitive: end every disposable on the same path that created it
([`memory_management.md`](memory_management.md)).

## How to investigate

1. **Reproduce** the interaction that should free memory (open → use → leave).
2. Take **heap snapshots** before and after; **diff** them.
3. Inspect **retaining paths** for objects that should be gone.
4. Check **Dart heap**, **external**, and **resident** memory separately in
   DevTools — do not conclude from one number alone.
5. Remember: repeated allocation or frequent GC alone does **not** prove a leak.

Prefer repo automation first when the surface is covered:

| Lane | Command / doc |
| --- | --- |
| Static ownership | `bash tool/run_memory_lint.sh` — [`memory_lints.md`](memory_lints.md) |
| Tagged leak_tracker | `bash tool/run_memory_leak_tests.sh` — [`memory_testing.md`](memory_testing.md) |
| Review questions | [`memory_checklist.md`](memory_checklist.md) |
| Interactive / unknown | [DevTools Memory](https://docs.flutter.dev/tools/devtools/memory) (diff snapshots, retaining paths) |

On tagged `leak_tracker` failure: confirm ownership, fix teardown, or document a
narrow ignore with an audit entry — never restore global ignore for tagged tests.

## Repo map

| Concern | Owner |
| --- | --- |
| Ownership principles | [`memory_management.md`](memory_management.md) |
| Trim under pressure | `AppMemoryService` + `register_app_memory_services.dart` |
| Cubit / repo lifecycle | [`bloc_standards.md`](../bloc_standards.md), [`REPOSITORY_LIFECYCLE.md`](../engineering/REPOSITORY_LIFECYCLE.md) |
| Historical leak audit | [`memory_leaks_analysis.md`](memory_leaks_analysis.md) |
