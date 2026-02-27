import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/http/resilient_http_client_extensions.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _AlwaysOnlineNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream =>
      Stream<NetworkStatus>.value(NetworkStatus.online);

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _FakeResilientHttpClient extends ResilientHttpClient {
  _FakeResilientHttpClient(this._handler)
    : super(
        innerClient: http.Client(),
        networkStatusService: _AlwaysOnlineNetworkStatusService(),
        userAgent: 'TestAgent/1.0',
        enableTelemetry: false,
        enableRetry: false,
      );

  final Future<http.StreamedResponse> Function(http.BaseRequest) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _handler(request);
  }
}

http.StreamedResponse _response(
  int statusCode, {
  String body = '',
  Map<String, String>? headers,
}) {
  return http.StreamedResponse(
    Stream<List<int>>.value(utf8.encode(body)),
    statusCode,
    headers: headers ?? const <String, String>{},
  );
}

void main() {
  group('ResilientHttpClientExtensions', () {
    test('getMapped returns response on success', () async {
      final _FakeResilientHttpClient client = _FakeResilientHttpClient(
        (final request) async => _response(200, body: 'ok'),
      );

      final http.Response response = await client.getMapped(
        Uri.parse('https://example.com'),
      );

      expect(response.statusCode, 200);
      expect(response.body, 'ok');
    });

    test('getMapped throws HttpRequestFailure for status code', () async {
      final _FakeResilientHttpClient client = _FakeResilientHttpClient(
        (final request) async => _response(404, body: 'not found'),
      );

      await expectLater(
        client.getMapped(Uri.parse('https://example.com')),
        throwsA(
          isA<HttpRequestFailure>()
              .having(
                (final HttpRequestFailure e) => e.statusCode,
                'statusCode',
                404,
              )
              .having(
                (final HttpRequestFailure e) => e.message,
                'message',
                'The requested resource was not found.',
              ),
        ),
      );
    });

    test(
      'getMapped captures Retry-After seconds for retryable failures',
      () async {
        final _FakeResilientHttpClient client = _FakeResilientHttpClient(
          (final request) async =>
              _response(429, headers: <String, String>{'retry-after': '30'}),
        );

        await expectLater(
          client.getMapped(Uri.parse('https://example.com')),
          throwsA(
            isA<HttpRequestFailure>()
                .having(
                  (final HttpRequestFailure e) => e.statusCode,
                  'statusCode',
                  429,
                )
                .having(
                  (final HttpRequestFailure e) => e.retryAfterSeconds,
                  'retryAfterSeconds',
                  30,
                ),
          ),
        );
      },
    );

    test('getMapped parses Retry-After date values', () async {
      final DateTime retryAt = DateTime.now().toUtc().add(
        const Duration(seconds: 90),
      );
      final _FakeResilientHttpClient client = _FakeResilientHttpClient(
        (final request) async => _response(
          503,
          headers: <String, String>{'retry-after': HttpDate.format(retryAt)},
        ),
      );

      await expectLater(
        client.getMapped(Uri.parse('https://example.com')),
        throwsA(
          isA<HttpRequestFailure>().having(
            (final HttpRequestFailure e) => e.retryAfterSeconds,
            'retryAfterSeconds',
            inInclusiveRange(1, 90),
          ),
        ),
      );
    });

    test('postMapped maps timeout to client exception', () async {
      final _FakeResilientHttpClient client = _FakeResilientHttpClient(
        (final request) async => throw TimeoutException('timeout'),
      );

      await expectLater(
        client.postMapped(Uri.parse('https://example.com')),
        throwsA(
          isA<http.ClientException>().having(
            (final http.ClientException error) => error.message,
            'message',
            'Request timed out',
          ),
        ),
      );
    });
  });
}
