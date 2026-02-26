# Design system

Quick reference for where theme, constants, and shared UI live in the Flutter BLoC app.

## Locations

| Area | Path | Purpose |
| ---- | ---- | ------- |
| Theme | `lib/core/theme/` | `ThemeData`, light/dark themes, `TextTheme`. Use `AppTheme.lightTheme()` / `AppTheme.darkTheme()`. |
| Mix theme | `lib/core/theme/mix_app_theme.dart` | `MixThemeData` and app tokens. Use `buildAppMixThemeData(context)`; app is wrapped with `MixTheme` in `AppConfig`. |
| Mix styles | `lib/shared/design_system/app_styles.dart` | Shared [Style] definitions (card, profileOutlinedButton, etc.) using Mix tokens. |
| Constants | `lib/core/constants/` | App-wide `AppConstants`: colors, breakpoints, window sizes, durations. |
| Core extensions | `lib/core/extensions/` | Core-level `BuildContext` (or similar) extensions. |
| Typography | `lib/shared/ui/typography.dart` | `AppTypography` helpers using `Theme.of(context).textTheme`. |
| UI constants | `lib/shared/ui/ui_constants.dart` | Layout/spacing tokens (`UI.gapM`, `UI.radiusM`, etc.). |
| Components | `lib/shared/components/` | Design system primitives (buttons, inputs, chips). |
| Widgets | `lib/shared/widgets/` | App-level composite widgets (e.g. `CommonPageLayout`, `CommonStatusView`). |

## Mix (design tokens and styles)

- **Tokens:** `AppMixTokens`, `AppMaterialColorTokens`, and `AppTextStyleTokens` in `mix_app_theme.dart` define space, radius, color, and text-style token names. Values are filled by `buildAppMixThemeData(context)` from `UI`, `AppConstants`, and Material `Theme` (including `textTheme`).
- **Surface/layout styles:** From `app_styles.dart`: `AppStyles.card`, `profileOutlinedButton`, `listTile`, `inputField`, `inputFieldShell`, `appBar`, `chip`, `dialogContent`, `banner`, `emptyState`. Card uses `$on.dark`; listTile, banner, and chip use `$on.medium` for responsive padding. Use with `Box(style: AppStyles.*, child: ...)` or **CommonCard** for card-like wrappers.
- **Button styles:** `AppStyles.filledButton`, `outlinedButton` — use with Mix `Button`/`Pressable` or align custom `ButtonStyle` with these tokens.
- **Text styles:** `AppStyles.headingStyle`, `subheadingStyle`, `bodyStyle`, `bodyLargeStyle`, `captionStyle`, `captionSmallStyle` (use `$text.style.ref(AppTextStyleTokens.*)` in Mix). For new text in Mix-aware widgets, prefer these over `AppTypography` where applicable.
- **Examples:** **GraphqlDataSourceBadge**, **SyncDiagnosticsSection** chips use `AppStyles.chip`; **CommonCard** in settings, **SettingsCard**, **CalculatorSummaryCard**, **WebsocketConnectionBanner**; **SearchAppBar** uses `AppStyles.appBar`; **TodoSearchField** uses `AppStyles.inputField`; **CommonStatusView** uses `AppStyles.emptyState` when padding is null; **PlatformAdaptiveSheets.showPickerModal** and **register_country_picker** sheet use `AppStyles.dialogContent`.
- **Tests:** Widget tests that need Mix theme use `pumpWithMixTheme(tester, child: ...)` from `test/helpers/pump_with_mix_theme.dart`.
- **Relation to Theme:** Flutter `Theme` / `ThemeData` remain the source for Material widgets and `Theme.of(context)`. Mix runs alongside: `MixTheme` provides tokens; styles reference them. Legacy `AppTypography` and `UI` remain valid during migration. When touching a screen, see [Mix Design System Plan](mix_design_system_plan.md) “Ongoing and next steps” for a checklist.

## Rules

- Define fonts and theme in `lib/core/theme/`; wire in `AppConfig`.
- Use `Theme.of(context).colorScheme` and theme-derived text styles; avoid hardcoded colors and per-widget `GoogleFonts.*`.
- For new styling, prefer Mix `Style` and tokens from `app_styles.dart` / `mix_app_theme.dart` where practical.
- Use `context.responsiveHeadlineSize` / `TitleSize` / `BodySize` and `PlatformAdaptive.*` for UI.
- Prefer barrel imports for consistency:
  - `package:flutter_bloc_app/core/constants/constants.dart`
  - `package:flutter_bloc_app/core/theme/theme.dart`
  - `package:flutter_bloc_app/shared/components/components.dart`

## Related docs

- [Mix Design System Plan](mix_design_system_plan.md) — full implementation plan (tokens, styles, pilot, migration, risks).
- [Architecture Details](architecture_details.md#design-system)
- [UI/UX Responsive Review](ui_ux_responsive_review.md)
