import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';

/// Remote data source contract for the GraphQL Countries demo.
///
/// Implementations provide continents/countries from a single upstream
/// source (e.g. direct GraphQL API, Supabase-backed tables). The
/// offline-first repository wraps this interface and is responsible for
/// caching and fallback behavior.
abstract class GraphqlRemoteRepository {
  GraphqlDataSource get lastSource;

  Future<List<GraphqlContinent>> fetchContinents();

  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  });
}
