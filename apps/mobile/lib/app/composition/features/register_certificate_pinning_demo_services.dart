import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/data/secure_probe_repository_impl.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/secure_probe_repository.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/reset_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/select_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/trigger_secure_probe.dart';
import 'package:networking/networking.dart';

void registerCertificatePinningDemoServices() {
  registerLazySingletonIfAbsent<MockCertificatePinValidator>(() {
    final CertificatePinningConfig config = getIt<CertificatePinningConfig>();
    return MockCertificatePinValidator(
      scenarioController: getIt<MockCertificateScenarioController>(),
      validationTimeout: config.validationTimeout,
      logger: getIt<CertificatePinningLogger>(),
      mode: config.mode == CertificatePinningMode.mockFailure
          ? CertificatePinningMode.mockFailure
          : CertificatePinningMode.mockSuccess,
    );
  });

  registerLazySingletonIfAbsent<SecureProbeRepository>(
    () => SecureProbeRepositoryImpl(
      config: getIt<CertificatePinningConfig>(),
      mockValidator: getIt<MockCertificatePinValidator>(),
      dio: getIt<Dio>(),
    ),
  );

  registerLazySingletonIfAbsent<TriggerSecureProbe>(
    () => TriggerSecureProbe(getIt<SecureProbeRepository>()),
  );
  registerLazySingletonIfAbsent<SelectMockScenario>(
    () => SelectMockScenario(getIt<MockCertificateScenarioController>()),
  );
  registerLazySingletonIfAbsent<ResetMockScenario>(
    () => ResetMockScenario(getIt<MockCertificateScenarioController>()),
  );
}
