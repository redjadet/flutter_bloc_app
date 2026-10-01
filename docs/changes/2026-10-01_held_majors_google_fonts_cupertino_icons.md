# Held majors: google_fonts 9 + cupertino_icons 2

## Why

User-approved dedicated migration after Phase A checklist/IT green.
Renovate had held `google_fonts` `<9` and `cupertino_icons` `<2`.

## What landed

- `apps/mobile/pubspec.yaml`: `google_fonts ^9.0.0`, `cupertino_icons ^2.0.0`
- `app_theme.dart`: use `material_ui` `TextTheme`/`ThemeData` with `GoogleFonts.*` (v9 API)
- `renovate.json`: drop those holds; keep `cross_file <0.4` (image_picker_platform_interface 2.11.1 still needs `cross_file ^0.3.1+1`)
- `docs/tech_stack.md`: typography pin → `^9.0.0`

## Not migrated

- `cross_file ^0.4.0` — blocked by current `image_picker` 1.2.3 graph (same as #933/#937/#939)

## Verification

- `./tool/analyze.sh` — no issues
- `flutter test --tags golden` (counter) — +8
