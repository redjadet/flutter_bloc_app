import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';

abstract class GraphqlCacheRepository {
  Future<List<GraphqlContinent>> readContinents({
    Duration? maxAge,
  });

  Future<void> writeContinents(
    List<GraphqlContinent> continents,
  );

  Future<List<GraphqlCountry>> readCountries({
    String? continentCode,
    Duration? maxAge,
  });

  Future<void> writeCountries({
    required List<GraphqlCountry> countries,
    String? continentCode,
  });

  Future<void> clear();
}
