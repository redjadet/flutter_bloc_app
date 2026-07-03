import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/session_invalidation_reason.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/shared/http/app_dio.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

class _SpyCoordinator extends SessionLifecycleCoordinatorImpl {
  final List<SessionInvalidationReason> invalidationReasons =
      <SessionInvalidationReason>[];

  @override
  Future<void> invalidateSession({
    required final AuthProviderKind provider,
    required final SessionInvalidationReason reason,
  }) async {
    invalidationReasons.add(reason);
    await super.invalidateSession(provider: provider, reason: reason);
  }
}

class _TestNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this._responses);

  final List<int> _responses;
  var _index = 0;

  @override
  Future<ResponseBody> fetch(
    final RequestOptions options,
    final Stream<List<int>>? requestStream,
    final Future<void>? cancelFuture,
  ) async {
    final int statusCode = _responses[_index];
    _index += 1;
    return ResponseBody.fromString(jsonEncode(<String, String>{}), statusCode);
  }

  @override
  void close({final bool force = false}) {}
}

void main() {
  group('AuthTokenInterceptor invalidation', () {
    late _MockFirebaseAuth auth;
    late _MockUser user;
    late _MockIdTokenResult tokenResult;
    late _SpyCoordinator coordinator;
    late AuthTokenManager authTokenManager;

    setUp(() {
      auth = _MockFirebaseAuth();
      user = _MockUser();
      tokenResult = _MockIdTokenResult();
      coordinator = _SpyCoordinator();
      authTokenManager = AuthTokenManager(firebaseAuth: auth);

      when(() => user.uid).thenReturn('user-1');
      when(() => auth.currentUser).thenReturn(user);
      when(() => tokenResult.token).thenReturn('token-1');
      when(
        () => tokenResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      when(() => user.getIdTokenResult()).thenAnswer((_) async => tokenResult);
    });

    Dio buildDio(final HttpClientAdapter adapter) {
      final Dio dio = createAppDio(
        networkStatusService: _TestNetworkStatusService(),
        userAgent: 'test-agent',
        firebaseAuth: auth,
        authTokenManager: authTokenManager,
        sessionCoordinator: coordinator,
        maxRetries: 0,
      );
      dio.httpClientAdapter = adapter;
      return dio;
    }

    test('auth-classified refresh failure invalidates session', () async {
      when(() => user.getIdTokenResult(true)).thenThrow(
        FirebaseAuthException(code: 'user-token-expired', message: 'expired'),
      );

      final Dio dio = buildDio(_SequenceAdapter(<int>[401]));

      final Response<dynamic> response = await dio.get<dynamic>(
        'https://example.com/protected',
      );

      expect(response.statusCode, 401);
      expect(
        coordinator.invalidationReasons,
        contains(SessionInvalidationReason.accessTokenRefreshFailed),
      );
    });

    test('network refresh failure does not invalidate session', () async {
      when(() => user.getIdTokenResult(true)).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'offline',
        ),
      );

      final Dio dio = buildDio(_SequenceAdapter(<int>[401]));

      final Response<dynamic> response = await dio.get<dynamic>(
        'https://example.com/protected',
      );

      expect(response.statusCode, 401);
      expect(coordinator.invalidationReasons, isEmpty);
    });

    test('post-retry 401 invalidates session as remoteRejected', () async {
      when(
        () => user.getIdTokenResult(true),
      ).thenAnswer((_) async => tokenResult);

      final Dio dio = buildDio(_SequenceAdapter(<int>[401, 401]));

      final Response<dynamic> response = await dio.get<dynamic>(
        'https://example.com/protected',
      );

      expect(response.statusCode, 401);
      expect(
        coordinator.invalidationReasons,
        contains(SessionInvalidationReason.remoteRejected),
      );
    });
  });
}
