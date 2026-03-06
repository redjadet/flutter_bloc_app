import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Injects Firebase auth token and retries once on 401 after refresh.
class AuthTokenInterceptor extends QueuedInterceptor {
  AuthTokenInterceptor({
    required final AuthTokenManager authTokenManager,
    required final Dio dio,
    final FirebaseAuth? firebaseAuth,
  }) : _authTokenManager = authTokenManager,
       _dio = dio,
       _firebaseAuth = firebaseAuth;

  final AuthTokenManager _authTokenManager;
  final Dio _dio;
  final FirebaseAuth? _firebaseAuth;

  static const String _keyAuthRetried = 'auth_401_retried';

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
    }
  }

  @override
  Future<void> onError(
    final DioException err,
    final ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    if (response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    if (err.requestOptions.extra[_keyAuthRetried] == true) {
      handler.next(err);
      return;
    }
    final bool refreshed = await _authTokenManager.refreshToken();
    if (!refreshed) {
      handler.next(err);
      return;
    }
    err.requestOptions.extra[_keyAuthRetried] = true;
    await _injectToken(err.requestOptions);
    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } on Object catch (e, st) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          stackTrace: st,
        ),
      );
    }
  }
}
