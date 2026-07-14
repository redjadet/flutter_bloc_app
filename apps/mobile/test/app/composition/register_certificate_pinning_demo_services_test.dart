import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/app/composition/features/register_certificate_pinning_demo_services.dart';
import 'package:flutter_bloc_app/app/composition/features/register_http_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/secure_probe_repository.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/reset_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/select_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/trigger_secure_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

class _TestNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

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

  test('registerCertificatePinningDemoServices wires probe use cases', () {
    getIt.registerSingleton<NetworkStatusService>(_TestNetworkStatusService());
    getIt.registerSingleton<TokenRepository>(InMemoryTokenRepository());
    registerHttpServices();
    registerCertificatePinningDemoServices();

    expect(getIt<CertificatePinningConfig>().mode, CertificatePinningMode.disabled);
    expect(getIt<CertificatePinValidator>(), isA<DisabledCertificatePinValidator>());
    expect(getIt<MockCertificatePinValidator>(), isA<MockCertificatePinValidator>());
    expect(getIt<SecureProbeRepository>(), isA<SecureProbeRepository>());
    expect(getIt<TriggerSecureProbe>(), isA<TriggerSecureProbe>());
    expect(getIt<SelectMockScenario>(), isA<SelectMockScenario>());
    expect(getIt<ResetMockScenario>(), isA<ResetMockScenario>());
    expect(getIt.isRegistered<Dio>(), isTrue);
  });
}
