import 'dart:convert';

import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/network_guard.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:http/http.dart' as http;

/// GraphQL-backed repository that talks to https://countries.trevorblades.com.
///
/// [http.Client] instances are injected via `get_it` so DI can dispose them
/// when the app shuts down. Avoid constructing new clients directly in
/// repositories to keep connection pooling and teardown consistent.
class CountriesGraphqlRepository implements GraphqlDemoRepository {
  CountriesGraphqlRepository({final http.Client? client})
    : _client = client ?? http.Client();

  static const String _opContinents = 'Continents';
  static const String _opAllCountries = 'AllCountries';
  static const String _opCountriesByContinent = 'CountriesByContinent';
  static const String _endpoint = 'https://countries.trevorblades.com/';
  static const Map<String, String> _headers = <String, String>{
    'Content-Type': 'application/json',
  };

  final http.Client _client;

  @override
  Future<List<GraphqlContinent>> fetchContinents() async {
    final Map<String, dynamic> data = await _postQuery(
      _continentsQuery,
      operationName: _opContinents,
    );
    final List<dynamic>? rawContinents = listFromDynamic(data['continents']);
    if (rawContinents == null || rawContinents.isEmpty) {
      return const <GraphqlContinent>[];
    }
    return List<GraphqlContinent>.unmodifiable(
      rawContinents
          .map(mapFromDynamic)
          .whereType<Map<String, dynamic>>()
          .map(GraphqlContinent.fromJson)
          .toList(),
    );
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({
    final String? continentCode,
  }) async {
    final String? normalizedCode = _normalizedContinentCode(continentCode);
    if (normalizedCode == null) {
      final Map<String, dynamic> data = await _postQuery(
        _allCountriesQuery,
        operationName: _opAllCountries,
      );
      return _mapCountries(data['countries']);
    }

    final Map<String, dynamic> data = await _postQuery(
      _countriesByContinentQuery,
      variables: <String, dynamic>{'continent': normalizedCode},
      operationName: _opCountriesByContinent,
    );
    final Map<String, dynamic>? continent = mapFromDynamic(data['continent']);
    return _mapCountries(continent?['countries']);
  }

  List<GraphqlCountry> _mapCountries(final Object? rawCountries) {
    final List<dynamic>? list = listFromDynamic(rawCountries);
    if (list == null || list.isEmpty) {
      return const <GraphqlCountry>[];
    }
    return List<GraphqlCountry>.unmodifiable(
      list
          .map(mapFromDynamic)
          .whereType<Map<String, dynamic>>()
          .map(GraphqlCountry.fromJson)
          .toList(),
    );
  }

  String? _normalizedContinentCode(final String? code) {
    if (code == null) {
      return null;
    }
    final String trimmed = code.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.toUpperCase();
  }

  Future<Map<String, dynamic>> _postQuery(
    final String query, {
    final Map<String, dynamic>? variables,
    final String? operationName,
  }) async {
    final Uri uri = Uri.parse(_endpoint);
    final Map<String, dynamic> payload = <String, dynamic>{
      'query': query.trim(),
    };
    if (variables != null && variables.isNotEmpty) {
      payload['variables'] = variables;
    }
    if (operationName != null) {
      payload['operationName'] = operationName;
    }

    const Duration timeout = Duration(seconds: 10);
    final http.Response
    response = await NetworkGuard.execute<GraphqlDemoException>(
      request: () => _client.post(
        uri,
        headers: _headers,
        // check-ignore: small payload (<8KB) - GraphQL request body is small
        body: jsonEncode(payload),
      ),
      timeout: timeout,
      isSuccess: (final statusCode) => statusCode == 200,
      logContext: 'CountriesGraphqlRepository._postQuery',
      onHttpFailure: (final res) {
        final bool isServerError = res.statusCode >= 500;
        return GraphqlDemoException(
          'Unexpected status code: ${res.statusCode}',
          cause: res.body.isNotEmpty ? res.body : null,
          type: isServerError
              ? GraphqlDemoErrorType.server
              : GraphqlDemoErrorType.invalidRequest,
        );
      },
      onException: (final error) => GraphqlDemoException(
        'Failed to reach GraphQL endpoint',
        cause: error,
        type: GraphqlDemoErrorType.network,
      ),
      onFailureLog: (final res) {
        AppLogger.error(
          'CountriesGraphqlRepository._postQuery non-success: ${res.statusCode}',
          'Response body omitted',
          StackTrace.current,
        );
      },
    );

    final Map<String, dynamic> decoded;
    try {
      decoded = await decodeJsonMap(response.body);
    } on FormatException {
      throw GraphqlDemoException(
        'Malformed GraphQL response',
        type: GraphqlDemoErrorType.data,
      );
    }

    final List<dynamic>? errors = decoded['errors'] as List<dynamic>?;
    if (errors != null && errors.isNotEmpty) {
      final dynamic first = errors.first;
      final Map<String, dynamic>? firstError = first is Map<String, dynamic>
          ? first
          : null;
      final String message =
          firstError?['message']?.toString() ?? 'Unknown error';
      throw GraphqlDemoException(
        message,
        cause: firstError,
        type: GraphqlDemoErrorType.invalidRequest,
      );
    }

    final Map<String, dynamic>? data = mapFromDynamic(decoded['data']);
    if (data == null) {
      throw GraphqlDemoException(
        'Missing data field in GraphQL response',
        type: GraphqlDemoErrorType.data,
      );
    }
    return data;
  }

  static const String _continentsQuery = '''
    query Continents {
      continents {
        code
        name
      }
    }
  ''';

  static const String _allCountriesQuery = '''
    query AllCountries {
      countries {
        code
        name
        capital
        currency
        emoji
        continent {
          code
          name
        }
      }
    }
  ''';

  static const String _countriesByContinentQuery = r'''
    query CountriesByContinent($continent: ID!) {
      continent(code: $continent) {
        countries {
          code
          name
          capital
          currency
          emoji
          continent {
            code
            name
          }
        }
      }
    }
  ''';
}
