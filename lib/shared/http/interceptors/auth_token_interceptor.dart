import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/session_invalidation_reason.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_refresh_classifier.dart';
import 'package:flutter_bloc_app/shared/http/interceptors/retry_interceptor.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'auth_token_interceptor_retry.part.dart';

/// Injects Firebase auth token and retries once on 401 after refresh.
class AuthTokenInterceptor extends QueuedInterceptor {
  AuthTokenInterceptor({
    required this._authTokenManager,
    required this._createRetryDio,
    this._firebaseAuth,
    this._sessionCoordinator,
  });

  final AuthTokenManager _authTokenManager;
  final Dio Function() _createRetryDio;
  final FirebaseAuth? _firebaseAuth;
  final SessionLifecycleCoordinator? _sessionCoordinator;

  late final _AuthTokenUnauthorizedRetrier _unauthorizedRetrier =
      _AuthTokenUnauthorizedRetrier(
        authTokenManager: _authTokenManager,
        createRetryDio: _createRetryDio,
        sessionCoordinator: _sessionCoordinator,
      );

  static const String requestExtraAuthRetried = 'auth_401_retried';
  static const String requestExtraManagedAuthUser = 'managed_auth_user';
  static const String requestExtraSkipAuthHandling = 'skip_auth_handling';
  static const String requestExtraAllowAuthRetryNonIdempotent =
      'allow_auth_retry_non_idempotent';

  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) {
    unawaited(
      _injectToken(options).then((_) => handler.next(options)).catchError(
        (final Object error, final StackTrace stackTrace) {
          AppLogger.error(
            'AuthTokenInterceptor failed to inject token',
            error,
            stackTrace,
          );
          handler.next(options);
        },
      ),
    );
  }

  Future<void> _injectToken(final RequestOptions options) async {
    if (options.extra[requestExtraSkipAuthHandling] == true) {
      return;
    }
    if (options.headers.containsKey('Authorization')) {
      return;
    }
    final User? user = _firebaseAuth?.currentUser;
    if (user == null) {
      return;
    }
    final String? token = await _authTokenManager.getValidAuthToken(user);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[requestExtraManagedAuthUser] = user;
    }
  }

  @override
  Future<void> onResponse(
    final Response<dynamic> response,
    final ResponseInterceptorHandler handler,
  ) async {
    final _RetryUnauthorizedResult result = await _unauthorizedRetrier.retry(
      response,
    );
    if (result.response case final Response<dynamic> retried) {
      handler.resolve(retried);
      return;
    }
    if (result.error case final DioException error) {
      handler.reject(error);
      return;
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    final DioException err,
    final ErrorInterceptorHandler handler,
  ) async {
    final Response<dynamic>? response = err.response;
    if (response == null) {
      handler.next(err);
      return;
    }
    final _RetryUnauthorizedResult result = await _unauthorizedRetrier.retry(
      response,
    );
    if (result.response case final Response<dynamic> retried) {
      handler.resolve(retried);
      return;
    }
    if (result.error case final DioException error) {
      handler.next(error);
      return;
    }
    handler.next(err);
  }
}
