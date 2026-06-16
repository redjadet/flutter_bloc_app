part of '../injector_registrations.dart';

Future<void> registerFeatureServices() async {
  _registerCounterRepository();
  registerAuthServices();
  registerRemoteConfigServices();
  _registerSupabaseConfigServices();
  registerSupabaseServices();
  _registerTimerAndNetworkStatus();
  registerHttpServices();
  registerChartServices();
  registerCalculatorServices();
  registerGraphqlServices();
  registerChatServices();
  registerCaseStudyDemoServices();
  _registerSettingsServices();
  _registerDeepLinkServices();
  _registerWebSocketServices();
  _registerMapServices();
  registerProfileServices();
  registerSearchServices();
  registerTodoServices();
  registerGenUiServices();
  registerWalletConnectAuthServices();
  registerPlaylearnServices();
}

void _registerCounterRepository() {
  registerLazySingletonIfAbsent<CounterRepository>(createCounterRepository);
}

void _registerSupabaseConfigServices() {
  final FirebaseAuth? firebaseAuth = _registeredFirebaseAuthOrNull();

  registerLazySingletonIfAbsent<SupabaseConfigProvider>(
    () => SupabaseConfigProvider(
      auth: firebaseAuth,
      remoteConfig: getIt<RemoteConfigService>(),
    ),
  );
  if (firebaseAuth == null) {
    return;
  }

  registerLazySingletonIfAbsent<SupabaseConfigCoordinator>(
    () => SupabaseConfigCoordinator(
      auth: firebaseAuth,
      provider: getIt<SupabaseConfigProvider>(),
    ),
    dispose: (final coordinator) => coordinator.dispose(),
  );
}

FirebaseAuth? _registeredFirebaseAuthOrNull() {
  if (!FirebaseBootstrapService.isFirebaseInitialized) {
    return null;
  }

  try {
    return getIt<FirebaseAuth>();
  } on Object {
    return null;
  }
}

/// `registerHttpServices` builds `Dio` with `NetworkStatusService`; chart setup
/// can eagerly resolve HTTP clients, so network status must exist first.
void _registerTimerAndNetworkStatus() {
  registerLazySingletonIfAbsent<TimerService>(DefaultTimerService.new);
  registerLazySingletonIfAbsent<NetworkStatusService>(
    () => ConnectivityNetworkStatusService(
      timerService: getIt<TimerService>(),
    ),
    dispose: (final service) => service.dispose(),
  );
}

void _registerSettingsServices() {
  registerLazySingletonIfAbsent<LocaleRepository>(
    () => HiveLocaleRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<ThemeRepository>(
    () => HiveThemeRepository(hiveService: getIt<HiveService>()),
  );
  registerLazySingletonIfAbsent<AppInfoRepository>(
    () => const PackageInfoAppInfoRepository(),
  );
}

void _registerDeepLinkServices() {
  registerLazySingletonIfAbsent<DeepLinkParser>(() => const DeepLinkParser());
  registerLazySingletonIfAbsent<DeepLinkService>(AppLinksDeepLinkService.new);
}

void _registerWebSocketServices() {
  registerLazySingletonIfAbsent<WebsocketRepository>(
    EchoWebsocketRepository.new,
    dispose: (final repository) => repository.dispose(),
  );
}

void _registerMapServices() {
  registerLazySingletonIfAbsent<MapLocationRepository>(
    () => const SampleMapLocationRepository(),
  );
}
