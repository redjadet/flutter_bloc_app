part of 'rest_counter_repository.dart';

Future<CounterSnapshot> _restCounterRepositoryLoad(
  final RestCounterRepository repository,
) async {
  final Response<String> response =
      await _restCounterRepositorySendRequest<String>(
        repository: repository,
        operation: 'load',
        request: () => repository._api
            .getCounter(Options(headers: _headers(repository)))
            .then(_stringResponseFromHttpResponse),
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
  // check-ignore: small payload (<8KB) - request body is small
  final Map<String, dynamic> body = <String, dynamic>{
    'userId': normalized.userId,
    'count': normalized.count,
    'last_changed': normalized.lastChanged?.millisecondsSinceEpoch,
  };
  await _restCounterRepositorySendRequest<void>(
    repository: repository,
    operation: 'save',
    request: () => repository._api
        .saveCounter(
          body,
          Options(
            headers: _headers(repository),
            contentType: 'application/json',
          ),
        )
        .then((final hr) => hr.response),
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

Future<Response<T>> _restCounterRepositorySendRequest<T>({
  required final RestCounterRepository repository,
  required final String operation,
  required final Future<Response<T>> Function() request,
  required final CounterError Function({
    Object? originalError,
    String? message,
  })
  errorFactory,
  final CounterError Function(Response<T> response)? onHttpFailure,
}) => NetworkGuard.executeDio<T, CounterError>(
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

Response<String> _stringResponseFromHttpResponse(
  final HttpResponse<String> httpResponse,
) {
  final Response<dynamic> response = httpResponse.response;
  return Response<String>(
    data: response.data is String ? response.data as String : null,
    requestOptions: response.requestOptions,
    statusCode: response.statusCode,
    statusMessage: response.statusMessage,
    isRedirect: response.isRedirect,
    redirects: response.redirects,
    extra: response.extra,
    headers: response.headers,
  );
}

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

void _logHttpError<T>(
  final String operation,
  final Response<T> response,
) {
  AppLogger.error(
    'RestCounterRepository.$operation non-success: ${response.statusCode}',
    'Response body omitted for privacy',
    StackTrace.current,
  );
}
