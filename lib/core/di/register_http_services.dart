import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/core/auth/token_repository.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';
import 'package:flutter_bloc_app/shared/http/app_dio.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';

void registerHttpServices() {
  registerLazySingletonIfAbsent<RetryNotificationService>(
    InMemoryRetryNotificationService.new,
    dispose: (final service) => service.dispose(),
  );
  registerLazySingletonIfAbsent<TokenRepository>(InMemoryTokenRepository.new);

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
