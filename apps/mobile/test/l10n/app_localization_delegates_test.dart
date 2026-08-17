import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'appLocalizationDelegates resolve Material and Cupertino for app locales',
    (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: appLocalizationDelegates,
            home: Builder(
              builder: (context) {
                expect(MaterialLocalizations.of(context), isNotNull);
                expect(CupertinoLocalizations.of(context), isNotNull);
                expect(AppLocalizations.of(context), isNotNull);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      }
    },
  );
}
