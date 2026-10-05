# Widget composition and rebuild boundaries

How to structure Flutter UI so extraction creates real **Element** boundaries —
not just smaller files. Complements (does not replace)
[`flutter_fundamentals_and_production_practices.md`](flutter_fundamentals_and_production_practices.md)
(three trees, `Widget.canUpdate`, keys) and
[`design_system.md`](../design_system.md) § Reusable widgets (preview/test leaf
contract).

Official canon:

- [Perf best practices — Control `build()` cost](https://docs.flutter.dev/perf/best-practices)
- [StatefulWidget — Performance considerations](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)
- [Widgets vs helper methods](https://www.youtube.com/watch?v=IOyq-eTRhvo) (Flutter YouTube)

---

## Intentional widgets ≠ file splits

Breaking a giant screen into more files only helps architecture when the pieces
are **widgets** (immutable configs with their own Element slots) chosen by
**what changes together**. Moving the same mega-`build()` into
`profile_screen_body.dart` without boundaries is organization, not architecture.

This repo already places feature UI under `presentation/pages/` and
`presentation/widgets/`
([feature structure contract](../architecture/feature_structure_contract.md)).
Use that layout to express change locality, not only LOC limits.

## Prefer widgets over `_build*` helpers

Flutter’s StatefulWidget docs: when creating reusable UI, **prefer a widget
rather than a helper method**. A function/`_buildHeader()` returns widgets
inline inside the parent’s `build`. On `setState` (or parent rebuild), the
framework must rebuild that returned subtree as part of the parent Element. A
child **Widget** class — especially with a `const` constructor — can be
re-encountered as the **same instance** so the rebuild walk short-circuits.

| Pattern | Element boundary | `const` / same-instance skip | Use when |
| --- | --- | --- | --- |
| Giant `build()` | One inflated subtree | Hard | Avoid for screens that rebuild often |
| `_buildFoo()` / local `Widget foo()` | No new Element type slot | Usually no | Tiny one-liners only; not “architecture” |
| `StatelessWidget` / leaf widget class | Yes | Yes if `const` + stable inputs | Default extraction |
| Leaf `StatefulWidget` | Yes + local `State` | Push ticking/`setState` here | Ephemeral UI (snackbar flag, ticker) |

Repo file-size guidance says “extract widgets/helpers”
([`CODE_QUALITY.md`](../CODE_QUALITY.md)). Prefer **widgets**; keep helpers for
non-UI or trivial glue.

## Split by how UI changes

From perf best practices:

1. **Localize rebuild owners** — `setState` / Inherited deps only where the
   visible change lives (“push state to the leaves”).
2. **Cache stable subtrees** — `const` children, or a `final` field on `State`
   that reuses the same widget instance across builds.
3. **Avoid depth/type thrash** — prefer toggling a property (e.g.
   `IgnorePointer.ignoring`) over conditionally wrapping/unwrapping layers.
4. **Feature state** — for business/async UI, narrow with Cubit selectors
   (`TypeSafeBlocSelector`, `buildWhen`), not a page-wide `BlocBuilder`. See
   fundamentals § Widget identity practical consequence and
   [QG-D03](../changes/2026-08-04_bloc_rebuild_scoping_qg-d03.md).

## Keys and identity (pointer)

Sibling identity, list reorder, and `GlobalKey` pitfalls live in fundamentals
§ **Widget identity: update, replace, or rebuild** and
[`../changes/2026-06-16_widget-list-stable-keys.md`](../changes/2026-06-16_widget-list-stable-keys.md).
Composition does not replace keys: wrong keys still attach the wrong Element /
`State` after a clean widget split.

## Anti-patterns (presentation)

- One screen-sized `build()` that rebuilds on every tick or Cubit emit.
- “Refactor” that only introduces `_buildSectionA/B/C` without widget classes.
- Extracting widgets for reuse/test while still calling `setState` at the page
  root for leaf-only changes.
- Recreating `GlobalKey`s every `build` (throws away subtree state).
- Creating `Future`s / `Stream`s inside `build` (AP-19 in
  [`flutter-anti-patterns.md`](flutter-anti-patterns.md)).

## Repo anchors

- Counter body selector (narrow rebuild):
  `apps/mobile/lib/features/counter/presentation/widgets/counter_page_body.dart`
- Leaf constructor-driven widgets: [`design_system.md`](../design_system.md)
  § Reusable widgets
- Gates: `bash tool/check_widget_identity.sh`,
  `bash tool/check_bloc_rebuild_scoping.sh`,
  `bash tool/check_perf_unnecessary_rebuilds.sh`

**Interview one-liner:** *Extract widgets for change locality and Element
boundaries (`const` where possible); file splits and `_build*` helpers alone do
not skip rebuilds.*
