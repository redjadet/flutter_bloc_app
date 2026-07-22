import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/app/supabase/edge_then_tables.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_exception_mapper.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/supabase_graphql_demo_parsers.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_remote_repository.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_graphql_demo_repository_impl.part.dart';

class SupabaseGraphqlDemoRepository implements GraphqlRemoteRepository {
  SupabaseGraphqlDemoRepository({
    final String? Function()? readAccessToken,
    final String? Function()? readCurrentUserId,
    final Future<FunctionResponse> Function({
      required String functionName,
      required String accessToken,
      required Map<String, dynamic> body,
    })?
    invokeEdgeFunction,
    final Future<Object?> Function()? fetchContinentRows,
    final Future<Object?> Function(String? code)? fetchCountryRows,
  }) : _readAccessToken = readAccessToken ?? _defaultReadAccessToken,
       _readCurrentUserId = readCurrentUserId ?? _defaultReadCurrentUserId,
       _invokeEdgeFunction = invokeEdgeFunction ?? _defaultInvokeEdgeFunction,
       _fetchContinentRows = fetchContinentRows ?? _defaultFetchContinentRows,
       _fetchCountryRows = fetchCountryRows ?? _defaultFetchCountryRows;

  static const String _continentsTable = 'graphql_continents';
  static const String _countriesTable = 'graphql_countries';
  static const String _syncFunction = 'sync-graphql-countries';
  static const String _authorizationHeader = 'Authorization';

  final String? Function() _readAccessToken;
  final String? Function() _readCurrentUserId;
  final Future<FunctionResponse> Function({
    required String functionName,
    required String accessToken,
    required Map<String, dynamic> body,
  })
  _invokeEdgeFunction;
  final Future<Object?> Function() _fetchContinentRows;
  final Future<Object?> Function(String? code) _fetchCountryRows;

  @override
  GraphqlDataSource get lastSource => _lastSource;

  GraphqlDataSource _lastSource = GraphqlDataSource.supabaseTables;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    _ensureConfigured();
    final SupabaseEdgeThenTablesResult<GraphqlContinent> result =
        await runSupabaseEdgeThenTables<GraphqlContinent>(
          tryEdge: _tryFetchContinentsFromEdge,
          fetchTables: _fetchContinentsFromTables,
          onPostgrestException: graphqlDemoExceptionFromPostgrest,
          onGenericException: (final msg, final cause) => GraphqlDemoException(
            msg,
            cause: cause,
          ),
          logContext: 'SupabaseGraphqlDemoRepository.fetchContinents',
          genericFailureMessage: 'Failed to load continents from Supabase',
        );
    _lastSource = result.fromEdge
        ? GraphqlDataSource.supabaseEdge
        : GraphqlDataSource.supabaseTables;
    return result.result;
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    _ensureConfigured();
    final String? normalized = _normalizedContinentCode(continentCode);
    final SupabaseEdgeThenTablesResult<GraphqlCountry> result =
        await runSupabaseEdgeThenTables<GraphqlCountry>(
          tryEdge: () => _tryFetchCountriesFromEdge(continentCode: normalized),
          fetchTables: () =>
              _fetchCountriesFromTables(continentCode: normalized),
          onPostgrestException: graphqlDemoExceptionFromPostgrest,
          onGenericException: (final msg, final cause) => GraphqlDemoException(
            msg,
            cause: cause,
          ),
          logContext: 'SupabaseGraphqlDemoRepository.fetchCountries',
          genericFailureMessage: 'Failed to load countries from Supabase',
        );
    _lastSource = result.fromEdge
        ? GraphqlDataSource.supabaseEdge
        : GraphqlDataSource.supabaseTables;
    return result.result;
  }

  static String? _defaultReadAccessToken() =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  static String? _defaultReadCurrentUserId() =>
      Supabase.instance.client.auth.currentUser?.id;

  static Future<FunctionResponse> _defaultInvokeEdgeFunction({
    required final String functionName,
    required final String accessToken,
    required final Map<String, dynamic> body,
  }) {
    return Supabase.instance.client.functions.invoke(
      functionName,
      headers: <String, String>{
        _authorizationHeader: 'Bearer $accessToken',
      },
      body: body,
    );
  }

  static Future<Object?> _defaultFetchContinentRows() {
    return Supabase.instance.client
        .from(_continentsTable)
        .select('code, name')
        .order('name');
  }

  static Future<Object?> _defaultFetchCountryRows(final String? continentCode) {
    PostgrestFilterBuilder<dynamic> query = Supabase.instance.client
        .from(_countriesTable)
        .select(
          'code, name, capital, currency, emoji, '
          'continent:graphql_continents!continent_code(code, name)',
        );
    if (continentCode != null) {
      query = query.eq('continent_code', continentCode);
    }
    return query.order('name');
  }
}
