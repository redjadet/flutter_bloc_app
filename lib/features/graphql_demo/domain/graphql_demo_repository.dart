import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';

/// Abstraction over the GraphQL sample data source.
abstract class GraphqlDemoRepository {
  Future<List<GraphqlContinent>> fetchContinents();
  Future<List<GraphqlCountry>> fetchCountries({String? continentCode});
}
