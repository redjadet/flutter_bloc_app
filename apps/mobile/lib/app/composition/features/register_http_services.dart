import 'dart:async';

import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/config/certificate_pinning_config_factory.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/http/app_dio.dart';
import 'package:flutter_bloc_app/app/http/auth/auth_token_manager.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';
import 'package:networking/networking.dart';

void registerHttpServices() {
  registerLazySingletonIfAbsent<RetryNotificationService>(
    InMemoryRetryNotificationService.new,
    dispose: (final service) => service.dispose(),
  );

  registerLazySingletonIfAbsent<CertificatePinningConfig>(() {
    return CertificatePinningConfigFactory.fromBootstrap(
      isProd: FlavorManager.I.isProd,
      isReleaseMode: kReleaseMode,
    );
  });

  registerLazySingletonIfAbsent<MockCertificateScenarioController>(
    MockCertificateScenarioController.new,
  );

  registerLazySingletonIfAbsent<CertificatePinningLogger>(() {
    final CertificatePinningConfig config = getIt<CertificatePinningConfig>();
    return CertificatePinningLogger(
      enableVerboseLogging: config.enableVerboseLogging,
    );
  });

  registerLazySingletonIfAbsent<CertificatePinValidator>(() {
    final CertificatePinningConfig config = getIt<CertificatePinningConfig>();
    final CertificatePinningLogger logger = getIt<CertificatePinningLogger>();
    final MockCertificateScenarioController scenarios = getIt<MockCertificateScenarioController>();
    switch (config.mode) {
      case CertificatePinningMode.disabled:
        return const DisabledCertificatePinValidator();
      case CertificatePinningMode.mockSuccess:
        return MockCertificatePinValidator(
          scenarioController: scenarios,
          validationTimeout: config.validationTimeout,
          logger: logger,
        );
      case CertificatePinningMode.mockFailure:
        if (scenarios.scenario == MockCertificateScenario.validPrimaryPin) {
          scenarios.setScenario(MockCertificateScenario.invalidPin);
        }
        return MockCertificatePinValidator(
          scenarioController: scenarios,
          validationTimeout: config.validationTimeout,
          logger: logger,
          mode: CertificatePinningMode.mockFailure,
        );
      case CertificatePinningMode.real:
        return RealCertificatePinValidator(config: config, logger: logger);
    }
  });

  registerLazySingletonIfAbsent<AuthTokenManager>(() {
    final AuthTokenManager manager = AuthTokenManager(
      firebaseAuth: getIt.isRegistered<FirebaseAuth>()
          ? createRemoteRepositoryOrNull<FirebaseAuth>(
              context: 'FirebaseAuth',
              factory: () => getIt<FirebaseAuth>(),
            )
          : null,
      tokenRepository: getIt<TokenRepository>(),
    );
    unawaited(manager.hydrateFromPersistentSession());
    return manager;
  });

  registerLazySingletonIfAbsent<Dio>(() {
    final Dio dio = createAppDio(
      networkStatusService: getIt<NetworkStatusService>(),
      userAgent: 'FlutterBlocApp/${getAppVersion()}',
      firebaseAuth: getIt.isRegistered<FirebaseAuth>()
          ? createRemoteRepositoryOrNull<FirebaseAuth>(
              context: 'FirebaseAuth',
              factory: () => getIt<FirebaseAuth>(),
            )
          : null,
      authTokenManager: getIt<AuthTokenManager>(),
      sessionCoordinator: getIt.isRegistered<SessionLifecycleCoordinator>()
          ? getIt<SessionLifecycleCoordinator>()
          : null,
      retryNotificationService: getIt<RetryNotificationService>(),
    );
    applyCertificatePinning(
      dio,
      config: getIt<CertificatePinningConfig>(),
      validator: getIt<CertificatePinValidator>(),
    );
    if (getIt.isRegistered<SessionLifecycleCoordinator>()) {
      getIt<SessionLifecycleCoordinator>().bindTokenRepository(
        getIt<TokenRepository>(),
      );
      getIt<SessionLifecycleCoordinator>().bindAuthTokenManager(
        getIt<AuthTokenManager>(),
      );
    }
    return dio;
  }, dispose: (final dio) => dio.close());
}
