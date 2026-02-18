# Design system

Quick reference for where theme, constants, and shared UI live in the Flutter BLoC app.

## Locations

| Area | Path | Purpose |
| ---- | ---- | ------- |
| Theme | `lib/core/theme/` | `ThemeData`, light/dark themes, `TextTheme`. Use `AppTheme.lightTheme()` / `AppTheme.darkTheme()`. |
| Constants | `lib/core/constants/` | App-wide `AppConstants`: colors, breakpoints, window sizes, durations. |
| Core extensions | `lib/core/extensions/` | Core-level `BuildContext` (or similar) extensions. |
| Typography | `lib/shared/ui/typography.dart` | `AppTypography` helpers using `Theme.of(context).textTheme`. |
| UI constants | `lib/shared/ui/ui_constants.dart` | Layout/spacing tokens (`UI.gapM`, `UI.radiusM`, etc.). |
| Components | `lib/shared/components/` | Design system primitives (buttons, inputs, chips). |
| Widgets | `lib/shared/widgets/` | App-level composite widgets (e.g. `CommonPageLayout`, `CommonStatusView`). |

## Rules

- Define fonts and theme in `lib/core/theme/`; wire in `AppConfig`.
- Use `Theme.of(context).colorScheme` and theme-derived text styles; avoid hardcoded colors and per-widget `GoogleFonts.*`.
- Use `context.responsiveHeadlineSize` / `TitleSize` / `BodySize` and `PlatformAdaptive.*` for UI.
- Prefer barrel imports for consistency:
  - `package:flutter_bloc_app/core/constants/constants.dart`
  - `package:flutter_bloc_app/core/theme/theme.dart`
  - `package:flutter_bloc_app/shared/components/components.dart`

## Related docs

- [Architecture Details](architecture_details.md#design-system)
- [UI/UX Responsive Review](ui_ux_responsive_review.md)
