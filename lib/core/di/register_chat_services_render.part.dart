part of 'register_chat_services.dart';

bool _chatRenderOrchestrationRunnable() {
  if (getIt.isRegistered<BackendAvailability>() &&
      getIt<BackendAvailability>().webNoBackendMode) {
    return false;
  }
  if (!SecretConfig.chatRenderDemoEnabled) {
    return false;
  }
  final String base = SecretConfig.chatRenderDemoBaseUrl.trim();
  if (base.isEmpty) {
    return false;
  }
  if (kReleaseMode) {
    final Uri? parsed = Uri.tryParse(base);
    if (parsed == null || parsed.scheme != 'https') {
      return false;
    }
  }
  if (!getIt.isRegistered<FirebaseAuth>()) {
    return false;
  }
  final bool hasUser = getIt<FirebaseAuth>().currentUser != null;
  if (kDebugMode) {
    AppLogger.info(
      'Chat: orchestration_runnable_check '
      'enabled=${SecretConfig.chatRenderDemoEnabled} '
      'isFastApiCloud=${base.contains('fastapicloud')} '
      'baseUrlChars=${base.length} '
      'firebaseUser=$hasUser',
    );
  }
  return hasUser;
}

void _registerChatRenderOrchestrationServices() {
  if (!getIt.isRegistered<Dio>(instanceName: _renderChatDioName)) {
    getIt.registerLazySingleton<Dio>(
      () {
        final String raw = SecretConfig.chatRenderDemoBaseUrl.trim();
        return createRenderChatDio(
          baseUrl: raw.isEmpty ? 'http://127.0.0.1' : raw,
        );
      },
      instanceName: _renderChatDioName,
      dispose: (dio) => dio.close(),
    );
  }
  registerLazySingletonIfAbsent<RenderCallerAuthHeaderProvider>(
    () => DefaultRenderCallerAuthHeaderProvider(() => getIt<FirebaseAuth>()),
  );
  registerLazySingletonIfAbsent<RenderOrchestrationHfTokenProvider>(
    () {
      final RenderOrchestrationHfTokenProvider provider =
          LayeredRenderOrchestrationHfTokenProvider(
            runtime: getIt<AppRuntimeConfig>(),
            remoteTokenPort: getIt<RenderOrchestrationRemoteTokenPort>(),
            storage: SecretConfig.storage ?? createDefaultSecretStorage(),
            firebaseAuth:
                getIt.isRegistered<FirebaseAuth>() && Firebase.apps.isNotEmpty
                ? getIt<FirebaseAuth>()
                : null,
          );
      if (getIt.isRegistered<SessionLifecycleCoordinator>()) {
        getIt<SessionLifecycleCoordinator>().bindHfTokenProvider(provider);
      }
      return provider;
    },
  );
  registerLazySingletonIfAbsent<RenderFastApiChatRepository>(
    () => RenderFastApiChatRepository(
      dio: getIt<Dio>(instanceName: _renderChatDioName),
      payloadBuilder: getIt<HuggingFacePayloadBuilder>(),
      responseParser: getIt<HuggingFaceResponseParser>(),
      callerAuth: getIt<RenderCallerAuthHeaderProvider>(),
      hfTokenProvider: getIt<RenderOrchestrationHfTokenProvider>(),
      isRunnable: _chatRenderOrchestrationRunnable,
    ),
  );
  registerLazySingletonIfAbsent<DemoFirstChatRepository>(
    () => DemoFirstChatRepository(
      renderRepository: getIt<RenderFastApiChatRepository>(),
      compositeRepository: getIt<CompositeChatRepository>(),
      isRenderAttemptedFirst: _chatRenderOrchestrationRunnable,
      isRenderStrict: () => SecretConfig.chatRenderDemoStrict,
    ),
  );
}
