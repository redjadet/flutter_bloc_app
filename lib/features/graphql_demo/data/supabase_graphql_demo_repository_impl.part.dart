part of 'supabase_graphql_demo_repository.dart';

extension _SupabaseGraphqlDemoRepositoryPrivate
    on SupabaseGraphqlDemoRepository {
  Future<List<GraphqlContinent>> _tryFetchContinentsFromEdge() async {
    try {
      final String? accessToken = _readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return const <GraphqlContinent>[];
      }
      final FunctionResponse response = await _invokeEdgeFunction(
        functionName: SupabaseGraphqlDemoRepository._syncFunction,
        accessToken: accessToken,
        body: const <String, dynamic>{'type': 'continents'},
      );
      final Map<String, dynamic>? json = mapFromDynamic(response.data);
      final List<dynamic>? raw = listFromDynamic(json?['continents']);
      if (raw == null) {
        return const <GraphqlContinent>[];
      }
      return parseGraphqlContinentsFromRaw(raw);
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'SupabaseGraphqlDemoRepository edge continents failed '
        '(${error.runtimeType})',
      );
      _logJwtMismatchDiagnostics(
        error: error,
        accessToken: _readAccessToken(),
      );
      AppLogger.error(
        'SupabaseGraphqlDemoRepository._tryFetchContinentsFromEdge',
        error,
        stackTrace,
      );
      return const <GraphqlContinent>[];
    }
  }

  Future<List<GraphqlCountry>> _tryFetchCountriesFromEdge({
    required final String? continentCode,
  }) async {
    try {
      final String? accessToken = _readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return const <GraphqlCountry>[];
      }
      final Map<String, dynamic> body = <String, dynamic>{'type': 'countries'};
      if (continentCode != null) {
        body['continentCode'] = continentCode;
      }
      final FunctionResponse response = await _invokeEdgeFunction(
        functionName: SupabaseGraphqlDemoRepository._syncFunction,
        accessToken: accessToken,
        body: body,
      );
      final Map<String, dynamic>? json = mapFromDynamic(response.data);
      final List<dynamic>? raw = listFromDynamic(json?['countries']);
      if (raw == null) {
        return const <GraphqlCountry>[];
      }
      return parseGraphqlCountriesFromRaw(raw);
    } on Object catch (error, stackTrace) {
      AppLogger.warning(
        'SupabaseGraphqlDemoRepository edge countries failed '
        '(${error.runtimeType})',
      );
      _logJwtMismatchDiagnostics(
        error: error,
        accessToken: _readAccessToken(),
      );
      AppLogger.error(
        'SupabaseGraphqlDemoRepository._tryFetchCountriesFromEdge',
        error,
        stackTrace,
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
    final String? userId = _readCurrentUserId();
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
      // check-ignore: small payload (<8KB) — JWT claim segment only
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
    final Object? raw = await _fetchContinentRows();
    return parseGraphqlContinentsFromRaw(raw);
  }

  Future<List<GraphqlCountry>> _fetchCountriesFromTables({
    required final String? continentCode,
  }) async {
    final Object? raw = await _fetchCountryRows(continentCode);
    return parseGraphqlCountriesFromRaw(raw);
  }

  void _ensureConfigured() {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw GraphqlDemoException(
        'Supabase is not configured',
        type: GraphqlDemoErrorType.network,
      );
    }
  }

  String? _normalizedContinentCode(final String? code) {
    if (code == null) return null;
    final String trimmed = code.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.toUpperCase();
  }
}
