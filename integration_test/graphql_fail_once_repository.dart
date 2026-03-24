import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';

/// First initial [fetchCountries] (null continent) throws network error; subsequent loads return fake data.
final class GraphqlFailOnceNetworkRepository implements GraphqlDemoRepository {
  GraphqlFailOnceNetworkRepository();

  static const List<GraphqlContinent> _continents = <GraphqlContinent>[
    GraphqlContinent(code: 'EU', name: 'Europe'),
    GraphqlContinent(code: 'NA', name: 'North America'),
  ];

  static const List<GraphqlCountry> _countries = <GraphqlCountry>[
    GraphqlCountry(
      code: 'DE',
      name: 'Germany',
      continent: GraphqlContinent(code: 'EU', name: 'Europe'),
      capital: 'Berlin',
      currency: 'EUR',
      emoji: '🇩🇪',
    ),
    GraphqlCountry(
      code: 'US',
      name: 'United States',
      continent: GraphqlContinent(code: 'NA', name: 'North America'),
      capital: 'Washington, D.C.',
      currency: 'USD',
      emoji: '🇺🇸',
    ),
  ];

  int _initialLoadAttempt = 0;
  GraphqlDataSource _lastSource = GraphqlDataSource.unknown;

  @override
  GraphqlDataSource get lastSource => _lastSource;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async => _continents;

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    if (continentCode == null) {
      _initialLoadAttempt++;
      if (_initialLoadAttempt == 1) {
        throw GraphqlDemoException(
          'integration simulated network failure',
          type: GraphqlDemoErrorType.network,
        );
      }
      return _succeedWithCache(_countries);
    }
    return _succeedWithCache(
      _countries
          .where((final country) => country.continent.code == continentCode)
          .toList(growable: false),
    );
  }

  List<GraphqlCountry> _succeedWithCache(final List<GraphqlCountry> countries) {
    _lastSource = GraphqlDataSource.cache;
    return countries;
  }
}
