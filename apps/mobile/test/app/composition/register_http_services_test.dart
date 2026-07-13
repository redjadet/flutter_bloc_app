import 'package:dio/dio.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/features/register_auth_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_http_services.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';
import 'package:flutter_bloc_app/app/http/auth/auth_token_manager.dart';
import 'package:networking/networking.dart';
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
    void registerHttpTestPrereqs({required final NetworkStatus initialStatus}) {
      getIt.registerSingleton<NetworkStatusService>(
        _TestNetworkStatusService(initialStatus),
      );
      getIt.registerSingleton<TokenRepository>(InMemoryTokenRepository());
    }

    test('builds Dio that blocks offline requests', () async {
      registerHttpTestPrereqs(initialStatus: NetworkStatus.offline);
      final _TestNetworkStatusService networkStatusService =
          getIt<NetworkStatusService>() as _TestNetworkStatusService;

      registerHttpServices();

      final Dio dio = getIt<Dio>();

      await expectLater(
        dio.get<String>('https://example.com/'),
        throwsA(isA<DioException>()),
      );

      expect(networkStatusService.statusChecks, 1);
    });

    test('registers Dio with standard headers', () async {
      registerHttpTestPrereqs(initialStatus: NetworkStatus.online);

      registerHttpServices();

      final Dio dio = getIt<Dio>();

      expect(
        dio.options.headers['User-Agent'],
        'FlutterBlocApp/${getAppVersion()}',
      );
      expect(dio.options.headers['Accept'], 'application/json, */*');
      expect(dio.options.headers['Accept-Encoding'], 'gzip');
    });

    test(
      'registers AuthTokenManager singleton and binds coordinator',
      () async {
        final _TestNetworkStatusService networkStatusService =
            _TestNetworkStatusService(NetworkStatus.online);
        getIt.registerSingleton<NetworkStatusService>(networkStatusService);
        registerAuthServices();

        registerHttpServices();

        expect(getIt<AuthTokenManager>(), same(getIt<AuthTokenManager>()));
        expect(getIt<TokenRepository>(), same(getIt<TokenRepository>()));
        final Dio dio = getIt<Dio>();
        expect(dio.options.headers['User-Agent'], isNotEmpty);
      },
    );

    test('allows repositories to handle non-success HTTP statuses', () async {
      registerHttpTestPrereqs(initialStatus: NetworkStatus.online);

      registerHttpServices();

      final Dio dio = getIt<Dio>();
      final bool Function(int?) validateStatus = dio.options.validateStatus;

      expect(validateStatus(200), isTrue);
      expect(validateStatus(404), isTrue);
      expect(validateStatus(500), isTrue);
    });

    test('defaults certificate pinning to disabled validator', () {
      registerHttpTestPrereqs(initialStatus: NetworkStatus.online);
      registerHttpServices();

      final CertificatePinningConfig config = getIt<CertificatePinningConfig>();
      expect(config.mode, CertificatePinningMode.disabled);
      expect(config.pinHashKind, CertificatePinHashKind.spki);
      expect(
        getIt<CertificatePinValidator>(),
        isA<DisabledCertificatePinValidator>(),
      );
      expect(getIt.isRegistered<CertificatePinningLogger>(), isTrue);
      expect(getIt.isRegistered<MockCertificateScenarioController>(), isTrue);
    });
  });
}
