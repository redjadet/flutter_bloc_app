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

- **Tokens:** `AppMixTokens` and `AppMaterialColorTokens` in `mix_app_theme.dart` define space, radius, and color token names. Values are filled by `buildAppMixThemeData(context)` from `UI`, `AppConstants`, and Material `Theme`.
- **Styles:** Use `AppStyles.card`, `AppStyles.profileOutlinedButton`, etc. from `app_styles.dart` in widgets (e.g. `Box(style: AppStyles.card, child: ...)`). Prefer tokens and these styles for new UI so styling stays consistent.
- **Relation to Theme:** Flutter `Theme` / `ThemeData` remain the source for Material widgets and `Theme.of(context)`. Mix runs alongside: `MixTheme` provides tokens; styles reference them. Legacy `AppTypography` and `UI` remain valid during migration.

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
