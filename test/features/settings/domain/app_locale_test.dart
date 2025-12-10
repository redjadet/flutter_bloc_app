import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocale.fromTag', () {
    test('returns null for null or empty', () {
      expect(AppLocale.fromTag(null), isNull);
      expect(AppLocale.fromTag(''), isNull);
    });

    test('parses language-only tags', () {
      final AppLocale? locale = AppLocale.fromTag('en');
      expect(locale, isNotNull);
      expect(locale!.languageCode, 'en');
      expect(locale.countryCode, isNull);
    });

    test('parses language and country when both parts exist', () {
      final AppLocale? locale = AppLocale.fromTag('en_US');
      expect(locale, isNotNull);
      expect(locale!.languageCode, 'en');
      expect(locale.countryCode, 'US');
    });
  });
}
