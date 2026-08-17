import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/widgets/graphql_filter_bar.dart';
import 'package:flutter_bloc_app/l10n/app_localization_delegates.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpFilterBar(
    WidgetTester tester, {
    required String? activeContinentCode,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              body: GraphqlFilterBar(
                continents: const <GraphqlContinent>[
                  GraphqlContinent(code: 'EU', name: 'Europe'),
                  GraphqlContinent(code: 'AF', name: 'Africa'),
                ],
                activeContinentCode: activeContinentCode,
                isLoading: false,
                l10n: l10n,
              ),
            );
          },
        ),
      ),
    );
  }

  group('GraphqlFilterBar', () {
    testWidgets('keeps selected continent when code exists', (tester) async {
      await pumpFilterBar(tester, activeContinentCode: 'EU');

      final DropdownButtonFormField<String?> dropdown = tester.widget(
        find.byType(DropdownButtonFormField<String?>),
      );
      expect(dropdown.initialValue, 'EU');
    });

    testWidgets('falls back to all continents for stale code', (tester) async {
      await pumpFilterBar(tester, activeContinentCode: 'ZZ');

      final DropdownButtonFormField<String?> dropdown = tester.widget(
        find.byType(DropdownButtonFormField<String?>),
      );
      expect(dropdown.initialValue, isNull);
      expect(tester.takeException(), isNull);
    });
  });
}
