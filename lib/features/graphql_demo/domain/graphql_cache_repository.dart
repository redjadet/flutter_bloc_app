import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';

abstract class GraphqlCacheRepository {
  Future<List<GraphqlContinent>> readContinents({
    final Duration? maxAge,
  });

  Future<void> writeContinents(
    final List<GraphqlContinent> continents,
  );

  Future<List<GraphqlCountry>> readCountries({
    final String? continentCode,
    final Duration? maxAge,
  });

  Future<void> writeCountries({
    required final List<GraphqlCountry> countries,
    final String? continentCode,
  });

  Future<void> clear();
}
