# Localization

This document describes the localization setup and supported languages.

## Supported Locales

- English (en)
- Turkish (tr)
- German (de)
- French (fr)
- Spanish (es)
- Arabic (ar) (RTL)

## Automatic Generation

Localization files are **automatically regenerated** when you run `flutter pub get`:

```bash
# Automatic (recommended)
flutter pub get  # Regenerates AppLocalizations if .arb files changed

# Manual regeneration
flutter gen-l10n
```

## Configuration

- **Output Directory**: `apps/mobile/lib/l10n` (prevents deletion during builds)
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

## Error and auth message keys

Error messages used by [NetworkErrorMapper](apps/mobile/lib/shared/utils/network_error_mapper.dart) and [auth_error_message](apps/mobile/lib/features/auth/presentation/helpers/auth_error_message.dart) are localized. Notable keys:

- **HTTP / API:** `errorUnknown`, `errorNetwork`, `errorTimeout`, `errorUnauthorized`, `errorForbidden`, `errorNotFound`, `errorServer`, `errorServiceUnavailable` (503), `errorClient`, `errorTooManyRequests` (429), `errorGeneric`
- **Auth (Firebase):** `authErrorInvalidEmail`, `authErrorWrongPassword`, `authErrorInvalidCredential`, `authErrorNetworkRequestFailed`, `authErrorTooManyRequests`, `authErrorGeneric`, and others (see `app_en.arb`)
- **Session invalidation (Firebase UX):** `sessionExpiredMessage` — snackbar when `AppAuthCubit` enters `sessionExpired` ([`authentication.md`](authentication.md) App auth UX). Every supported locale needs distinct copy in `app_*.arb` **and** locale-specific generated Dart getters (not English fallback strings); guard with focused l10n tests such as [`test/l10n/session_expired_message_localization_test.dart`](../apps/mobile/test/l10n/session_expired_message_localization_test.dart).

Use these via `context.l10n` in the UI layer; repository/cubit code can pass `l10n: null` for English fallbacks.

## ARB Files

Localization strings are defined in `apps/mobile/lib/l10n/app_*.arb` files:

- `app_en.arb` - English (base)
- `app_tr.arb` - Turkish
- `app_de.arb` - German
- `app_fr.arb` - French
- `app_es.arb` - Spanish
- `app_ar.arb` - Arabic (RTL)

## Arabic + RTL notes

- Arabic is an RTL locale. Flutter will automatically use `TextDirection.rtl` for `Locale('ar')`.
- Typography for Arabic uses the **bundled** Cairo font family (see `pubspec.yaml` and `apps/mobile/lib/core/theme/app_theme.dart`).
  - The bundled `assets/fonts/Cairo.ttf` is a variable font (weight axis), so typical `FontWeight` usage maps cleanly without runtime fetching.
- Prefer directional layout primitives in presentation code:
  - `AlignmentDirectional`, `EdgeInsetsDirectional`, `BorderRadiusDirectional`, `TextAlign.start/end`, `PositionedDirectional`.
- ICU plural/select messages must preserve placeholders exactly (e.g. `{count, plural, ...}`) and should use Arabic plural categories (`zero/one/two/few/many/other`) when the string is user-facing.

## Related Documentation

- UI/UX guidelines: [`ui_ux_responsive_review.md`](ui_ux_responsive_review.md)
- Validation scripts: [`validation_scripts.md`](validation_scripts.md) (includes hardcoded string checks)
