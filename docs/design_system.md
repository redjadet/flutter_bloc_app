# Design system

Quick reference for where theme, constants, and shared UI live in the Flutter BLoC app.

Root [`../DESIGN.md`](../DESIGN.md) is the agent-readable visual brief:
tokens plus prose for brand feel, color roles, typography, spacing, component
rules, and do/don't guardrails. Flutter runtime values still live in
`AppTheme`, `buildAppMixScope`, `AppStyles`, and `UI`; when values diverge,
patch runtime source and then update [`DESIGN.md`](../DESIGN.md) to match the verified
decision.

[`DESIGN.md`](../DESIGN.md) follows Google’s @google/design.md **alpha** spec: YAML tokens +
`##` prose sections in canonical order. Keep any extra guidance as `###`
subsections (so the linter doesn’t treat it as a new section).

## Locations

During the Melos migration, shared theme/Mix/widgets also live in `packages/design_system/`.
The app keeps **compatibility barrels** at the paths below so existing imports keep working.

| Area | Path | Purpose |
| ---- | ---- | ------- |
| Visual brief | [`DESIGN.md`](../DESIGN.md) | Agent-readable design memory using Google's DesignMD alpha format. |
| Theme | `lib/core/theme/` | `ThemeData`, light/dark themes, `TextTheme`. Use `AppTheme.lightTheme()` / `AppTheme.darkTheme()`. |
| Design system package | `packages/design_system/` | `package:design_system` — Mix tokens, `AppStyles`, responsive helpers, `CommonCard`, `CommonStatusView`, skeletons. **No** feature or l10n imports. |
| Mix theme | `lib/core/theme/mix_app_theme.dart` | Barrel → `package:design_system`. Mix token names; `buildAppMixScope(context, child: …)`; wrapped in `AppConfig`. |
| Mix styles | `lib/shared/design_system/app_styles.dart` | Barrel → `package:design_system` shared Mix `[Style]` definitions. |
| Constants | `lib/core/constants/` | App-wide `AppConstants`: colors, breakpoints, window sizes, durations. |
| Core extensions | `lib/core/extensions/` | Core-level `BuildContext` (or similar) extensions. |
| Typography | `lib/shared/ui/typography.dart` | `AppTypography` helpers using `Theme.of(context).textTheme`. |
| UI constants | `lib/shared/ui/ui_constants.dart` | Barrel → `package:design_system` layout/spacing tokens (`UI.gapM`, `UI.radiusM`, etc.). |
| Components | `lib/shared/components/` | Design system primitives (buttons, inputs, chips). |
| Widgets | `lib/shared/widgets/` | App-level composite widgets; `common_card.dart` / `common_status_view.dart` barrel shared widgets from `design_system`. |

### Page shell (`CommonPageLayout`)

Default wrapper for feature screens (`lib/shared/widgets/common_page_layout.dart`).

| Need | API |
| ---- | --- |
| Standard titled screen | `title:` (non-empty) + optional `actions`, `appBarBackgroundColor`, `titleTextStyle`, `centerTitle`, etc. |
| Custom app bar (search field, counter menu, themed bar) | `appBar:` — bypasses default `CommonAppBar`; do not also pass title/actions for the default bar |
| Full-bleed body (lists, grids, embedded search) | `useResponsiveBody: false` — page applies its own padding/safe area |
| Themed scaffold surface | `backgroundColor:` (e.g. search uses `colorScheme.surface`) |
| Keyboard-safe padded body | Keep `useResponsiveBody: true` (default) — `_ResponsiveBody` adds safe-area + keyboard inset |

**Migrated examples:** search (`_SearchPageAppBar`), counter (`CounterPageAppBar`), chat list (themed `CommonAppBar` params), calculator (title only).

**Skip:** FirebaseUI auth layouts, demo nav shells. Change log:
[`docs/changes/2026-06-06_common-page-layout-appbar-widening.md`](changes/2026-06-06_common-page-layout-appbar-widening.md).

**Tests:** `test/shared/widgets/common_page_layout_test.dart` (default + custom `appBar`).

## Mix (design tokens and styles)

- **Tokens:** `AppMixTokens`, `AppMaterialColorTokens`, and `AppTextStyleTokens` in `mix_app_theme.dart` define space, radius, color, and text-style token names. Values are filled by `buildAppMixScope(context, child: ...)` from `UI`, `AppConstants`, and Material `Theme` (including `textTheme`).
- **Surface/layout styles:** From `app_styles.dart`: `AppStyles.card`, `profileOutlinedButton`, `listTile`, `inputField`, `inputFieldShell`, `inputOutline`, `appBar`, `chip`, `dialogContent`, `banner`, `emptyState`, `statusSuccess`, `statusError`. Card uses `$on.dark`; listTile, banner, and chip use `$on.medium` for responsive padding. Use with `Box(style: AppStyles.*, child: ...)` or **CommonCard** for card-like wrappers.
- **Button styles:** `AppStyles.filledButton`, `outlinedButton` — use with Mix `Button`/`Pressable` or align custom `ButtonStyle` with these tokens.
- **Status text styles:** `AppStyles.statusSuccessText` and `statusErrorText` pair with the status surfaces.
- **Text styles:** `AppStyles.headingStyle`, `subheadingStyle`, `bodyStyle`, `bodyLargeStyle`, `captionStyle`, `captionSmallStyle` (use `$text.style.ref(AppTextStyleTokens.*)` in Mix). For new text in Mix-aware widgets, prefer these over `AppTypography` where applicable.
- **Examples:** **GraphqlDataSourceBadge**, **SyncDiagnosticsSection** chips use `AppStyles.chip`; **CommonCard** in settings, **SettingsCard**, **CalculatorSummaryCard**, **WebsocketConnectionBanner**; **SearchAppBar** uses `AppStyles.appBar`; **TodoSearchField** uses `AppStyles.inputField`; **CommonStatusView** uses `AppStyles.emptyState` when padding is null; **PlatformAdaptiveSheets.showPickerModal** and **register_country_picker** sheet use `AppStyles.dialogContent`.
- **Tests:** Widget tests that need Mix theme use `pumpWithMixTheme(tester, child: ...)` from `test/helpers/pump_with_mix_theme.dart`.
- **Relation to Theme:** Flutter `Theme` / `ThemeData` remain the source for Material widgets and `Theme.of(context)`. Mix runs alongside: `MixScope` provides tokens; styles reference them. Legacy `AppTypography` and `UI` remain valid during migration. When touching a screen, see [Mix Design System Plan](mix_design_system_plan.md) “Ongoing and next steps” for a checklist.

## Reusable widgets (preview, test, design iteration)

Agents should **extract and ship leaf widgets** so the same surface is easy to
preview in the IDE, pump in widget tests, and tweak during design iteration
without rewiring whole pages.

### Contract

| Rule | Why |
| --- | --- |
| **Constructor-driven UI** — all visible variation via constructor params (data, flags, callbacks) | Same widget in page, test, and `@Preview` without DI |
| **No hidden deps in leaf widgets** — no `context.read`, `get_it`, or cubit lookup inside reusable widgets | Isolated pump/preview; page wires cubit → props |
| **Callbacks out** — `VoidCallback` / typed handlers instead of navigation or repo calls inside the widget | Tests assert taps; pages own side effects |
| **Design tokens** — `AppStyles`, `UI`, `Theme.of(context)`, responsive helpers; no magic numbers | Hot reload + iteration stay on-brand |
| **`ValueKey` on tappable controls** | Stable widget tests ([widget test playbook](testing/widget_test_playbook.md)) |
| **One visual concern per file** when practical — target ≤ ~225 LOC per widget file ([`CODE_QUALITY.md`](CODE_QUALITY.md)) | Smaller diffs, faster preview reload |
| **Placement** — feature `presentation/widgets/` first; `lib/shared/widgets/` only after a second real consumer ([feature structure contract](architecture/feature_structure_contract.md)) | Avoid premature shared abstractions |

Pages and route shells **compose** widgets; they are not the only place layout
lives. When a screen section has distinct states (loading / empty / error /
success), extract a widget per meaningful layout branch.

### Widget Preview (Flutter `@Preview`)

Stack: Flutter **3.44+** supports [`@Preview`](https://api.flutter.dev/flutter/widget_previews/Preview-class.html)
via `package:flutter/widget_previews.dart`.

For non-trivial new or changed widgets:

1. Add a **top-level preview function** (or static preview target) next to the
   widget — co-located `*_preview.dart` under `presentation/widgets/` is fine.
2. Pump the **same constructor** you use in widget tests with **fixture data**
   (sample domain/view models, no live cubit).
3. Add **multiple `@Preview` annotations** when branches differ materially
   (empty vs populated, error banner, wide vs narrow if layout-sensitive).
4. Wrap with the same shell tests use when needed: `MaterialApp` + l10n
   delegates; `pumpWithMixTheme` / `buildAppMixScope` for Mix-aware widgets.
5. Preview targets must not require `dart:io`, native plugins, or uninitialized
   DI — use fakes or omit IO in the preview path.

Run: IDE **Flutter Widget Preview** tab, or `flutter widget-preview start`.
After UI edits, hot reload the preview before claiming visual proof.

### Widget tests

Mirror previews: pump the **widget under test** directly with fixture props.
Reference: [`test/features/playlearn/presentation/widgets/word_card_test.dart`](../test/features/playlearn/presentation/widgets/word_card_test.dart).

- File mirror: `test/features/<feature>/presentation/widgets/<widget>_test.dart`
- Prefer component tests for layout/interaction; reserve full-page tests for
  navigation and cubit wiring ([`testing/widget_test_playbook.md`](testing/widget_test_playbook.md)).
- Share fixture constants between preview and test when both exist in the same
  feature (private top-level or small `*_fixtures.dart` in `test/`).

### Design iteration

- Change **tokens or leaf widgets** first; keep pages as thin composition.
- Reuse shared rows/bars from [Horizontal action layout](#horizontal-action-layout-overflow) instead of one-off `Row`s.
- Prove responsive / no-overlap states at the widget or page level per
  [`DESIGN.md`](../DESIGN.md) and [`ui_ux_responsive_review.md`](ui_ux_responsive_review.md).

## Responsive layout (avoid fixed sizes)

Agents must **design responsive UIs** — layout adapts to width, height, text
scale, keyboard, and safe areas. Do not pin full sections to fixed pixel
width/height when constraints can change.

### Prefer first (repo helpers)

| Need | Use |
| --- | --- |
| Spacing, padding, gaps | `context.responsiveGap*`, `context.pagePadding`, `UI.gap*` |
| Typography scale | `context.responsiveHeadlineSize` / `TitleSize` / `BodySize`, theme `textTheme` |
| Breakpoints (mobile / tablet / desktop) | `context.responsiveValue`, `context.isTabletOrLarger`, `ResponsiveFramework` via [`responsive.dart`](../lib/shared/extensions/responsive.dart) |
| Max content width | `context.contentMaxWidth`, `CommonPageLayout` + `useResponsiveBody` |
| Dual CTAs / action rows | [`ResponsiveDualCtaRow`](../lib/shared/widgets/responsive_action_bar.dart), [`ResponsiveActionOverflowBar`](../lib/shared/widgets/responsive_action_bar.dart) |
| Platform chrome | `PlatformAdaptive.*`, `SafeArea`, keyboard via `MediaQuery.viewInsetsOf(context)` |

Full review checklist: [`ui_ux_responsive_review.md`](ui_ux_responsive_review.md).

### When to use `LayoutBuilder`

Use when **branching or sizing depends on the parent’s max constraints** (not
the whole screen):

- Compact vs wide **within** a card, column, dialog, or split pane
- Scale a child down when `constraints.maxWidth` is tight
- Grid column count or aspect ratio from available width

Examples: [`word_card.dart`](../lib/features/playlearn/presentation/widgets/word_card.dart),
[`calculator_keypad.dart`](../lib/features/calculator/presentation/widgets/calculator_keypad.dart),
[`common_page_layout.dart`](../lib/shared/widgets/common_page_layout.dart).

Pattern:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final maxW = constraints.maxWidth;
    if (maxW < breakpoint) { /* stack / scroll */ }
    return /* row / grid */;
  },
)
```

### When to use `MediaQuery`

Use when behavior depends on **viewport / system**, not only the immediate parent:

| Signal | API |
| --- | --- |
| Screen size / orientation | `MediaQuery.sizeOf(context)`, `orientation` |
| Keyboard overlap | `MediaQuery.viewInsetsOf(context).bottom` |
| Text scale (a11y) | `MediaQuery.textScalerOf(context)` |
| Safe areas | `MediaQuery.paddingOf(context)` or `context.bottomInset` |
| Breakpoint when parent is narrower than screen | `MediaQuery.sizeOf(context).width` (see [`ResponsiveDualCtaRow`](../lib/shared/widgets/responsive_action_bar.dart)) |

Do not read `MediaQuery` for layout that only needs **local** constraints — use
`LayoutBuilder` instead (cheaper, correct in nested scrollables).

### Avoid

- Fixed `width` / `height` on **page shells**, lists, or text blocks that should
  reflow (use `Expanded`, `Flexible`, `Wrap`, scroll views).
- Hard-coded font sizes / line heights without theme or responsive helpers.
- `Positioned` layouts without scroll/reflow fallback on small height or large
  text scale.
- One-off magic numbers — map to `UI` / `AppStyles` / responsive extensions.

### Allowed fixed sizes

- Icon/asset sizes tied to design tokens (e.g. `context.responsiveIconSize`).
- Minimum tap targets (44–48 logical px) via padding, not clipping content.
- Borders, dividers, and single-line controls where the spec is intentionally fixed.

### Proof

- Widget tests at compact width when layout branches (see
  [`widget_test_playbook.md`](testing/widget_test_playbook.md) § Layout-sensitive screens).
- Manual: narrow phone width, tablet/desktop, text scale ≥ 1.3, keyboard open.

## Cross-platform form factors (mobile, tablet, web, desktop)

Shared widgets and pages must behave correctly on **all four** first-class
targets ([`tech_stack.md`](tech_stack.md) § Supported platforms). Do not ship
layout or interaction that only works on the device under debug.

### Form-factor matrix

| Form factor | Width (repo breakpoints) | Agent checks |
| --- | --- | --- |
| **Mobile** | &lt; 800 logical px (`AppConstants.mobileBreakpoint`) | Touch targets; safe area; keyboard overlap; portrait/landscape reflow; no clipped primary actions |
| **Tablet** | 800–1199 px | Use `context.isTabletOrLarger` / `responsiveValue`; multi-column or side-by-side where width allows; avoid phone-only stacks on wide tablet |
| **Web** | Any viewport in browser | Web-safe imports (`kIsWeb`); URL/deep-link routes; pointer hover/focus; scroll without mobile-only assumptions; run web preflight when bootstrap/routing touched |
| **Desktop (macOS)** | Often ≥ 1200 px; also **narrow windows** | Keyboard traversal and focus rings; mouse affordances; resizable window — prove compact width, not only full screen |

Breakpoints: [`responsive_config.dart`](../lib/shared/responsive/responsive_config.dart)
(mobile &lt; 800, tablet 800–1199, desktop ≥ 1200).

### One widget tree, adaptive behavior

- **Prefer** a single shared widget tree with responsive breakpoints and
  `PlatformAdaptive` — not forked `if (iOS)` / `if (web)` page copies unless
  platform policy requires it.
- **Mobile + tablet:** width-driven layout via `context.responsive*`,
  `LayoutBuilder`, `CommonPageLayout` (`useResponsiveBody`), grid column helpers.
- **Web + desktop:** same components; add input-model checks (focus, hover,
  keyboard shortcuts only when product requires them).
- **Never** put `dart:io` or unguarded `Platform.is*` in presentation; isolate
  IO in data/shared adapters (`RISK-PLATFORM-SCOPE`).

Skill: `flutter-cross-platform-modern`. Pitfall table: `agents-common-pitfalls`.

### Proof (widgets)

| Change type | Minimum proof |
| --- | --- |
| Layout-sensitive widget | Widget test at **compact mobile width** + at least one **wide** width (tablet/desktop); text scale ≥ 1.3 when text-heavy |
| Shared page / shell | No overlap at mobile, tablet, and desktop breakpoints; [`ui_ux_responsive_review.md`](ui_ux_responsive_review.md) |
| Routing / auth / deep links | `./bin/router_feature_validate` or web integration preflight when applicable |
| Platform plugin / IO | Adapter + `check_sync_io_in_presentation.sh`; document if a target is intentionally deferred |

## Rules

- Read root [`DESIGN.md`](../DESIGN.md) before adding new shared visual roles or UI patterns.
- Define fonts and theme in `lib/core/theme/`; wire in `AppConfig`.
- Use `Theme.of(context).colorScheme` and theme-derived text styles; avoid hardcoded colors and per-widget `GoogleFonts.*`.
- For new styling, prefer Mix `Style` and tokens from `app_styles.dart` / `mix_app_theme.dart` where practical.
- Use `context.responsiveHeadlineSize` / `TitleSize` / `BodySize` and `PlatformAdaptive.*` for UI.
- Design responsive layouts; avoid fixed sizes for reflowable content — [`ui_ux_responsive_review.md`](ui_ux_responsive_review.md) and design_system § Responsive layout.
- Cross-platform widgets: mobile, tablet, web, desktop — design_system § Cross-platform form factors; `flutter-cross-platform-modern`.
- Build actual workflow/demo first; avoid landing/marketing screens unless asked.
- Match app density: quiet controls, scannable state, predictable nav, complete states.
- Keep cards un-nested and controls stable; dynamic text/icons/badges/counters must not resize, overlap, or hide primary content.
- Validate the visual brief with `./tool/check_design_md.sh` after editing
  root [`DESIGN.md`](../DESIGN.md). This wrapper is intentionally not part of default
  checklist until the CLI is pinned locally.

### Horizontal action layout (overflow)

| Pattern | Widget | When |
| ------- | ------ | ---- |
| Icon + label in a row | [`IconLabelRow`](../lib/shared/widgets/icon_label_row.dart) | Any `Row` with `Icon` + `Text` (enforced by `tool/check_row_text_overflow.sh`) |
| 2+ intrinsic-width actions | `ResponsiveActionOverflowBar` (wraps `OverflowBar`, spacing 12) | Clear/Save, Cancel/Confirm; Cupertino picker sheets |
| Many chips / batch tools | `Wrap` with spacing | Todo batch bar, filter chips |
| Equal dual CTA (Sign in / Register, Cancel/Confirm) | `ResponsiveDualCtaRow` (`Row`+`Expanded` wide; column below 360dp screen width) | Auth landing, booking confirm |
| Dialog actions | `AlertDialog.actions` + `PlatformAdaptive.dialogAction` | Framework handles overflow |

Static guard: `tool/check_row_action_overflow.sh` (PRIMARY_SCOPE by default). Widget regressions: `tool/check_action_bar_layout.sh`.

### DESIGN.md CLI workflow

- Package: @google/design.md
- Lint command: npx @google/design.md lint DESIGN.md
- Diff command: npx @google/design.md diff DESIGN.md DESIGN.before.md

- Lint (wrapped by `./tool/check_design_md.sh`): npx @google/design.md lint DESIGN.md
- Diff (useful in reviews): npx @google/design.md diff DESIGN.md DESIGN.before.md
- Prefer barrel imports for consistency:
  - `package:flutter_bloc_app/core/constants/constants.dart`
  - `package:flutter_bloc_app/core/theme/theme.dart`
  - `package:flutter_bloc_app/shared/components/components.dart`

## Related docs

- [Mix Design System Plan](mix_design_system_plan.md) — full implementation plan (tokens, styles, pilot, migration, risks).
- [Architecture Details](architecture_details.md#design-system)
- [UI/UX Responsive Review](ui_ux_responsive_review.md)
