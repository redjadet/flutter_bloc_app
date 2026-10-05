# CustomPainter & RenderObject — contract

Use custom painting when widgets cannot express the visual. Prefer
`CustomPainter` for data-driven paint; use a custom `RenderObject` only when
you need layout + paint control.

## When

| Approach | Use when |
| --- | --- |
| `CustomPainter` | Rings, charts, badges, whiteboard strokes — parent owns layout |
| `RenderObject` | Custom layout + paint (e.g. markdown preview layout) |

## Architecture

- Keep painters **presentation-only**. Cubit/BLoC own domain state; painter
  receives immutable view data.
- Do not put networking, Hive, or DI inside `paint` / `performLayout`.
- Prefer `shouldRepaint` / `shouldRebuild` that compare meaningful fields.

## Dirty marking (layout vs paint)

Flutter does **not** eagerly relayout or repaint the whole tree when a
`RenderObject` mutates. Writes mark stages dirty; `PipelineOwner` flushes them
on the next visual update in order: **layout → compositing bits → paint →
semantics** ([`PipelineOwner`](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html)).

| Call | Use when | Isolation |
| --- | --- | --- |
| [`markNeedsLayout`](https://api.flutter.dev/flutter/rendering/RenderObject/markNeedsLayout.html) | Geometry may change (text, padding, constraints-sensitive fields) | Bubbles to the nearest **relayout boundary**, then that node registers with the pipeline owner |
| [`markNeedsPaint`](https://api.flutter.dev/flutter/rendering/RenderObject/markNeedsPaint.html) | Appearance changes without size change | Bubbles to the nearest [`isRepaintBoundary`](https://api.flutter.dev/flutter/rendering/RenderObject/isRepaintBoundary.html) (often a [`RepaintBoundary`](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html) widget) |
| [`markNeedsSemanticsUpdate`](https://api.flutter.dev/flutter/rendering/RenderObject/markNeedsSemanticsUpdate.html) | Accessibility description changes | Semantics tree only — not layout/paint |

**Relayout boundary ≠ `RepaintBoundary`.** A relayout boundary is a render-tree
flag set during [`layout`](https://api.flutter.dev/flutter/rendering/RenderObject/layout.html)
when the parent does not need the child’s size for its own layout
(`!parentUsesSize`), or when constraints are tight / `sizedByParent` / root.
There is no public `RelayoutBoundary` widget. `RepaintBoundary` isolates
**paint** layers. Confusing the two mis-teaches perf work.

Custom `RenderObject` setters should early-return when the value is unchanged,
then call the minimal dirty flag(s). Repo example
(`markdown_render_object.dart`): text/style/padding/direction setters call
`markNeedsLayout()` + `markNeedsPaint()` because those fields affect both
geometry and drawing. Prefer paint-only when size is unchanged (e.g. color).

Debug: [`debugPrintMarkNeedsLayoutStacks`](https://docs.flutter.dev/testing/code-debugging)
/ `debugPrintMarkNeedsPaintStacks`; dump trees show `relayoutBoundary=upN`.
Deeper model: [Inside Flutter — Sublinear layout](https://docs.flutter.dev/resources/inside-flutter).

## Repo examples

| Example | Path |
| --- | --- |
| Whiteboard painter | `apps/mobile/lib/features/example/presentation/widgets/whiteboard/` |
| Markdown render object | `apps/mobile/lib/features/example/presentation/widgets/markdown_editor/` |

## Related

- [`design_system.md`](../design_system.md) — tokens / Mix for surrounding chrome
- [`flutter_layout_constraints.md`](flutter_layout_constraints.md) — constraints/size/position contract for `performLayout`
- [`../performance/performance_bottlenecks.md`](../performance/performance_bottlenecks.md) — frame pipeline + `RepaintBoundary` for paint isolation
- [`bloc_standards.md`](../bloc_standards.md) — state ownership
