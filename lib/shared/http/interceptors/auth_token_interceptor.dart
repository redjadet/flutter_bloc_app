import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Injects Firebase auth token and retries once on 401 after refresh.
class AuthTokenInterceptor extends QueuedInterceptor {
  AuthTokenInterceptor({
    required final AuthTokenManager authTokenManager,
    required final Dio Function() createRetryDio,
    final FirebaseAuth? firebaseAuth,
  }) : _authTokenManager = authTokenManager,
       _createRetryDio = createRetryDio,
       _firebaseAuth = firebaseAuth;

  final AuthTokenManager _authTokenManager;
  final Dio Function() _createRetryDio;
  final FirebaseAuth? _firebaseAuth;

  static const String requestExtraAuthRetried = 'auth_401_retried';
  static const String requestExtraManagedAuthUser = 'managed_auth_user';
  static const String requestExtraSkipAuthHandling = 'skip_auth_handling';

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
    final _RetryUnauthorizedResult result = await _retryUnauthorizedResponse(
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
    final _RetryUnauthorizedResult result = await _retryUnauthorizedResponse(
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

  Future<_RetryUnauthorizedResult> _retryUnauthorizedResponse(
    final Response<dynamic> response,
  ) async {
    if (response.statusCode != 401) {
      return const _RetryUnauthorizedResult.noRetry();
    }
    final RequestOptions requestOptions = response.requestOptions;
    if (requestOptions.extra[requestExtraSkipAuthHandling] == true ||
        requestOptions.extra[requestExtraAuthRetried] == true) {
      return const _RetryUnauthorizedResult.noRetry();
    }
    final User? user = _managedUserFrom(requestOptions);
    if (user == null) {
      return const _RetryUnauthorizedResult.noRetry();
    }
    final String? refreshedToken = await _refreshManagedUserToken(user);
    if (refreshedToken == null) {
      return const _RetryUnauthorizedResult.noRetry();
    }
    final RequestOptions retryOptions = requestOptions.copyWith(
      headers: Map<String, dynamic>.from(requestOptions.headers),
      extra: Map<String, dynamic>.from(requestOptions.extra),
    );
    retryOptions.extra[requestExtraAuthRetried] = true;
    retryOptions.extra[requestExtraSkipAuthHandling] = true;
    retryOptions.headers['Authorization'] = 'Bearer $refreshedToken';
    retryOptions.extra[requestExtraManagedAuthUser] = user;
    try {
      return _RetryUnauthorizedResult.response(
        await _createRetryDio().fetch<dynamic>(retryOptions),
      );
    } on DioException catch (error, stackTrace) {
      AppLogger.error(
        'AuthTokenInterceptor retry request failed',
        error,
        stackTrace,
      );
      return _RetryUnauthorizedResult.error(error);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'AuthTokenInterceptor retry failed',
        error,
        stackTrace,
      );
      return _RetryUnauthorizedResult.error(
        DioException(
          requestOptions: retryOptions,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  User? _managedUserFrom(final RequestOptions options) {
    final Object? value = options.extra[requestExtraManagedAuthUser];
    return value is User ? value : null;
  }

  Future<String?> _refreshManagedUserToken(final User user) async {
    try {
      return await _authTokenManager.refreshTokenAndGet(user);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'AuthTokenInterceptor failed to refresh token',
        error,
        stackTrace,
      );
      return null;
    }
  }
}

class _RetryUnauthorizedResult {
  const _RetryUnauthorizedResult._({
    this.response,
    this.error,
  });

  const _RetryUnauthorizedResult.noRetry() : this._();

  const _RetryUnauthorizedResult.response(final Response<dynamic> response)
    : this._(response: response);

  const _RetryUnauthorizedResult.error(final DioException error)
    : this._(error: error);

  final Response<dynamic>? response;
  final DioException? error;
}
