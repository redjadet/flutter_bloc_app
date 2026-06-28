import 'package:flutter_bloc_app/l10n/app_localizations_ar.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_de.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_es.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_fr.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_tr.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sessionExpiredMessage localization', () {
    test('each supported locale has distinct non-English copy', () {
      final String english = AppLocalizationsEn().sessionExpiredMessage;

      final Map<String, String> localized = <String, String>{
        'en': english,
        'tr': AppLocalizationsTr().sessionExpiredMessage,
        'de': AppLocalizationsDe().sessionExpiredMessage,
        'fr': AppLocalizationsFr().sessionExpiredMessage,
        'es': AppLocalizationsEs().sessionExpiredMessage,
        'ar': AppLocalizationsAr().sessionExpiredMessage,
      };

      for (final MapEntry<String, String> entry in localized.entries) {
        expect(
          entry.value,
          isNotEmpty,
          reason: 'sessionExpiredMessage missing in ${entry.key}',
        );
      }

      for (final MapEntry<String, String> entry in localized.entries) {
        if (entry.key == 'en') {
          continue;
        }
        expect(
          entry.value,
          isNot(english),
          reason:
              'sessionExpiredMessage in ${entry.key} must not fall back to English',
        );
      }

      expect(localized.values.toSet().length, localized.length);
    });
  });
}
