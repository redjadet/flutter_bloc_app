part of 'rest_counter_repository.dart';

Future<CounterSnapshot> _restCounterRepositoryLoad(
  final RestCounterRepository repository,
) async {
  final Response<String> response = await _restCounterRepositorySendRequest(
    repository: repository,
    operation: 'load',
    request: () => repository._client.get<String>(
      repository._counterUri.toString(),
      options: Options(headers: _headers(repository)),
    ),
    errorFactory: CounterError.load,
    onHttpFailure: (final res) => CounterError.load(
      message: 'REST load failed (HTTP ${res.statusCode}).',
    ),
  );
  final String? body = response.data;
  final CounterSnapshot snapshot = _parseSnapshot(body ?? '');
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
    request: () => repository._client.post<String>(
      repository._counterUri.toString(),
      // check-ignore: small payload (<8KB) - request body is small
      data: jsonEncode(<String, dynamic>{
        'userId': normalized.userId,
        'count': normalized.count,
        'last_changed': normalized.lastChanged?.millisecondsSinceEpoch,
      }),
      options: Options(
        headers: _headers(
          repository,
          overrides: const {'Content-Type': 'application/json'},
        ),
      ),
    ),
    errorFactory: CounterError.save,
    onHttpFailure: (final res) => CounterError.save(
      originalError: Exception(
        'Counter save failed (HTTP ${res.statusCode})',
      ),
      message: 'Save failed with status ${res.statusCode}',
    ),
  );
  _emitSnapshot(repository, normalized);
}

Future<Response<String>> _restCounterRepositorySendRequest({
  required final RestCounterRepository repository,
  required final String operation,
  required final Future<Response<String>> Function() request,
  required final CounterError Function({
    Object? originalError,
    String? message,
  })
  errorFactory,
  final CounterError Function(Response<String> response)? onHttpFailure,
}) => NetworkGuard.executeDio<String, CounterError>(
  request: request,
  timeout: repository._requestTimeout,
  isSuccess: _isSuccess,
  logContext: 'RestCounterRepository.$operation',
  onHttpFailure: (final response) =>
      onHttpFailure?.call(response) ??
      errorFactory(
        originalError: Exception(
          'REST $operation failed (HTTP ${response.statusCode})',
        ),
        message: 'REST $operation failed (HTTP ${response.statusCode}).',
      ),
  onException: (final error) => errorFactory(originalError: error),
  onFailureLog: (final response) => _logHttpError(operation, response),
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
    // check-ignore: small payload (<8KB) - counter snapshot responses are small
    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw CounterError.load(
        message: 'REST payload was not a JSON object.',
        originalError: decoded,
      );
    }
    final Map<String, dynamic> json = decoded;
    final int count = intFromDynamic(json['count']) ?? 0;
    final int? changedMs = intFromDynamic(json['last_changed']);
    final DateTime? lastChanged = changedMs != null
        ? DateTime.fromMillisecondsSinceEpoch(changedMs)
        : null;
    final String userId =
        stringFromDynamic(json['userId']) ??
        stringFromDynamic(json['id']) ??
        'rest';
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

void _logHttpError(
  final String operation,
  final Response<String> response,
) {
  AppLogger.error(
    'RestCounterRepository.$operation non-success: ${response.statusCode}',
    'Response body omitted for privacy',
    StackTrace.current,
  );
}
