import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/presentation/graphql_demo_view_models.dart';

void main() {
  const GraphqlContinent europe = GraphqlContinent(code: 'EU', name: 'Europe');
  const GraphqlContinent africa = GraphqlContinent(code: 'AF', name: 'Africa');
  const GraphqlCountry france = GraphqlCountry(
    code: 'FR',
    name: 'France',
    continent: europe,
    capital: 'Paris',
    currency: 'EUR',
  );

  group('GraphqlFilterBarData', () {
    test('supports value equality', () {
      final GraphqlFilterBarData a = GraphqlFilterBarData(
        continents: const <GraphqlContinent>[europe],
        activeContinentCode: 'EU',
        isLoading: false,
      );
      final GraphqlFilterBarData b = GraphqlFilterBarData(
        continents: const <GraphqlContinent>[europe],
        activeContinentCode: 'EU',
        isLoading: false,
      );

      expect(a, equals(b));
    });

    test('detects inequality when properties differ', () {
      final GraphqlFilterBarData base = GraphqlFilterBarData(
        continents: const <GraphqlContinent>[europe],
        activeContinentCode: 'EU',
        isLoading: false,
      );
      final GraphqlFilterBarData differentContinent = GraphqlFilterBarData(
        continents: const <GraphqlContinent>[africa],
        activeContinentCode: 'EU',
        isLoading: false,
      );
      final GraphqlFilterBarData differentSelection = GraphqlFilterBarData(
        continents: const <GraphqlContinent>[europe],
        activeContinentCode: 'AF',
        isLoading: false,
      );

      expect(base, isNot(equals(differentContinent)));
      expect(base, isNot(equals(differentSelection)));
    });
  });

  group('GraphqlBodyData', () {
    test('supports value equality', () {
      final GraphqlBodyData a = GraphqlBodyData(
        isLoading: false,
        hasError: true,
        countries: const <GraphqlCountry>[france],
        errorType: GraphqlDemoErrorType.network,
        errorMessage: 'oops',
      );
      final GraphqlBodyData b = GraphqlBodyData(
        isLoading: false,
        hasError: true,
        countries: const <GraphqlCountry>[france],
        errorType: GraphqlDemoErrorType.network,
        errorMessage: 'oops',
      );

      expect(a, equals(b));
    });

    test('detects inequality when properties differ', () {
      final GraphqlBodyData base = GraphqlBodyData(
        isLoading: false,
        hasError: true,
        countries: const <GraphqlCountry>[france],
        errorType: GraphqlDemoErrorType.network,
        errorMessage: 'oops',
      );
      final GraphqlBodyData differentError = GraphqlBodyData(
        isLoading: false,
        hasError: true,
        countries: const <GraphqlCountry>[france],
        errorType: GraphqlDemoErrorType.data,
        errorMessage: 'oops',
      );
      final GraphqlBodyData differentCountries = GraphqlBodyData(
        isLoading: false,
        hasError: true,
        countries: const <GraphqlCountry>[
          GraphqlCountry(code: 'DE', name: 'Germany', continent: europe),
        ],
        errorType: GraphqlDemoErrorType.network,
        errorMessage: 'oops',
      );

      expect(base, isNot(equals(differentError)));
      expect(base, isNot(equals(differentCountries)));
    });
  });
}
