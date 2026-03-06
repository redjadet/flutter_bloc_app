import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/register_http_services.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  group('registerHttpServices', () {
    test('builds Dio that blocks offline requests', () async {
      final _TestNetworkStatusService networkStatusService =
          _TestNetworkStatusService(NetworkStatus.offline);
      getIt.registerSingleton<NetworkStatusService>(networkStatusService);

      registerHttpServices();

      final Dio dio = getIt<Dio>();

      await expectLater(
        dio.get<String>('https://example.com/'),
        throwsA(isA<DioException>()),
      );

      expect(networkStatusService.statusChecks, 1);
    });

    test('registers Dio with standard headers', () async {
      final _TestNetworkStatusService networkStatusService =
          _TestNetworkStatusService(NetworkStatus.online);
      getIt.registerSingleton<NetworkStatusService>(networkStatusService);

      registerHttpServices();

      final Dio dio = getIt<Dio>();

      expect(
        dio.options.headers['User-Agent'],
        'FlutterBlocApp/${getAppVersion()}',
      );
      expect(dio.options.headers['Accept'], 'application/json, */*');
      expect(dio.options.headers['Accept-Encoding'], 'gzip');
    });

    test('allows repositories to handle non-success HTTP statuses', () async {
      final _TestNetworkStatusService networkStatusService =
          _TestNetworkStatusService(NetworkStatus.online);
      getIt.registerSingleton<NetworkStatusService>(networkStatusService);

      registerHttpServices();

      final Dio dio = getIt<Dio>();
      final bool Function(int?) validateStatus = dio.options.validateStatus;

      expect(validateStatus(200), isTrue);
      expect(validateStatus(404), isTrue);
      expect(validateStatus(500), isTrue);
    });
  });
}
