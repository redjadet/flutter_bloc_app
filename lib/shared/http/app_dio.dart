import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/auth_token_interceptor.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/network_check_interceptor.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/retry_interceptor.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/telemetry_interceptor.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';

/// Creates a [Dio] instance with app-wide interceptors (network check, auth,
/// retry, telemetry).
Dio createAppDio({
  required final NetworkStatusService networkStatusService,
  required final String userAgent,
  final FirebaseAuth? firebaseAuth,
  final RetryNotificationService? retryNotificationService,
  final TelemetryEventSink? telemetryEventSink,
  final Future<void> Function(Duration delay)? waitForRetryDelay,
  final bool enableTelemetry = true,
  final bool enableRetry = true,
  final int maxRetries = 3,
}) {
  final AuthTokenManager authTokenManager = AuthTokenManager(
    firebaseAuth: firebaseAuth,
  );
  final Dio dio = Dio(_createBaseOptions(userAgent: userAgent));
  _configureInterceptors(
    dio: dio,
    networkStatusService: networkStatusService,
    authTokenManager: authTokenManager,
    firebaseAuth: firebaseAuth,
    retryNotificationService: retryNotificationService,
    telemetryEventSink: telemetryEventSink,
    waitForRetryDelay: waitForRetryDelay,
    enableAuth: true,
    enableRetry: enableRetry,
    enableTelemetry: enableTelemetry,
    maxRetries: maxRetries,
    createAuthRetryDio: () => _createAuthRetryDio(
      sourceDio: dio,
      networkStatusService: networkStatusService,
      retryNotificationService: retryNotificationService,
      telemetryEventSink: telemetryEventSink,
      waitForRetryDelay: waitForRetryDelay,
      enableRetry: enableRetry,
      enableTelemetry: enableTelemetry,
      maxRetries: maxRetries,
    ),
  );
  return dio;
}

BaseOptions _createBaseOptions({required final String userAgent}) {
  return BaseOptions(
    headers: <String, dynamic>{
      'User-Agent': userAgent,
      'Accept': 'application/json, */*',
      'Accept-Encoding': 'gzip',
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    // Let repositories and NetworkGuard inspect non-2xx responses directly
    // so existing status-based error mapping remains intact.
    validateStatus: (final _) => true,
  );
}

void _configureInterceptors({
  required final Dio dio,
  required final NetworkStatusService networkStatusService,
  required final RetryNotificationService? retryNotificationService,
  required final TelemetryEventSink? telemetryEventSink,
  required final Future<void> Function(Duration delay)? waitForRetryDelay,
  required final bool enableAuth,
  required final bool enableRetry,
  required final bool enableTelemetry,
  required final int maxRetries,
  final AuthTokenManager? authTokenManager,
  final FirebaseAuth? firebaseAuth,
  final Dio Function()? createAuthRetryDio,
}) {
  dio.interceptors.add(NetworkCheckInterceptor(networkStatusService));

  if (enableAuth) {
    final AuthTokenManager resolvedAuthTokenManager;
    final Dio Function() resolvedCreateAuthRetryDio;
    if (authTokenManager case final value?) {
      resolvedAuthTokenManager = value;
    } else {
      throw StateError(
        'authTokenManager is required when auth interceptors are enabled',
      );
    }
    if (createAuthRetryDio case final value?) {
      resolvedCreateAuthRetryDio = value;
    } else {
      throw StateError(
        'createAuthRetryDio is required when auth interceptors are enabled',
      );
    }
    dio.interceptors.add(
      AuthTokenInterceptor(
        authTokenManager: resolvedAuthTokenManager,
        createRetryDio: resolvedCreateAuthRetryDio,
        firebaseAuth: firebaseAuth,
      ),
    );
  }

  if (enableRetry) {
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: maxRetries,
        retryNotificationService: retryNotificationService,
        waitForDelay: waitForRetryDelay,
      ),
    );
  }

  if (enableTelemetry) {
    dio.interceptors.add(TelemetryInterceptor(eventSink: telemetryEventSink));
  }
}

Dio _createAuthRetryDio({
  required final Dio sourceDio,
  required final NetworkStatusService networkStatusService,
  required final RetryNotificationService? retryNotificationService,
  required final TelemetryEventSink? telemetryEventSink,
  required final Future<void> Function(Duration delay)? waitForRetryDelay,
  required final bool enableRetry,
  required final bool enableTelemetry,
  required final int maxRetries,
}) {
  final Dio dio = Dio(sourceDio.options.copyWith())
    ..httpClientAdapter = sourceDio.httpClientAdapter
    ..transformer = sourceDio.transformer;
  _configureInterceptors(
    dio: dio,
    networkStatusService: networkStatusService,
    retryNotificationService: retryNotificationService,
    telemetryEventSink: telemetryEventSink,
    waitForRetryDelay: waitForRetryDelay,
    enableAuth: false,
    enableRetry: enableRetry,
    enableTelemetry: enableTelemetry,
    maxRetries: maxRetries,
  );
  return dio;
}
