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
  final bool enableTelemetry = true,
  final bool enableRetry = true,
  final int maxRetries = 3,
}) {
  final dio = Dio(
    BaseOptions(
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
    ),
  );

  dio.interceptors.add(
    NetworkCheckInterceptor(networkStatusService),
  );

  final AuthTokenManager authTokenManager = AuthTokenManager(
    firebaseAuth: firebaseAuth,
  );
  dio.interceptors.add(
    AuthTokenInterceptor(
      authTokenManager: authTokenManager,
      dio: dio,
      firebaseAuth: firebaseAuth,
    ),
  );

  if (enableRetry) {
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: maxRetries,
        retryNotificationService: retryNotificationService,
      ),
    );
  }

  if (enableTelemetry) {
    dio.interceptors.add(TelemetryInterceptor());
  }

  return dio;
}
