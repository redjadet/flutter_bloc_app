import 'dart:convert';

import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_country.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_exception.dart';
import 'package:flutter_bloc_app/features/graphql_demo/domain/graphql_demo_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

/// GraphQL-backed repository that talks to https://countries.trevorblades.com.
class CountriesGraphqlRepository implements GraphqlDemoRepository {
  CountriesGraphqlRepository({http.Client? client})
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
    final List<dynamic> rawContinents =
        (data['continents'] as List<dynamic>? ?? <dynamic>[]);
    if (rawContinents.isEmpty) {
      return const <GraphqlContinent>[];
    }
    return List<GraphqlContinent>.unmodifiable(
      rawContinents.map(
        (dynamic item) => GraphqlContinent.fromJson(
          Map<String, dynamic>.from(item as Map<Object?, Object?>),
        ),
      ),
    );
  }

  @override
  Future<List<GraphqlCountry>> fetchCountries({String? continentCode}) async {
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
    final Map<String, dynamic>? continent =
        data['continent'] as Map<String, dynamic>?;
    return _mapCountries(continent?['countries']);
  }

  List<GraphqlCountry> _mapCountries(Object? rawCountries) {
    final List<dynamic> list = (rawCountries as List<dynamic>? ?? <dynamic>[]);
    if (list.isEmpty) {
      return const <GraphqlCountry>[];
    }
    return List<GraphqlCountry>.unmodifiable(
      list.map(
        (dynamic item) => GraphqlCountry.fromJson(
          Map<String, dynamic>.from(item as Map<Object?, Object?>),
        ),
      ),
    );
  }

  String? _normalizedContinentCode(String? code) {
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
    String query, {
    Map<String, dynamic>? variables,
    String? operationName,
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

    try {
      final http.Response response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        final bool isServerError = response.statusCode >= 500;
        throw GraphqlDemoException(
          'Unexpected status code: ${response.statusCode}',
          cause: response.body.isNotEmpty ? response.body : null,
          type: isServerError
              ? GraphqlDemoErrorType.server
              : GraphqlDemoErrorType.invalidRequest,
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw GraphqlDemoException(
          'Malformed GraphQL response',
          type: GraphqlDemoErrorType.data,
        );
      }

      final List<dynamic>? errors = decoded['errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        final Map<String, dynamic>? firstError =
            errors.first as Map<String, dynamic>?;
        final String message =
            firstError?['message']?.toString() ?? 'Unknown error';
        throw GraphqlDemoException(
          message,
          cause: firstError,
          type: GraphqlDemoErrorType.invalidRequest,
        );
      }

      final Map<String, dynamic>? data =
          decoded['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw GraphqlDemoException(
          'Missing data field in GraphQL response',
          type: GraphqlDemoErrorType.data,
        );
      }
      return data;
    } catch (error, stackTrace) {
      if (error is GraphqlDemoException) {
        AppLogger.error(
          'CountriesGraphqlRepository._postQuery failed',
          error,
          stackTrace,
        );
        rethrow;
      }
      AppLogger.error(
        'CountriesGraphqlRepository._postQuery failed',
        error,
        stackTrace,
      );
      throw GraphqlDemoException(
        'Failed to reach GraphQL endpoint',
        cause: error,
        type: GraphqlDemoErrorType.network,
      );
    }
  }

  static const String _continentsQuery = r'''
    query Continents {
      continents {
        code
        name
      }
    }
  ''';

  static const String _allCountriesQuery = r'''
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

  static const String _countriesByContinentQuery = '''
    query CountriesByContinent(\$continent: ID!) {
      continent(code: \$continent) {
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
