part of 'countries_graphql_repository.dart';

extension _CountriesGraphqlRepositoryQueries on CountriesGraphqlRepository {
  List<GraphqlCountry> mapCountries(final Object? rawCountries) {
    final List<dynamic>? list = listFromDynamic(rawCountries);
    if (list == null || list.isEmpty) {
      return const <GraphqlCountry>[];
    }
    return List<GraphqlCountry>.unmodifiable(
      list.map(mapFromDynamic).whereType<Map<String, dynamic>>().map((json) {
        try {
          return GraphqlCountryDto.fromJson(json).toDomain();
        } on FormatException catch (e) {
          throw GraphqlDemoException(
            'Malformed GraphQL country payload',
            cause: e,
            type: GraphqlDemoErrorType.data,
          );
        }
      }).toList(),
    );
  }

  String? normalizedContinentCode(final String? code) {
    if (code == null) {
      return null;
    }
    final String trimmed = code.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.toUpperCase();
  }

  Future<Map<String, dynamic>> postQuery(
    final String query, {
    final Map<String, dynamic>? variables,
    final String? operationName,
  }) async {
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
    final Response<List<int>>
    response = await NetworkGuard.executeDio<List<int>, GraphqlDemoException>(
      request: () => _api
          .postQuery(payload, CountriesGraphqlRepository.options())
          .then(bytesResponseFromHttpResponse),
      timeout: timeout,
      isSuccess: (final statusCode) => statusCode == 200,
      logContext:
          'CountriesGraphqlRepository._postQuery'
          '${operationName != null ? '.$operationName' : ''}',
      onHttpFailure: (final res) {
        final int? statusCode = res.statusCode;
        final bool isServerError = (statusCode ?? 0) >= 500;
        final String? bodyData = responseBodyAsDiagnosticString(res.data);
        return GraphqlDemoException(
          'Unexpected status code: $statusCode',
          cause: bodyData != null && bodyData.isNotEmpty ? bodyData : null,
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

    final List<int>? responseBody = response.data;
    if (responseBody == null || responseBody.isEmpty) {
      throw GraphqlDemoException(
        'Empty GraphQL response',
        type: GraphqlDemoErrorType.data,
      );
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = await decodeJsonMapFromBytes(responseBody);
    } on FormatException {
      throw GraphqlDemoException(
        'Malformed GraphQL response',
        type: GraphqlDemoErrorType.data,
      );
    }

    final List<dynamic>? errors = listFromDynamic(decoded['errors']);
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

  static String? responseBodyAsDiagnosticString(final Object? data) {
    if (data == null) {
      return null;
    }
    if (data is String) {
      return data;
    }
    if (data is List<int>) {
      if (data.isEmpty) {
        return null;
      }
      try {
        return utf8.decode(data);
      } on FormatException {
        return null;
      }
    }
    return null;
  }

  static const String continentsQuery = '''
    query Continents {
      continents {
        code
        name
      }
    }
  ''';

  static const String allCountriesQuery = '''
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

  static const String countriesByContinentQuery = r'''
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
