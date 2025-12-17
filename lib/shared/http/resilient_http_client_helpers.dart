part of 'resilient_http_client.dart';

extension _ResilientHttpClientHelpers on ResilientHttpClient {
  Map<String, String> _getStandardHeaders() => <String, String>{
    'User-Agent': _userAgent,
    'Accept': 'application/json, */*',
    // `package:http` (and the underlying Dart IO client) can transparently
    // handle gzip, but not brotli (`br`). Advertising brotli can lead to
    // binary payloads that fail UTF-8 decoding in callers reading `Response.body`.
    'Accept-Encoding': 'gzip',
  };

  void _injectStandardHeaders(final http.BaseRequest request) {
    final Map<String, String> standard = _getStandardHeaders();
    for (final entry in standard.entries) {
      request.headers.putIfAbsent(entry.key, () => entry.value);
    }
  }

  Future<void> _injectAuthToken(
    final http.BaseRequest request, {
    bool forceRefresh = false,
  }) async {
    final FirebaseAuth? firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) {
      return;
    }
    if (request.headers.containsKey('Authorization')) {
      return;
    }
    try {
      final User? user = firebaseAuth.currentUser;
      if (user != null) {
        final String? token = forceRefresh
            ? await _authTokenManager.refreshTokenAndGet(user)
            : await _authTokenManager.getValidAuthToken(user);
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error('Failed to inject auth token', error, stackTrace);
    }
  }

  void _logTelemetry(
    final http.BaseRequest request,
    final http.StreamedResponse response,
    final int durationMs,
  ) {
    AppLogger.debug(
      'HTTP ${request.method} ${request.url} -> ${response.statusCode} (${durationMs}ms)',
    );
  }

  void _logErrorTelemetry(
    final http.BaseRequest request,
    final Object error,
    final int durationMs,
  ) {
    AppLogger.debug(
      'HTTP ${request.method} ${request.url} failed after ${durationMs}ms: $error',
    );
  }

  bool _isTransientError(final http.ClientException error) {
    final String message = error.message.toLowerCase();
    return message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('network') ||
        message.contains('temporary') ||
        message.contains('unavailable') ||
        message.contains('server error');
  }

  bool _isTransientStatusCode(final int statusCode) =>
      statusCode == 408 || statusCode == 429 || statusCode >= 500;

  Duration _calculateRetryDelay(final int attempt) {
    final int baseDelayMs = 1000 * (1 << attempt);
    const int maxDelayMs = 30000;
    final int delayMs = baseDelayMs > maxDelayMs ? maxDelayMs : baseDelayMs;
    final int jitterRange = (delayMs * 0.25).toInt();
    final int jitter =
        (jitterRange *
                2 *
                (0.5 - DateTime.now().microsecondsSinceEpoch % 1000 / 1000))
            .toInt();
    final int finalDelayMs = delayMs + jitter;
    return Duration(milliseconds: finalDelayMs.clamp(1000, maxDelayMs));
  }

  http.BaseRequest _cloneOrFallback(final http.BaseRequest request) {
    if (request is http.Request || request is http.MultipartRequest) {
      return request.clone();
    }
    AppLogger.warning(
      'ResilientHttpClient retry disabled (unsupported request type): '
      '${request.runtimeType}',
    );
    return request;
  }
}
