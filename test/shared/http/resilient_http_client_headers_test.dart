import 'dart:async';

import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

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

class _RecordingClient extends http.BaseClient {
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(final http.BaseRequest request) async {
    lastRequest = request;
    return http.StreamedResponse(
      Stream<List<int>>.value(<int>[]),
      200,
      request: request,
    );
  }
}

void main() {
  test('injects Accept-Encoding=gzip and does not advertise brotli', () async {
    final _RecordingClient inner = _RecordingClient();
    final ResilientHttpClient client = ResilientHttpClient(
      innerClient: inner,
      networkStatusService: _FakeNetworkStatusService(NetworkStatus.online),
      userAgent: 'TestAgent/1.0',
      enableTelemetry: false,
      enableRetry: false,
    );

    await client.send(http.Request('GET', Uri.parse('https://example.com')));

    final http.BaseRequest recorded = inner.lastRequest!;
    expect(recorded.headers['Accept-Encoding'], isNotNull);
    expect(recorded.headers['Accept-Encoding']!.toLowerCase(), equals('gzip'));
    expect(
      recorded.headers['Accept-Encoding']!.toLowerCase().contains('br'),
      isFalse,
    );
  });

  test('does not override caller-provided Accept-Encoding', () async {
    final _RecordingClient inner = _RecordingClient();
    final ResilientHttpClient client = ResilientHttpClient(
      innerClient: inner,
      networkStatusService: _FakeNetworkStatusService(NetworkStatus.online),
      userAgent: 'TestAgent/1.0',
      enableTelemetry: false,
      enableRetry: false,
    );

    final http.Request request = http.Request(
      'GET',
      Uri.parse('https://example.com'),
    )..headers['Accept-Encoding'] = 'identity';

    await client.send(request);

    final http.BaseRequest recorded = inner.lastRequest!;
    expect(recorded.headers['Accept-Encoding'], equals('identity'));
  });

  test('does not override existing Authorization header', () async {
    final _RecordingClient inner = _RecordingClient();
    final ResilientHttpClient client = ResilientHttpClient(
      innerClient: inner,
      networkStatusService: _FakeNetworkStatusService(NetworkStatus.online),
      userAgent: 'TestAgent/1.0',
      enableTelemetry: false,
      enableRetry: false,
    );

    final http.Request request = http.Request(
      'GET',
      Uri.parse('https://example.com'),
    )..headers['Authorization'] = 'Bearer preset-token';

    await client.send(request);

    final http.BaseRequest recorded = inner.lastRequest!;
    expect(recorded.headers['Authorization'], equals('Bearer preset-token'));
  });
}
