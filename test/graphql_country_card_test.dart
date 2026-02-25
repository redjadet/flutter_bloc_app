import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/widgets/graphql_country_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_with_mix_theme.dart';

void main() {
  testWidgets('GraphqlCountryCard renders country details and chips', (
    WidgetTester tester,
  ) async {
    const GraphqlCountry country = GraphqlCountry(
      code: 'TR',
      name: 'Türkiye',
      capital: 'Ankara',
      currency: 'TRY',
      emoji: '🇹🇷',
      continent: GraphqlContinent(code: 'EU', name: 'Europe'),
    );

    await pumpWithMixTheme(
      tester,
      child: GraphqlCountryCard(
        country: country,
        capitalLabel: 'Capital',
        currencyLabel: 'Currency',
      ),
    );

    expect(find.text('🇹🇷'), findsOneWidget);
    expect(find.text('Türkiye'), findsOneWidget);
    expect(find.text('TR - Europe'), findsOneWidget);
    expect(find.text('Capital: Ankara'), findsOneWidget);
    expect(find.text('Currency: TRY'), findsOneWidget);
  });

  testWidgets('GraphqlCountryCard hides detail chips when values missing', (
    WidgetTester tester,
  ) async {
    const GraphqlCountry country = GraphqlCountry(
      code: 'AQ',
      name: 'Antarctica',
      capital: '',
      currency: null,
      emoji: null,
      continent: GraphqlContinent(code: 'AN', name: 'Antarctica'),
    );

    await pumpWithMixTheme(
      tester,
      child: GraphqlCountryCard(
        country: country,
        capitalLabel: 'Capital',
        currencyLabel: 'Currency',
      ),
    );

    expect(find.text('?'), findsOneWidget);
    expect(find.text('Antarctica'), findsOneWidget);
    expect(find.text('AQ - Antarctica'), findsOneWidget);
    expect(find.textContaining('Capital:'), findsNothing);
    expect(find.textContaining('Currency:'), findsNothing);
  });
}
