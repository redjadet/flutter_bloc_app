import 'dart:async';

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_http_services.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';
import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _TestNetworkStatusService implements NetworkStatusService {
  _TestNetworkStatusService(this._status);

  NetworkStatus _status;
  int statusChecks = 0;

  set status(final NetworkStatus next) => _status = next;

  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async {
    statusChecks += 1;
    return _status;
  }

  @override
  Future<void> dispose() async {}
}

class _RecordingHttpClient extends http.BaseClient {
  _RecordingHttpClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;
  http.BaseRequest? lastRequest;
  int sendCount = 0;

  @override
  Future<http.StreamedResponse> send(final http.BaseRequest request) {
    sendCount += 1;
    lastRequest = request;
    return _handler(request);
  }
}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('registerHttpServices', () {
    test('builds ResilientHttpClient that blocks offline requests', () async {
      final _TestNetworkStatusService networkStatusService =
          _TestNetworkStatusService(NetworkStatus.offline);
      getIt.registerSingleton<NetworkStatusService>(networkStatusService);

      final _RecordingHttpClient innerClient = _RecordingHttpClient(
        (final _) async =>
            http.StreamedResponse(Stream.value(const <int>[]), 200),
      );
      getIt.registerSingleton<http.Client>(innerClient);

      registerHttpServices();

      final ResilientHttpClient client = getIt<ResilientHttpClient>();
      final http.BaseRequest request = http.Request(
        'GET',
        Uri.parse('https://example.com'),
      );

      await expectLater(
        client.send(request),
        throwsA(isA<http.ClientException>()),
      );

      expect(networkStatusService.statusChecks, 1);
      expect(innerClient.sendCount, 0);
    });

    test('injects standard headers when online', () async {
      final _TestNetworkStatusService networkStatusService =
          _TestNetworkStatusService(NetworkStatus.online);
      getIt.registerSingleton<NetworkStatusService>(networkStatusService);

      final Completer<void> responseCompleted = Completer<void>();
      final _RecordingHttpClient innerClient = _RecordingHttpClient((
        final _,
      ) async {
        responseCompleted.complete();
        return http.StreamedResponse(Stream.value(const <int>[]), 200);
      });
      getIt.registerSingleton<http.Client>(innerClient);

      registerHttpServices();

      final ResilientHttpClient client = getIt<ResilientHttpClient>();
      final http.BaseRequest request = http.Request(
        'GET',
        Uri.parse('https://example.com'),
      );

      await client.send(request);
      await responseCompleted.future;

      final http.BaseRequest recorded = innerClient.lastRequest!;
      expect(
        recorded.headers['User-Agent'],
        'FlutterBlocApp/${getAppVersion()}',
      );
      expect(recorded.headers['Accept'], 'application/json, */*');
      expect(recorded.headers['Accept-Encoding'], 'gzip');
      expect(networkStatusService.statusChecks, 1);
      expect(innerClient.sendCount, 1);
    });
  });
}
