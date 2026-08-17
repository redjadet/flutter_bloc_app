import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/http/auth/auth_token_manager.dart';
import 'package:flutter_bloc_app/app/http/auth/interceptors/auth_token_interceptor.dart';
import 'package:networking/networking.dart';

/// Creates a [Dio] instance with app-wide interceptors (network check, auth,
/// retry, telemetry).
Dio createAppDio({
  required NetworkStatusService networkStatusService,
  required String userAgent,
  required AuthTokenManager authTokenManager,
  FirebaseAuth? firebaseAuth,
  SessionLifecycleCoordinator? sessionCoordinator,
  RetryNotificationService? retryNotificationService,
  TelemetryEventSink? telemetryEventSink,
  Future<void> Function(Duration delay)? waitForRetryDelay,
  bool enableTelemetry = true,
  bool enableRetry = true,
  int maxRetries = 3,
}) {
  final Dio dio = Dio(_createBaseOptions(userAgent: userAgent));
  _configureInterceptors(
    dio: dio,
    networkStatusService: networkStatusService,
    authTokenManager: authTokenManager,
    firebaseAuth: firebaseAuth,
    sessionCoordinator: sessionCoordinator,
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

BaseOptions _createBaseOptions({required String userAgent}) {
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
    validateStatus: (_) => true,
  );
}

void _configureInterceptors({
  required Dio dio,
  required NetworkStatusService networkStatusService,
  required RetryNotificationService? retryNotificationService,
  required TelemetryEventSink? telemetryEventSink,
  required Future<void> Function(Duration delay)? waitForRetryDelay,
  required bool enableAuth,
  required bool enableRetry,
  required bool enableTelemetry,
  required int maxRetries,
  AuthTokenManager? authTokenManager,
  FirebaseAuth? firebaseAuth,
  SessionLifecycleCoordinator? sessionCoordinator,
  Dio Function()? createAuthRetryDio,
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
        sessionCoordinator: sessionCoordinator,
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
  required Dio sourceDio,
  required NetworkStatusService networkStatusService,
  required RetryNotificationService? retryNotificationService,
  required TelemetryEventSink? telemetryEventSink,
  required Future<void> Function(Duration delay)? waitForRetryDelay,
  required bool enableRetry,
  required bool enableTelemetry,
  required int maxRetries,
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
