import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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
}
