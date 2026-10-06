# Low-risk UI polish (Apr 2026 production trends)

**Date:** 2026-10-06  
**Branch:** `cursor/ui-polish-production-trends-cca1`

## Intent

Apply only low-risk presentation polish guided by Mohit Phogat's Apr 2026
production UI trends. No redesign, navigation IA change, AI features, BLoC /
repository contract changes, or CI edits.

## Trend map

| # | Trend | Applied |
| --- | --- | --- |
| 1 | Functional minimalism | Quieter error copy styling (`CommonErrorView` uses body token weight) |
| 2 | Real-time feedback | Shared skeleton effect + reduce-motion solid bones; loading button switch duration respects `disableAnimations` |
| 3 | Invisible UI | Confetti overlay skipped when `MediaQuery.disableAnimations` |
| 4 | AI layer | Skipped |
| 5 | Communicating micro-interactions | `IconButtonTheme` overlay; delete action overlay; floating `SnackBarTheme` (undo already exists) |
| 6 | Design tokens | `AppTheme` list/icon/snackbar/progress themes; error view uses `textTheme` |
| 7 | Dense-but-readable lists | Dense `ListTileTheme`; chat history + todo title/subtitle hierarchy |
| 8 | Light personalization | Skipped — no existing last-filter preference to surface |

## Skipped (higher risk)

- Remember last todo/filter preference (needs prefs/cubit persistence)
- Gesture redesign / new navigation patterns
- Drift/Hive schema or new packages
- Dispersion branch
- Decorative animation systems beyond reduce-motion hooks

## Layers touched

- [x] presentation / theme / design_system widgets
- [ ] domain / data / CI

## Proof

```bash
./bin/format --changed
cd packages/design_system && flutter test test/skeleton_base_test.dart
cd apps/mobile && flutter test test/theme/app_theme_component_themes_test.dart \
  test/shared/widgets/skeletons_test.dart \
  test/shared/widgets/common_error_view_test.dart \
  test/shared/widgets/common_loading_widget_test.dart
```
