import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class _FakeNetworkStatusService implements NetworkStatusService {
  _FakeNetworkStatusService(this._status);

  final NetworkStatus _status;

  @override
  Stream<NetworkStatus> get statusStream =>
      Stream<NetworkStatus>.value(_status);

  @override
  Future<NetworkStatus> getCurrentStatus() =>
      Future<NetworkStatus>.value(_status);

  @override
  Future<void> dispose() => Future<void>.value();
}

class _CountingClient extends http.BaseClient {
  _CountingClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;
  int callCount = 0;

  @override
  Future<http.StreamedResponse> send(final http.BaseRequest request) {
    callCount += 1;
    return _handler(request);
  }
}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  test('retries transient HTTP status codes and emits notification', () {
    fakeAsync((final async) {
      int callCount = 0;
      final InMemoryRetryNotificationService retryService =
          InMemoryRetryNotificationService();
      final List<RetryNotification> notifications = <RetryNotification>[];
      final subscription = retryService.notifications.listen(notifications.add);

      final http.Client inner = MockClient((final request) async {
        callCount += 1;
        return http.Response(
          callCount == 1 ? 'server error' : 'ok',
          callCount == 1 ? 500 : 200,
        );
      });

      final ResilientHttpClient client = ResilientHttpClient(
        innerClient: inner,
        networkStatusService: _FakeNetworkStatusService(NetworkStatus.online),
        userAgent: 'TestAgent/1.0',
        retryNotificationService: retryService,
        maxRetries: 1,
      );

      http.Response? parsed;
      Object? thrown;

      client
          .send(http.Request('GET', Uri.parse('https://example.com')))
          .then(http.Response.fromStream)
          .then<void>((final response) => parsed = response)
          .catchError((final Object error) => thrown = error);

      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();

      expect(thrown, isNull);
      expect(parsed?.statusCode, 200);
      expect(callCount, 2);
      expect(notifications, hasLength(1));
      expect(notifications.single.attempt, 1);
      expect(notifications.single.maxAttempts, 2);

      subscription.cancel();
      retryService.dispose();
    });
  });

  test('throws when offline before sending request', () async {
    final ResilientHttpClient client = ResilientHttpClient(
      innerClient: MockClient(
        (final request) async => http.Response('ok', 200),
      ),
      networkStatusService: _FakeNetworkStatusService(NetworkStatus.offline),
      userAgent: 'TestAgent/1.0',
      enableRetry: false,
    );

    await expectLater(
      client.send(http.Request('GET', Uri.parse('https://example.com'))),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('does not retry multipart requests with transient failures', () async {
    final InMemoryRetryNotificationService retryService =
        InMemoryRetryNotificationService();
    final List<RetryNotification> notifications = <RetryNotification>[];
    final subscription = retryService.notifications.listen(notifications.add);

    final _CountingClient inner = _CountingClient(
      (final request) async => http.StreamedResponse(
        Stream<List<int>>.value(utf8.encode('server error')),
        500,
        headers: const <String, String>{'content-type': 'text/plain'},
      ),
    );

    final ResilientHttpClient client = ResilientHttpClient(
      innerClient: inner,
      networkStatusService: _FakeNetworkStatusService(NetworkStatus.online),
      userAgent: 'TestAgent/1.0',
      retryNotificationService: retryService,
      maxRetries: 1,
    );

    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse('https://example.com/upload'),
    )..fields['name'] = 'sample';

    final http.Response response = await http.Response.fromStream(
      await client.send(request),
    );

    expect(response.statusCode, 500);
    expect(inner.callCount, 1);
    expect(notifications, isEmpty);

    await subscription.cancel();
    await retryService.dispose();
  });

  test(
    '401 retry refreshes once and retries with fresh bearer token',
    () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockUser user = _MockUser();
      final _MockIdTokenResult staleToken = _MockIdTokenResult();
      final _MockIdTokenResult freshToken = _MockIdTokenResult();
      final DateTime expiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );

      when(() => auth.currentUser).thenReturn(user);
      when(() => user.uid).thenReturn('user-id');
      when(
        () => user.getIdToken(true),
      ).thenAnswer((final invocation) async => 'refreshed');
      when(() => staleToken.token).thenReturn('stale-token');
      when(() => staleToken.expirationTime).thenReturn(expiry);
      when(() => freshToken.token).thenReturn('fresh-token');
      when(() => freshToken.expirationTime).thenReturn(expiry);

      int tokenResultCalls = 0;
      when(() => user.getIdTokenResult()).thenAnswer((final invocation) async {
        tokenResultCalls += 1;
        return tokenResultCalls == 1 ? staleToken : freshToken;
      });

      final List<String?> authHeaders = <String?>[];
      final _CountingClient inner = _CountingClient((final request) async {
        authHeaders.add(request.headers['Authorization']);
        final int statusCode = authHeaders.length == 1 ? 401 : 200;
        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode('ok')),
          statusCode,
          headers: const <String, String>{'content-type': 'text/plain'},
        );
      });

      final ResilientHttpClient client = ResilientHttpClient(
        innerClient: inner,
        networkStatusService: _FakeNetworkStatusService(NetworkStatus.online),
        userAgent: 'TestAgent/1.0',
        firebaseAuth: auth,
        enableRetry: false,
      );

      final http.Response response = await http.Response.fromStream(
        await client.send(
          http.Request('GET', Uri.parse('https://example.com')),
        ),
      );

      expect(response.statusCode, 200);
      expect(inner.callCount, 2);
      expect(authHeaders, <String?>[
        'Bearer stale-token',
        'Bearer fresh-token',
      ]);
      verify(() => user.getIdToken(true)).called(1);
    },
  );

  test(
    'concurrent 401 responses share one refresh and both retries succeed',
    () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockUser user = _MockUser();
      final _MockIdTokenResult staleToken = _MockIdTokenResult();
      final _MockIdTokenResult freshToken = _MockIdTokenResult();
      final DateTime expiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );

      bool refreshed = false;
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.uid).thenReturn('user-id');
      when(() => staleToken.token).thenReturn('stale-token');
      when(() => staleToken.expirationTime).thenReturn(expiry);
      when(() => freshToken.token).thenReturn('fresh-token');
      when(() => freshToken.expirationTime).thenReturn(expiry);
      when(() => user.getIdToken(true)).thenAnswer((final invocation) async {
        refreshed = true;
        return 'refreshed';
      });
      when(() => user.getIdTokenResult()).thenAnswer((final invocation) async {
        return refreshed ? freshToken : staleToken;
      });

      final Completer<void> firstWaveBarrier = Completer<void>();
      int staleRequestCount = 0;
      final List<String?> authHeaders = <String?>[];
      final _CountingClient inner = _CountingClient((final request) async {
        final String? authHeader = request.headers['Authorization'];
        authHeaders.add(authHeader);

        if (authHeader == 'Bearer stale-token') {
          staleRequestCount += 1;
          if (staleRequestCount == 2 && !firstWaveBarrier.isCompleted) {
            firstWaveBarrier.complete();
          }
          await firstWaveBarrier.future;
          return http.StreamedResponse(
            Stream<List<int>>.value(utf8.encode('unauthorized')),
            401,
            headers: const <String, String>{'content-type': 'text/plain'},
          );
        }

        return http.StreamedResponse(
          Stream<List<int>>.value(utf8.encode('ok')),
          200,
          headers: const <String, String>{'content-type': 'text/plain'},
        );
      });

      final ResilientHttpClient client = ResilientHttpClient(
        innerClient: inner,
        networkStatusService: _FakeNetworkStatusService(NetworkStatus.online),
        userAgent: 'TestAgent/1.0',
        firebaseAuth: auth,
        enableRetry: false,
      );

      final Future<http.Response> firstResponseFuture = client
          .send(http.Request('GET', Uri.parse('https://example.com/a')))
          .then(http.Response.fromStream);
      final Future<http.Response> secondResponseFuture = client
          .send(http.Request('GET', Uri.parse('https://example.com/b')))
          .then(http.Response.fromStream);

      final List<http.Response> responses = await Future.wait(
        <Future<http.Response>>[firstResponseFuture, secondResponseFuture],
      );

      expect(responses.map((final response) => response.statusCode), <int>[
        200,
        200,
      ]);
      expect(staleRequestCount, 2);
      expect(inner.callCount, 4);
      expect(
        authHeaders.where((final header) => header == 'Bearer fresh-token'),
        hasLength(2),
      );
      verify(() => user.getIdToken(true)).called(1);
    },
  );
}
