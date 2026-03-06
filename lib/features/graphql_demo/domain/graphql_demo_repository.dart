import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';

/// Abstraction over the GraphQL sample data source.
abstract class GraphqlDemoRepository {
  /// Last source that successfully returned data (remote, cache, or unknown).
  GraphqlDataSource get lastSource;

  Future<List<GraphqlContinent>> fetchContinents();
  Future<List<GraphqlCountry>> fetchCountries({final String? continentCode});
}
