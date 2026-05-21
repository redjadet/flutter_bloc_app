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

| Area | Path | Purpose |
| ---- | ---- | ------- |
| Visual brief | [`DESIGN.md`](../DESIGN.md) | Agent-readable design memory using Google's DesignMD alpha format. |
| Theme | `lib/core/theme/` | `ThemeData`, light/dark themes, `TextTheme`. Use `AppTheme.lightTheme()` / `AppTheme.darkTheme()`. |
| Mix theme | `lib/core/theme/mix_app_theme.dart` | Mix token names and runtime values. Use `buildAppMixScope(context, child: ...)`; app is wrapped with `MixScope` in `AppConfig`. |
| Mix styles | `lib/shared/design_system/app_styles.dart` | Shared [Style] definitions (card, profileOutlinedButton, etc.) using Mix tokens. |
| Constants | `lib/core/constants/` | App-wide `AppConstants`: colors, breakpoints, window sizes, durations. |
| Core extensions | `lib/core/extensions/` | Core-level `BuildContext` (or similar) extensions. |
| Typography | `lib/shared/ui/typography.dart` | `AppTypography` helpers using `Theme.of(context).textTheme`. |
| UI constants | `lib/shared/ui/ui_constants.dart` | Layout/spacing tokens (`UI.gapM`, `UI.radiusM`, etc.). |
| Components | `lib/shared/components/` | Design system primitives (buttons, inputs, chips). |
| Widgets | `lib/shared/widgets/` | App-level composite widgets (e.g. `CommonPageLayout`, `CommonStatusView`). |

## Mix (design tokens and styles)

- **Tokens:** `AppMixTokens`, `AppMaterialColorTokens`, and `AppTextStyleTokens` in `mix_app_theme.dart` define space, radius, color, and text-style token names. Values are filled by `buildAppMixScope(context, child: ...)` from `UI`, `AppConstants`, and Material `Theme` (including `textTheme`).
- **Surface/layout styles:** From `app_styles.dart`: `AppStyles.card`, `profileOutlinedButton`, `listTile`, `inputField`, `inputFieldShell`, `inputOutline`, `appBar`, `chip`, `dialogContent`, `banner`, `emptyState`, `statusSuccess`, `statusError`. Card uses `$on.dark`; listTile, banner, and chip use `$on.medium` for responsive padding. Use with `Box(style: AppStyles.*, child: ...)` or **CommonCard** for card-like wrappers.
- **Button styles:** `AppStyles.filledButton`, `outlinedButton` — use with Mix `Button`/`Pressable` or align custom `ButtonStyle` with these tokens.
- **Status text styles:** `AppStyles.statusSuccessText` and `statusErrorText` pair with the status surfaces.
- **Text styles:** `AppStyles.headingStyle`, `subheadingStyle`, `bodyStyle`, `bodyLargeStyle`, `captionStyle`, `captionSmallStyle` (use `$text.style.ref(AppTextStyleTokens.*)` in Mix). For new text in Mix-aware widgets, prefer these over `AppTypography` where applicable.
- **Examples:** **GraphqlDataSourceBadge**, **SyncDiagnosticsSection** chips use `AppStyles.chip`; **CommonCard** in settings, **SettingsCard**, **CalculatorSummaryCard**, **WebsocketConnectionBanner**; **SearchAppBar** uses `AppStyles.appBar`; **TodoSearchField** uses `AppStyles.inputField`; **CommonStatusView** uses `AppStyles.emptyState` when padding is null; **PlatformAdaptiveSheets.showPickerModal** and **register_country_picker** sheet use `AppStyles.dialogContent`.
- **Tests:** Widget tests that need Mix theme use `pumpWithMixTheme(tester, child: ...)` from `test/helpers/pump_with_mix_theme.dart`.
- **Relation to Theme:** Flutter `Theme` / `ThemeData` remain the source for Material widgets and `Theme.of(context)`. Mix runs alongside: `MixScope` provides tokens; styles reference them. Legacy `AppTypography` and `UI` remain valid during migration. When touching a screen, see [Mix Design System Plan](mix_design_system_plan.md) “Ongoing and next steps” for a checklist.

## Rules

- Read root [`DESIGN.md`](../DESIGN.md) before adding new shared visual roles or UI patterns.
- Define fonts and theme in `lib/core/theme/`; wire in `AppConfig`.
- Use `Theme.of(context).colorScheme` and theme-derived text styles; avoid hardcoded colors and per-widget `GoogleFonts.*`.
- For new styling, prefer Mix `Style` and tokens from `app_styles.dart` / `mix_app_theme.dart` where practical.
- Use `context.responsiveHeadlineSize` / `TitleSize` / `BodySize` and `PlatformAdaptive.*` for UI.
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
