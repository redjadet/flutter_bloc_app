# Localization

This document describes the localization setup and supported languages.

## Supported Locales

- English (en)
- Turkish (tr)
- German (de)
- French (fr)
- Spanish (es)

## Automatic Generation

Localization files are **automatically regenerated** when you run `flutter pub get`:

```bash
# Automatic (recommended)
flutter pub get  # Regenerates AppLocalizations if .arb files changed

# Manual regeneration
flutter gen-l10n
```

## Configuration

- **Output Directory**: `lib/l10n` (prevents deletion during builds)
- **Pre-build Script**: `tool/ensure_localizations.dart` (iOS Xcode integration)
- **After `flutter clean`**: Always run `flutter pub get` before `flutter run`

## Usage in Code

Never hard-code strings. Always use localization:

```dart
// ❌ Bad
Text('Hello World')

// ✅ Good
Text(context.l10n.helloWorld)
```

## ARB Files

Localization strings are defined in `lib/l10n/app_*.arb` files:
- `app_en.arb` - English (base)
- `app_tr.arb` - Turkish
- `app_de.arb` - German
- `app_fr.arb` - French
- `app_es.arb` - Spanish

## Related Documentation

- UI/UX guidelines: `docs/ui_ux_responsive_review.md`
- Validation scripts: `docs/validation_scripts.md` (includes hardcoded string checks)

