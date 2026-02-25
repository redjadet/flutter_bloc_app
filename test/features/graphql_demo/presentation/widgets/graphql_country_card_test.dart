import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/widgets/graphql_country_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

void main() {
  group('GraphqlCountryCard', () {
    testWidgets('renders country information correctly', (tester) async {
      const country = GraphqlCountry(
        code: 'AD',
        name: 'Andorra',
        capital: 'Andorra la Vella',
        currency: 'EUR',
        emoji: '🇦🇩',
        continent: GraphqlContinent(code: 'EU', name: 'Europe'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (final context) => MixTheme(
              data: buildAppMixThemeData(context),
              child: Scaffold(
                body: GraphqlCountryCard(
                  country: country,
                  capitalLabel: 'Capital',
                  currencyLabel: 'Currency',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('🇦🇩'), findsOneWidget);
      expect(find.text('Andorra'), findsOneWidget);
      expect(find.text('AD - Europe'), findsOneWidget);
      expect(find.text('Capital: Andorra la Vella'), findsOneWidget);
      expect(find.text('Currency: EUR'), findsOneWidget);
    });

    testWidgets(
      'renders country information correctly when capital and currency are null',
      (tester) async {
        const country = GraphqlCountry(
          code: 'AD',
          name: 'Andorra',
          capital: null,
          currency: null,
          emoji: '🇦🇩',
          continent: GraphqlContinent(code: 'EU', name: 'Europe'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (final context) => MixTheme(
                data: buildAppMixThemeData(context),
                child: Scaffold(
                  body: GraphqlCountryCard(
                    country: country,
                    capitalLabel: 'Capital',
                    currencyLabel: 'Currency',
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('🇦🇩'), findsOneWidget);
        expect(find.text('Andorra'), findsOneWidget);
        expect(find.text('AD - Europe'), findsOneWidget);
        expect(find.text('Capital: Andorra la Vella'), findsNothing);
        expect(find.text('Currency: EUR'), findsNothing);
      },
    );
  });
}
