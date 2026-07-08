part of 'auth_token_interceptor.dart';

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

class _AuthTokenUnauthorizedRetrier {
  _AuthTokenUnauthorizedRetrier({
    required this.authTokenManager,
    required this.createRetryDio,
    required this.sessionCoordinator,
  });

  final AuthTokenManager authTokenManager;
  final Dio Function() createRetryDio;
  final SessionLifecycleCoordinator? sessionCoordinator;

  Future<_RetryUnauthorizedResult> retry(
    final Response<dynamic> response,
  ) async {
    if (response.statusCode != 401) {
      return const _RetryUnauthorizedResult.noRetry();
    }
    final RequestOptions requestOptions = response.requestOptions;
    if (requestOptions.extra[AuthTokenInterceptor
                .requestExtraSkipAuthHandling] ==
            true ||
        requestOptions.extra[AuthTokenInterceptor.requestExtraAuthRetried] ==
            true) {
      return const _RetryUnauthorizedResult.noRetry();
    }

    final String method = requestOptions.method.toUpperCase();
    if (!_isIdempotentMethod(method) &&
        requestOptions.extra[AuthTokenInterceptor
                .requestExtraAllowAuthRetryNonIdempotent] !=
            true) {
      AppLogger.debug(
        'AuthTokenInterceptor: skip auth retry (non-idempotent): '
        '$method ${requestOptions.uri}',
      );
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
    retryOptions.extra[AuthTokenInterceptor.requestExtraAuthRetried] = true;
    retryOptions.extra[AuthTokenInterceptor.requestExtraSkipAuthHandling] =
        true;
    retryOptions.headers['Authorization'] = 'Bearer $refreshedToken';
    retryOptions.extra[AuthTokenInterceptor.requestExtraManagedAuthUser] = user;
    retryOptions.extra[RetryInterceptor.extraSkipRetry] = true;
    try {
      final Response<dynamic> retried = await createRetryDio().fetch<dynamic>(
        retryOptions,
      );
      if (retried.statusCode == 401) {
        await _invalidateFirebaseSession(
          SessionInvalidationReason.remoteRejected,
        );
      }
      return _RetryUnauthorizedResult.response(retried);
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
    final Object? value =
        options.extra[AuthTokenInterceptor.requestExtraManagedAuthUser];
    return value is User ? value : null;
  }

  Future<String?> _refreshManagedUserToken(final User user) async {
    try {
      return await authTokenManager.refreshTokenAndGet(user);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'AuthTokenInterceptor failed to refresh token',
        error,
        stackTrace,
      );
      if (isAuthClassifiedFirebaseRefreshFailure(error)) {
        await _invalidateFirebaseSession(
          SessionInvalidationReason.accessTokenRefreshFailed,
        );
      }
      return null;
    }
  }

  Future<void> _invalidateFirebaseSession(
    final SessionInvalidationReason reason,
  ) async {
    final SessionLifecycleCoordinator? coordinator = sessionCoordinator;
    if (coordinator == null) {
      return;
    }
    await coordinator.invalidateSession(
      provider: AuthProviderKind.firebase,
      reason: reason,
    );
  }

  bool _isIdempotentMethod(final String method) {
    switch (method.toUpperCase()) {
      case 'GET':
      case 'HEAD':
      case 'PUT':
      case 'DELETE':
      case 'OPTIONS':
      case 'TRACE':
        return true;
    }
    return false;
  }
}
