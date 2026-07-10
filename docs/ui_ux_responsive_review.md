# UI/UX Responsive and Adaptive Review

Review contract for shared Flutter UI. Runtime APIs and examples live in
[`design_system.md`](design_system.md); visual intent lives in root
[`DESIGN.md`](../DESIGN.md).

## Agent rules (responsive layout)

- Support mobile, tablet, web, and desktop/macOS for shared UI.
- Prefer one responsive widget tree; branch only when interaction policy differs.
- Use design tokens, theme, l10n, and `PlatformAdaptive` components.
- Keep widgets presentational; Cubit/state supplies derived view data.
- Use leaf widgets with constructor data + callbacks for preview and tests.
- Avoid fixed page/section sizes when content can reflow.
- Preserve keyboard, pointer, focus, screen-reader, and text-scale usability.

## Layout chooser

| Need | Preferred tool |
| --- | --- |
| App/page width and standard padding | `CommonPageLayout`, responsive context helpers |
| Parent-local width branch | `LayoutBuilder` |
| Viewport, keyboard, text scale, safe area | targeted `MediaQuery.*Of(context)` API |
| Rows that may overflow | `Wrap`, `ResponsiveDualCtaRow`, `ResponsiveActionOverflowBar` |
| Flexible text beside controls | `Expanded` / `Flexible` |
| Bounded readable desktop content | `ConstrainedBox` / repo content-width helper |
| Platform chrome | `PlatformAdaptive.*` |

Fixed sizes remain valid for icons, borders, tokenized controls, and minimum tap
targets. Fixed heights remain invalid for dynamic text, full forms, lists, and
content sections without scroll/reflow fallback.

## Agent rules (cross-platform form factors)

Apply same widget contract across supported targets; adapt layout and input
behavior through repo helpers instead of platform-specific page copies.

## Form-factor matrix

| Target | Required checks |
| --- | --- |
| Mobile | Safe areas, keyboard overlap, touch targets, portrait/landscape, compact width |
| Tablet | Wide layout, split/multi-column opportunity, no stretched phone-only stack |
| Web | Web-safe imports, URL/deep-link behavior, pointer/focus, narrow browser width |
| Desktop/macOS | Resizable window, keyboard traversal, hover/focus, compact and wide widths |

Repo breakpoints: mobile `<800`, tablet `800–1199`, desktop `>=1200`; source:
[`responsive_config.dart`](../packages/design_system/lib/src/responsive/responsive_config.dart).

## Component review

For each changed screen/widget verify:

- primary action visible at compact width and large text scale
- no clipped/overlapping text, badges, icons, or controls
- loading, empty, error, success, disabled, and offline states where applicable
- tap targets at least 44–48 logical pixels
- semantic labels for icon-only controls
- visible keyboard focus and logical traversal
- color not sole carrier of meaning
- contrast and theme behavior in light/dark mode
- scroll ownership clear; no unbounded nested scrollables
- stable keys/identity for dynamic rows
- no raw platform-only import on shared/web path

## Reusable-widget contract

- Feature widget starts in `presentation/widgets/`.
- Generic second-use component moves to `packages/design_system`.
- App-flow composite stays in `apps/mobile/lib/app/widgets/`.
- Leaf widget accepts display-ready data and typed callbacks.
- Page owns Cubit lookup, navigation, dialogs, and repository-triggering intent.
- Non-trivial widget gets direct widget test; add `@Preview` when useful.

Owner: [`architecture/feature_structure_contract.md`](architecture/feature_structure_contract.md)
and [`design_system.md`](design_system.md) § Reusable widgets.

## Accessibility checks

- Test text scale at least 1.3; use 2.0 for sensitive layouts.
- Verify semantics labels, button roles, and reading order.
- Confirm keyboard-only operation on web/desktop.
- Avoid hard-coded line heights that clip scaled text.
- Respect reduced-motion/platform accessibility settings where animation exists.
- Ensure errors are announced and remain understandable without color.

## Proof matrix

| Change | Minimum proof |
| --- | --- |
| Token/theme only | Targeted theme/widget tests + `./tool/check_design_md.sh` when [`DESIGN.md`](../DESIGN.md) changes |
| Leaf widget | Direct widget test at compact width; interaction assertion |
| Responsive branch | Compact + wide widget tests; text-scale case |
| Shared/app page | Mobile + wide host proof; loading/error/empty states |
| Router/bootstrap web UI | `./bin/integration_preflight` with Chrome lane |
| Platform plugin UI | Supported-platform smoke; web guard when shared |

Useful commands:

```bash
./tool/check_design_md.sh
./tool/run_mix_lint.sh
./tool/run_file_length_lint.sh
bash tool/check_flutter_layout_overflows.sh
./bin/router_feature_validate       # routes/auth gates
./bin/integration_preflight         # bootstrap/browser seams
```

Then run focused Flutter tests and route final proof through
[`engineering/validation_routing_fast_vs_full.md`](engineering/validation_routing_fast_vs_full.md).
Hot reload active debug/preview session after UI edits; report when unavailable.

## Review stop conditions

Do not approve when any applies:

- compact-width overflow or hidden primary action
- keyboard blocks required field/action
- layout supports only debug device width
- widget contains business/data/navigation policy
- raw colors, strings, platform APIs, or network images bypass repo abstractions
- required state branch lacks executable proof
- shared UI lacks web/desktop-safe behavior

## Related owners

- [`DESIGN.md`](../DESIGN.md) — visual brief
- [`design_system.md`](design_system.md) — runtime tokens/components/responsive APIs
- [`testing/widget_test_playbook.md`](testing/widget_test_playbook.md) — widget proof patterns
- [`review/performance_checklist.md`](review/performance_checklist.md) — rebuild/layout performance
- [`tech_stack.md`](tech_stack.md) — supported platforms
