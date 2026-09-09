# Flutter layout constraints (repo contract)

Canonical layout mental model for this app. Prefer this doc over ad-hoc
overflow fixes. Upstream source:
[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints).

## The contract

> **Constraints go down. Sizes go up. Parents set positions.**

Flutter enforces a one-pass parent/child negotiation:

1. **Constraints go down** — parent tells child min/max width and height
   (`BoxConstraints`). Child may only choose a size **inside** those bounds.
2. **Sizes go up** — child returns a concrete `Size`. Parent cannot force a
   size the child never reported (except via widgets that ignore child
   preference, such as `Expanded`).
3. **Parents set positions** — child does **not** choose where it sits on
   screen; parent places each child after sizes are known.

That is why errors like `RenderFlex overflowed by 42 pixels`,
`Vertical viewport was given unbounded height`, and
`RenderBox was not laid out` feel opaque until the contract is clear: Flutter
is rejecting an illegal negotiation, not a random UI glitch.

## Tight vs loose (quick)

| Kind | Meaning | Typical source |
| --- | --- | --- |
| **Tight** | `min == max` on an axis — exact size | Screen / `SizedBox.expand` / many root boxes |
| **Loose** | `min == 0`, finite `max` — “up to this size” | `Center`, `Align`, padded regions |
| **Unbounded** | `max == infinity` on an axis | Main axis of `Row`/`Column` for non-flex children; scrollables’ cross-axis peers |

Unbounded max + a child that wants to be “as big as possible”
(`ListView`, default `Container`) → layout exception.

## Error → diagnosis map

Ignore cascading **`RenderBox was not laid out`**; find the first real
constraint failure higher in the stack.

| Symptom | What broke in the contract | Repo fix |
| --- | --- | --- |
| `RenderFlex overflowed by N pixels` | Child size > constraints parent passed along flex main axis | Bound the child: `Flexible` / `Expanded` + ellipsis, `Wrap`, `OverflowBar`, or shared row helpers |
| `Vertical viewport was given unbounded height` | Scrollable wants infinite height; parent (`Column`) passed unbounded max height | Give finite height: `Expanded` / `SizedBox` / sliver in `CustomScrollView` — avoid `shrinkWrap: true` for long lists |
| `InputDecorator … unbounded width` | `TextField` inside unbounded horizontal parent (`Row`) | Wrap field in `Expanded` / `Flexible` |
| `BoxConstraints forces an infinite width/height` | Child asked for infinity under unbounded constraints | Replace with bounded box (`LimitedBox`, `ConstrainedBox`, flex, fixed size) |
| `Incorrect use of ParentDataWidget` | `Expanded`/`Flexible`/`Positioned` under wrong parent | Move under `Row`/`Column`/`Flex` or `Stack` |

## Box behavior classes (official)

Most single-child boxes fall into one of:

- **As big as possible** — `Center`, `ListView` viewport, default empty `Container`
- **As big as child** — `Transform`, `Opacity`, many wrappers
- **Particular size** — `Text`, `Image`, explicit `width`/`height`

`Row` / `Column` act like `UnconstrainedBox` along the main axis for
non-flex children: they **do not** shrink text/buttons unless you wrap with
`Flexible` / `Expanded`. That is why icon+label and multi-button rows overflow
on narrow widths.

## Repo patterns (use these)

| Need | Prefer | Why (contract) |
| --- | --- | --- |
| Feature page shell | `CommonPageLayout` | Scaffold gives tight-ish body bounds; `_ResponsiveBody` passes **local** max width down via `ConstrainedBox` |
| Parent-local branch | `LayoutBuilder` | Read **incoming** constraints (down), not only screen `MediaQuery` |
| Icon + label | `IconLabelRow` | Passes remaining width into `Flexible` text so size can go up within bounds |
| 2+ intrinsic actions | `ResponsiveActionOverflowBar` | Lets parent width constrain; wraps instead of overflowing |
| Equal dual CTAs | `ResponsiveDualCtaRow` | Wide: `Expanded` forces equal widths; narrow: column stretch |
| Long lists | `ListView.builder` / slivers | Viewport gets bounded extent from parent; avoid nested `shrinkWrap` |

Guards: `tool/check_row_text_overflow.sh`, `tool/check_row_action_overflow.sh`,
`tool/check_flutter_layout_overflows.sh`, `tool/check_perf_shrinkwrap_lists.sh`.

## Agent checklist

1. Name the axis that failed (width vs height) and whether max was finite.
2. Trace **constraints down** one parent at a time (`Column` → child,
   `Row` → child, scrollable → viewport).
3. Prefer bounding with flex/scroll over hard-coded page heights.
4. Prove with a **compact-width** widget test when the fix is overflow-related
   ([`widget_test_playbook.md`](../testing/widget_test_playbook.md) §
   Layout-sensitive screens). Capture helpers:
   `apps/mobile/test/helpers/layout_overflow_expectations.dart`.
   Nested parent narrower than `contentMaxWidth`:
   `apps/mobile/test/shared/widgets/common_page_layout_test.dart`
   (`responsive body caps maxWidth…`).

## Related

- [`../design_system.md`](../design_system.md) — responsive layout + horizontal action overflow
- [`../review/ui_ux_responsive_review.md`](../review/ui_ux_responsive_review.md) — review chooser
- [`../performance/performance_bottlenecks.md`](../performance/performance_bottlenecks.md) — layout stage + lists
- [`../validation_scripts/guides_state_layout.md`](../validation_scripts/guides_state_layout.md) — static overflow guards
- [`custom_painter_and_render_object.md`](custom_painter_and_render_object.md) — custom layout/paint
- Official: [Understanding constraints](https://docs.flutter.dev/ui/layout/constraints),
  [Layout](https://docs.flutter.dev/ui/layout)
