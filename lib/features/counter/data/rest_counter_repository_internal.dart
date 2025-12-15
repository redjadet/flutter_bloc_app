part of 'rest_counter_repository.dart';

Future<CounterSnapshot> _restCounterRepositoryLoad(
  final RestCounterRepository repository,
) async {
  final http.Response response = await _restCounterRepositorySendRequest(
    repository: repository,
    operation: 'load',
    request: () => repository._client.get(
      repository._counterUri,
      headers: _headers(repository),
    ),
    errorFactory: CounterError.load,
    onHttpFailure: (final http.Response res) => CounterError.load(
      message: 'REST load failed (HTTP ${res.statusCode}).',
    ),
  );
  final CounterSnapshot snapshot = _parseSnapshot(response.body);
  return _storeSnapshot(repository, snapshot);
}

Future<void> _restCounterRepositorySave(
  final RestCounterRepository repository,
  final CounterSnapshot snapshot,
) async {
  final CounterSnapshot normalized = _normalizeSnapshot(repository, snapshot);
  await _restCounterRepositorySendRequest(
    repository: repository,
    operation: 'save',
    request: () => repository._client.post(
      repository._counterUri,
      headers: _headers(
        repository,
        overrides: const {'Content-Type': 'application/json'},
      ),
      body: jsonEncode(<String, dynamic>{
        'userId': normalized.userId,
        'count': normalized.count,
        'last_changed': normalized.lastChanged?.millisecondsSinceEpoch,
      }),
    ),
    errorFactory: CounterError.save,
    onHttpFailure: (final http.Response res) => CounterError.save(
      originalError: http.ClientException(
        'Counter save failed (HTTP ${res.statusCode})',
        repository._counterUri,
      ),
      message: 'Save failed with status ${res.statusCode}',
    ),
  );
  _emitSnapshot(repository, normalized);
}

Future<http.Response> _restCounterRepositorySendRequest({
  required final RestCounterRepository repository,
  required final String operation,
  required final Future<http.Response> Function() request,
  required final CounterError Function({
    Object? originalError,
    String? message,
  })
  errorFactory,
  CounterError Function(http.Response response)? onHttpFailure,
}) => NetworkGuard.execute<CounterError>(
  request: request,
  timeout: repository._requestTimeout,
  isSuccess: _isSuccess,
  logContext: 'RestCounterRepository.$operation',
  onHttpFailure: (final http.Response response) =>
      onHttpFailure?.call(response) ??
      errorFactory(
        originalError: http.ClientException(
          'REST $operation failed (HTTP ${response.statusCode})',
          response.request?.url ?? repository._counterUri,
        ),
        message: 'REST $operation failed (HTTP ${response.statusCode}).',
      ),
  onException: (final Object error) => errorFactory(originalError: error),
  onFailureLog: (final http.Response response) =>
      _logHttpError(operation, response),
);

Map<String, String> _headers(
  final RestCounterRepository repository, {
  final Map<String, String>? overrides,
}) => {
  ...repository._defaultHeaders,
  if (overrides != null) ...overrides,
};

bool _isSuccess(final int statusCode) => statusCode >= 200 && statusCode < 300;

CounterSnapshot _storeSnapshot(
  final RestCounterRepository repository,
  final CounterSnapshot snapshot,
) {
  final CounterSnapshot normalized = _normalizeSnapshot(repository, snapshot);
  repository
    .._latestSnapshot = normalized
    .._initialLoadHelper.markResolved();
  return normalized;
}

CounterSnapshot _normalizeSnapshot(
  final RestCounterRepository repository,
  final CounterSnapshot snapshot,
) {
  final String? userId = snapshot.userId;
  if (userId == null || userId.isEmpty) {
    return snapshot.copyWith(
      userId: RestCounterRepository._emptySnapshot.userId,
    );
  }
  return snapshot;
}

CounterSnapshot _parseSnapshot(final String body) {
  try {
    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw CounterError.load(
        message: 'REST payload was not a JSON object.',
        originalError: decoded,
      );
    }
    final Map<String, dynamic> json = decoded;
    final int count = (json['count'] as num?)?.toInt() ?? 0;
    final int? changedMs = (json['last_changed'] as num?)?.toInt();
    final DateTime? lastChanged = changedMs != null
        ? DateTime.fromMillisecondsSinceEpoch(changedMs)
        : null;
    final String userId =
        json['userId'] as String? ?? json['id'] as String? ?? 'rest';
    return CounterSnapshot(
      userId: userId,
      count: count,
      lastChanged: lastChanged,
    );
  } on CounterError {
    rethrow;
  } on FormatException catch (error) {
    throw CounterError.load(
      message: 'Malformed REST counter payload.',
      originalError: error,
    );
  }
}

void _logHttpError(final String operation, final http.Response response) {
  AppLogger.error(
    'RestCounterRepository.$operation non-success: ${response.statusCode}',
    'Response body omitted for privacy',
    StackTrace.current,
  );
}
