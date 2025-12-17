import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/http/http_request_extensions.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

part 'resilient_http_client_helpers.dart';

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
    RetryNotificationService? retryNotificationService,
    this.enableTelemetry = true,
    this.enableRetry = true,
    this.maxRetries = 3,
  }) : _innerClient = innerClient,
       _networkStatusService = networkStatusService,
       _userAgent = userAgent,
       _authTokenManager = AuthTokenManager(firebaseAuth: firebaseAuth),
       _firebaseAuth = firebaseAuth,
       _retryNotificationService = retryNotificationService;

  final http.Client _innerClient;
  final NetworkStatusService _networkStatusService;
  final String _userAgent;
  final AuthTokenManager _authTokenManager;
  final FirebaseAuth? _firebaseAuth;
  final RetryNotificationService? _retryNotificationService;
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

    final Stopwatch? stopwatch = enableTelemetry
        ? (Stopwatch()..start())
        : null;

    final http.BaseRequest requestTemplate = _cloneOrFallback(request);
    final bool canRetrySafely = requestTemplate != request;

    try {
      for (int attempt = 0; attempt <= maxRetries; attempt++) {
        final bool isLastAttempt = attempt >= maxRetries;
        final http.BaseRequest attemptRequest = canRetrySafely
            ? requestTemplate.clone()
            : requestTemplate;

        _injectStandardHeaders(attemptRequest);
        await _injectAuthToken(attemptRequest);

        http.StreamedResponse response;
        try {
          response = await _innerClient.send(attemptRequest);
        } on http.ClientException catch (error) {
          if (!enableRetry ||
              !canRetrySafely ||
              isLastAttempt ||
              !_isTransientError(error)) {
            if (enableTelemetry && stopwatch != null) {
              stopwatch.stop();
              _logErrorTelemetry(
                requestTemplate,
                error,
                stopwatch.elapsedMilliseconds,
              );
            }
            rethrow;
          }

          final Duration delay = _calculateRetryDelay(attempt);
          _retryNotificationService?.notifyRetrying(
            RetryNotification(
              method: requestTemplate.method,
              uri: requestTemplate.url,
              attempt: attempt + 1,
              maxAttempts: maxRetries + 1,
              delay: delay,
              error: error,
            ),
          );

          AppLogger.debug(
            'ResilientHttpClient retrying request (attempt ${attempt + 1}/${maxRetries + 1}): $error',
          );
          await Future<void>.delayed(delay);
          continue;
        }

        if (response.statusCode == 401 && canRetrySafely) {
          final bool tokenRefreshed = await _authTokenManager.refreshToken();
          if (tokenRefreshed) {
            final http.BaseRequest retryRequest = requestTemplate.clone();
            _injectStandardHeaders(retryRequest);
            await _injectAuthToken(retryRequest, forceRefresh: true);
            final http.StreamedResponse refreshedResponse = await _innerClient
                .send(retryRequest);
            if (enableTelemetry && stopwatch != null) {
              stopwatch.stop();
              _logTelemetry(
                retryRequest,
                refreshedResponse,
                stopwatch.elapsedMilliseconds,
              );
            }
            return refreshedResponse;
          }
        }

        if (!enableRetry ||
            !canRetrySafely ||
            isLastAttempt ||
            !_isTransientStatusCode(response.statusCode)) {
          if (enableTelemetry && stopwatch != null) {
            stopwatch.stop();
            _logTelemetry(
              attemptRequest,
              response,
              stopwatch.elapsedMilliseconds,
            );
          }
          return response;
        }

        await response.stream.drain<void>();

        final Duration delay = _calculateRetryDelay(attempt);
        _retryNotificationService?.notifyRetrying(
          RetryNotification(
            method: requestTemplate.method,
            uri: requestTemplate.url,
            attempt: attempt + 1,
            maxAttempts: maxRetries + 1,
            delay: delay,
            error: http.ClientException(
              'HTTP ${response.statusCode}',
              requestTemplate.url,
            ),
          ),
        );

        AppLogger.debug(
          'ResilientHttpClient retrying request (attempt ${attempt + 1}/${maxRetries + 1}) due to status ${response.statusCode}',
        );
        await Future<void>.delayed(delay);
      }
    } catch (error, stackTrace) {
      if (enableTelemetry && stopwatch != null) {
        stopwatch.stop();
        _logErrorTelemetry(
          requestTemplate,
          error,
          stopwatch.elapsedMilliseconds,
        );
      }
      AppLogger.error('ResilientHttpClient request failed', error, stackTrace);
      rethrow;
    }

    if (enableTelemetry && stopwatch != null) {
      stopwatch.stop();
      _logErrorTelemetry(
        requestTemplate,
        http.ClientException(
          'Request failed after ${maxRetries + 1} attempts',
          requestTemplate.url,
        ),
        stopwatch.elapsedMilliseconds,
      );
    }

    throw http.ClientException(
      'Request failed after ${maxRetries + 1} attempts',
      requestTemplate.url,
    );
  }

  @override
  void close() {
    _innerClient.close();
  }
}
