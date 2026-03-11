import 'dart:convert';

import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/core/supabase/edge_then_tables.dart';
import 'package:flutter_bloc_app/features/graphql_demo/data/graphql_demo_exception_mapper.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_data_source.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_remote_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseGraphqlDemoRepository implements GraphqlRemoteRepository {
  static const String _continentsTable = 'graphql_continents';
  static const String _countriesTable = 'graphql_countries';
  static const String _syncFunction = 'sync-graphql-countries';
  static const String _authorizationHeader = 'Authorization';

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

  Future<List<GraphqlContinent>> _tryFetchContinentsFromEdge() async {
    try {
      // Non-2xx responses throw FunctionException; we catch below and fall back.
      //
      // We explicitly pass the access token. In some configurations the
      // Functions client can end up using the anon key as `Authorization`,
      // which triggers `Invalid JWT` when `verify_jwt: true`.
      final String? accessToken =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        return const <GraphqlContinent>[];
      }
      final FunctionResponse response = await Supabase.instance.client.functions
          .invoke(
            _syncFunction,
            headers: <String, String>{
              _authorizationHeader: 'Bearer $accessToken',
            },
            body: const <String, dynamic>{'type': 'continents'},
          );
      final Map<String, dynamic>? json = mapFromDynamic(response.data);
      final List<dynamic>? raw = listFromDynamic(json?['continents']);
      if (raw == null) {
        return const <GraphqlContinent>[];
      }
      return _parseContinentsResilient(raw);
    } on Object catch (e, s) {
      AppLogger.warning(
        'SupabaseGraphqlDemoRepository edge continents failed '
        '(${e.runtimeType})',
      );
      _logJwtMismatchDiagnostics(
        error: e,
        accessToken: Supabase.instance.client.auth.currentSession?.accessToken,
      );
      AppLogger.error(
        'SupabaseGraphqlDemoRepository._tryFetchContinentsFromEdge',
        e,
        s,
      );
      return const <GraphqlContinent>[];
    }
  }

  Future<List<GraphqlCountry>> _tryFetchCountriesFromEdge({
    required final String? continentCode,
  }) async {
    try {
      final String? accessToken =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        return const <GraphqlCountry>[];
      }
      final Map<String, dynamic> body = <String, dynamic>{'type': 'countries'};
      if (continentCode != null) {
        body['continentCode'] = continentCode;
      }
      final FunctionResponse response = await Supabase.instance.client.functions
          .invoke(
            _syncFunction,
            headers: <String, String>{
              _authorizationHeader: 'Bearer $accessToken',
            },
            body: body,
          );
      final Map<String, dynamic>? json = mapFromDynamic(response.data);
      final List<dynamic>? raw = listFromDynamic(json?['countries']);
      if (raw == null) {
        return const <GraphqlCountry>[];
      }
      return _parseCountriesResilient(raw);
    } on Object catch (e, s) {
      AppLogger.warning(
        'SupabaseGraphqlDemoRepository edge countries failed '
        '(${e.runtimeType})',
      );
      _logJwtMismatchDiagnostics(
        error: e,
        accessToken: Supabase.instance.client.auth.currentSession?.accessToken,
      );
      AppLogger.error(
        'SupabaseGraphqlDemoRepository._tryFetchCountriesFromEdge',
        e,
        s,
      );
      return const <GraphqlCountry>[];
    }
  }

  void _logJwtMismatchDiagnostics({
    required final Object error,
    required final String? accessToken,
  }) {
    if (error is! FunctionException) return;
    if (error.status != 401) return;

    final String? iss = _tryReadJwtIssuer(accessToken);
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    final int tokenLength = accessToken?.length ?? 0;
    final String? configuredUrl = SecretConfig.supabaseUrl;
    AppLogger.warning(
      'SupabaseGraphqlDemoRepository edge 401 Invalid JWT diagnostics: '
      'initialized=${SupabaseBootstrapService.isSupabaseInitialized} '
      'configuredUrl=${configuredUrl ?? 'null'} '
      'userId=${userId ?? 'null'} '
      'iss=${iss ?? 'null'} '
      'tokenLength=$tokenLength',
    );
  }

  String? _tryReadJwtIssuer(final String? token) {
    if (token == null || token.isEmpty) return null;
    final List<String> parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final String payload = _base64UrlDecodeToString(parts[1]);
      // check-ignore: small payload (<8KB) - JWT payload inspection is tiny
      final dynamic decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;
      final Object? iss = decoded['iss'];
      return iss is String ? iss : null;
    } on FormatException {
      return null;
    } on Exception {
      return null;
    }
  }

  String _base64UrlDecodeToString(final String input) {
    final String normalized = base64Url.normalize(input);
    return utf8.decode(base64Url.decode(normalized));
  }

  Future<List<GraphqlContinent>> _fetchContinentsFromTables() async {
    final dynamic raw = await Supabase.instance.client
        .from(_continentsTable)
        .select('code, name')
        .order('name');
    return _mapContinents(raw);
  }

  Future<List<GraphqlCountry>> _fetchCountriesFromTables({
    required final String? continentCode,
  }) async {
    PostgrestFilterBuilder<dynamic> query = Supabase.instance.client
        .from(_countriesTable)
        .select(
          'code, name, capital, currency, emoji, '
          'continent:graphql_continents!continent_code(code, name)',
        );
    if (continentCode != null) {
      query = query.eq('continent_code', continentCode);
    }
    final dynamic raw = await query.order('name');
    return _mapCountries(raw);
  }

  void _ensureConfigured() {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw GraphqlDemoException(
        'Supabase is not configured',
        type: GraphqlDemoErrorType.network,
      );
    }
  }

  /// Parses a list of continent-like maps; skips invalid items and logs.
  List<GraphqlContinent> _parseContinentsResilient(final List<dynamic> raw) {
    final List<GraphqlContinent> out = <GraphqlContinent>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = mapFromDynamic(item);
      if (map == null) continue;
      try {
        out.add(GraphqlContinent.fromJson(map));
      } on Exception catch (e, s) {
        AppLogger.warning(
          'SupabaseGraphqlDemoRepository skip invalid continent row',
        );
        AppLogger.error(
          'SupabaseGraphqlDemoRepository._parseContinentsResilient',
          e,
          s,
        );
      }
    }
    return List<GraphqlContinent>.unmodifiable(out);
  }

  /// Parses a list of country-like maps; skips invalid items and logs.
  List<GraphqlCountry> _parseCountriesResilient(final List<dynamic> raw) {
    final List<GraphqlCountry> out = <GraphqlCountry>[];
    for (final dynamic item in raw) {
      final Map<String, dynamic>? map = mapFromDynamic(item);
      if (map == null) continue;
      try {
        out.add(GraphqlCountry.fromJson(map));
      } on Exception catch (e, s) {
        AppLogger.warning(
          'SupabaseGraphqlDemoRepository skip invalid country row',
        );
        AppLogger.error(
          'SupabaseGraphqlDemoRepository._parseCountriesResilient',
          e,
          s,
        );
      }
    }
    return List<GraphqlCountry>.unmodifiable(out);
  }

  List<GraphqlContinent> _mapContinents(final Object? raw) {
    final List<dynamic>? list = listFromDynamic(raw);
    if (list == null || list.isEmpty) {
      return const <GraphqlContinent>[];
    }
    return _parseContinentsResilient(list);
  }

  List<GraphqlCountry> _mapCountries(final Object? raw) {
    final List<dynamic>? list = listFromDynamic(raw);
    if (list == null || list.isEmpty) {
      return const <GraphqlCountry>[];
    }
    return _parseCountriesResilient(list);
  }

  String? _normalizedContinentCode(final String? code) {
    if (code == null) return null;
    final String trimmed = code.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }
}
