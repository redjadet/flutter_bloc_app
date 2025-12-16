import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/http/http_request_extensions.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

/// A resilient HTTP client wrapper that provides:
/// - Automatic auth token injection from FirebaseAuth
/// - Standardized headers (User-Agent, Content-Type, Accept)
/// - Request/response telemetry logging
/// - Token refresh on 401 responses
/// - HTTP status code mapping to domain exceptions
class ResilientHttpClient extends http.BaseClient {
  ResilientHttpClient({
    required http.Client innerClient,
    required NetworkStatusService networkStatusService,
    required String userAgent,
    FirebaseAuth? firebaseAuth,
    this.enableTelemetry = true,
    this.enableRetry = true,
    this.maxRetries = 3,
  }) : _innerClient = innerClient,
       _networkStatusService = networkStatusService,
       _userAgent = userAgent,
       _authTokenManager = AuthTokenManager(firebaseAuth: firebaseAuth);

  final http.Client _innerClient;
  final NetworkStatusService _networkStatusService;
  final String _userAgent;
  final AuthTokenManager _authTokenManager;
  final bool enableTelemetry;
  final bool enableRetry;
  final int maxRetries;

  @override
  Future<http.StreamedResponse> send(final http.BaseRequest request) async {
    // Check network connectivity first
    final NetworkStatus currentStatus = await _networkStatusService
        .getCurrentStatus();
    if (currentStatus == NetworkStatus.offline) {
      throw http.ClientException(
        'No network connection available',
        request.url,
      );
    }

    // Inject standard headers
    request.headers.addAll(_getStandardHeaders());

    // Inject auth token if available
    await _injectAuthToken(request);

    final Stopwatch? stopwatch = enableTelemetry
        ? (Stopwatch()..start())
        : null;

    return _executeWithRetry(() async {
      final http.StreamedResponse response = await _innerClient.send(request);

      if (enableTelemetry && stopwatch != null) {
        stopwatch.stop();
        _logTelemetry(request, response, stopwatch.elapsedMilliseconds);
      }

      // Handle 401 responses by refreshing token and retrying
      if (response.statusCode == 401) {
        final bool tokenRefreshed = await _authTokenManager.refreshToken();
        if (tokenRefreshed) {
          // Retry the request with fresh token
          final http.BaseRequest retryRequest = request.clone();
          await _injectAuthToken(retryRequest);
          return _innerClient.send(retryRequest);
        }
      }

      return response;
    }, stopwatch);
  }

  /// Get standardized headers for all requests
  Map<String, String> _getStandardHeaders() => <String, String>{
    'User-Agent': _userAgent,
    'Accept': 'application/json, */*',
    'Accept-Encoding': 'gzip, deflate, br',
  };

  /// Inject authentication token if user is signed in
  Future<void> _injectAuthToken(final http.BaseRequest request) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String? token = await _authTokenManager.getValidAuthToken(user);
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Failed to inject auth token',
        error,
        stackTrace,
      );
    }
  }

  /// Log successful request telemetry
  void _logTelemetry(
    final http.BaseRequest request,
    final http.StreamedResponse response,
    final int durationMs,
  ) {
    AppLogger.debug(
      'HTTP ${request.method} ${request.url} -> ${response.statusCode} (${durationMs}ms)',
    );
  }

  /// Log failed request telemetry
  void _logErrorTelemetry(
    final http.BaseRequest request,
    final Object error,
    final int durationMs,
  ) {
    AppLogger.debug(
      'HTTP ${request.method} ${request.url} failed after ${durationMs}ms: $error',
    );
  }

  /// Execute a request with automatic retry for transient errors
  Future<http.StreamedResponse> _executeWithRetry(
    Future<http.StreamedResponse> Function() requestFn,
    Stopwatch? stopwatch,
  ) async {
    Object? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await requestFn();
      } on http.ClientException catch (error) {
        lastError = error;

        // Only retry if retries are enabled and this is a transient error
        if (!enableRetry ||
            attempt >= maxRetries ||
            !_isTransientError(error)) {
          if (enableTelemetry && stopwatch != null) {
            stopwatch.stop();
            _logErrorTelemetry(
              _createDummyRequest(),
              error,
              stopwatch.elapsedMilliseconds,
            );
          }
          rethrow;
        }

        // Log retry attempt
        AppLogger.debug(
          'ResilientHttpClient retrying request (attempt ${attempt + 1}/${maxRetries + 1}): $error',
        );

        // Wait before retry (exponential backoff with jitter)
        if (attempt < maxRetries) {
          await Future<void>.delayed(_calculateRetryDelay(attempt));
        }
      } catch (error, stackTrace) {
        lastError = error;

        if (enableTelemetry && stopwatch != null) {
          stopwatch.stop();
          _logErrorTelemetry(
            _createDummyRequest(),
            error,
            stopwatch.elapsedMilliseconds,
          );
        }
        AppLogger.error(
          'ResilientHttpClient request failed',
          error,
          stackTrace,
        );
        rethrow;
      }
    }

    // Should not reach here, but just in case
    if (lastError is Exception) {
      throw lastError;
    }
    throw Exception(
      'Request failed after ${maxRetries + 1} attempts: $lastError',
    );
  }

  /// Check if an error indicates a transient condition that should be retried
  bool _isTransientError(http.ClientException error) {
    final message = error.message.toLowerCase();
    return message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('network') ||
        message.contains('temporary') ||
        message.contains('unavailable') ||
        message.contains('server error');
  }

  /// Calculate retry delay with exponential backoff and jitter
  Duration _calculateRetryDelay(int attempt) {
    // Base delay: 1s, 2s, 4s, 8s, etc.
    final baseDelayMs = 1000 * (1 << attempt); // 2^attempt seconds
    const maxDelayMs = 30000; // Max 30 seconds

    // Cap at max delay
    final delayMs = baseDelayMs > maxDelayMs ? maxDelayMs : baseDelayMs;

    // Add jitter (±25% of delay)
    final jitterRange = (delayMs * 0.25).toInt();
    final jitter =
        (jitterRange *
                2 *
                (0.5 - DateTime.now().microsecondsSinceEpoch % 1000 / 1000))
            .toInt();
    final finalDelayMs = delayMs + jitter;

    return Duration(milliseconds: finalDelayMs.clamp(1000, maxDelayMs));
  }

  /// Create a dummy request for logging when the original request is not available
  http.BaseRequest _createDummyRequest() =>
      http.Request('GET', Uri.parse('unknown://unknown'));

  @override
  void close() {
    _innerClient.close();
  }
}
