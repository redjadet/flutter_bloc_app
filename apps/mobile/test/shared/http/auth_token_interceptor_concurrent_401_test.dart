import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/http/app_dio.dart';
import 'package:flutter_bloc_app/app/http/auth/auth_token_manager.dart';
import 'package:networking/networking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

class _TestNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _Concurrent401Adapter implements HttpClientAdapter {
  final Completer<void> refreshStarted = Completer<void>();
  final Completer<void> releaseRefresh = Completer<void>();
  var _refreshCalls = 0;
  var _requestCount = 0;

  int get refreshCalls => _refreshCalls;

  @override
  Future<ResponseBody> fetch(
    final RequestOptions options,
    final Stream<List<int>>? requestStream,
    final Future<void>? cancelFuture,
  ) async {
    _requestCount += 1;
    if (_requestCount == 1) {
      return ResponseBody.fromString(jsonEncode(<String, String>{}), 401);
    }
    if (!refreshStarted.isCompleted) {
      refreshStarted.complete();
    }
    await releaseRefresh.future;
    return ResponseBody.fromString(jsonEncode(<String, String>{}), 200);
  }

  void markRefreshCalled() {
    _refreshCalls += 1;
  }

  @override
  void close({final bool force = false}) {}
}

void main() {
  test('parallel 401 responses share one serialized refresh', () async {
    final _MockFirebaseAuth auth = _MockFirebaseAuth();
    final _MockUser user = _MockUser();
    final _MockIdTokenResult initial = _MockIdTokenResult();
    final _MockIdTokenResult refreshed = _MockIdTokenResult();
    final _Concurrent401Adapter adapter = _Concurrent401Adapter();

    when(() => user.uid).thenReturn('user-1');
    when(() => auth.currentUser).thenReturn(user);
    when(() => initial.token).thenReturn('initial');
    when(
      () => initial.expirationTime,
    ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
    when(() => refreshed.token).thenReturn('refreshed');
    when(
      () => refreshed.expirationTime,
    ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
    when(() => user.getIdTokenResult(false)).thenAnswer((_) async => initial);
    when(() => user.getIdTokenResult(true)).thenAnswer((_) async {
      adapter.markRefreshCalled();
      return refreshed;
    });

    final Dio dio = createAppDio(
      networkStatusService: _TestNetworkStatusService(),
      userAgent: 'test-agent',
      firebaseAuth: auth,
      authTokenManager: AuthTokenManager(firebaseAuth: auth),
      maxRetries: 0,
    )..httpClientAdapter = adapter;

    final Future<Response<dynamic>> first = dio.get<dynamic>(
      'https://example.com/a',
    );
    final Future<Response<dynamic>> second = dio.get<dynamic>(
      'https://example.com/b',
    );

    await adapter.refreshStarted.future;
    adapter.releaseRefresh.complete();
    final List<Response<dynamic>> responses = await Future.wait(
      <Future<Response<dynamic>>>[first, second],
    );

    expect(responses.every((final r) => r.statusCode == 200), isTrue);
    expect(adapter.refreshCalls, 1);
  });
}
