part of 'routes_demos.dart';

List<RouteBase> createDemoRoutesHead(DemoRouteFactory factory) => <RouteBase>[
  GoRoute(
    path: AppRoutes.chatPath,
    name: AppRoutes.chat,
    builder: (context, state) {
      final BackendAvailability availability = factory.backendAvailability;
      return factory._withChatSupabaseSessionGate(
        state: state,
        availability: availability,
        child: BlocProviderHelpers.withAsyncInit<ChatSyncStatusCubit>(
          create: () => ChatSyncStatusCubit(
            pendingRepository: factory.pendingSyncRepository,
          ),
          init: (cubit) => cubit.refresh(),
          child: BlocProviderHelpers.withAsyncInit<ChatCubit>(
            create: factory._createChatCubit,
            init: (cubit) => cubit.loadHistory(),
            child: factory._listenBackendAvailability(
              (live) => ChatPage(
                errorNotificationService: factory.errorNotificationService,
                showBackendDisabledBanner: live.showChatBackendDisabledBanner,
                renderTransportDemoStrict: SecretConfig.chatRenderDemoStrict,
                chatRenderDemoBaseUrl: SecretConfig.chatRenderDemoBaseUrl,
              ),
            ),
          ),
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.chatListPath,
    name: AppRoutes.chatList,
    builder: (context, state) {
      final BackendAvailability availability = factory.backendAvailability;
      return factory._withChatSupabaseSessionGate(
        state: state,
        availability: availability,
        child: BlocProviderHelpers.withAsyncInit<ChatSyncStatusCubit>(
          create: () => ChatSyncStatusCubit(
            pendingRepository: factory.pendingSyncRepository,
          ),
          init: (cubit) => cubit.refresh(),
          child: factory._listenBackendAvailability(
            (live) => ChatListPage(
              repository: factory.chatListRepository,
              chatRepository: factory.chatRepository,
              historyRepository: factory.chatHistoryRepository,
              renderOrchestrationHfTokenProvider:
                  factory.renderOrchestrationHfTokenProvider,
              authSessionPort: factory.chatAuthSessionPort,
              renderOrchestrationDiagnostics:
                  factory.chatRenderOrchestrationDiagnosticsPort,
              errorNotificationService: factory.errorNotificationService,
              showBackendDisabledBanner: live.showChatBackendDisabledBanner,
              renderTransportDemoStrict: SecretConfig.chatRenderDemoStrict,
              chatRenderDemoBaseUrl: SecretConfig.chatRenderDemoBaseUrl,
              initialHuggingfaceModel: SecretConfig.huggingfaceModel,
            ),
          ),
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.genuiDemoPath,
    name: AppRoutes.genuiDemo,
    builder: (context, state) {
      final apiKey = SecretConfig.geminiApiKey;
      if (apiKey == null || apiKey.isEmpty) {
        return CommonPageLayout(
          title: context.l10n.genuiDemoPageTitle,
          body: CommonErrorView(message: context.l10n.genuiDemoNoApiKey),
        );
      }
      return BlocProviderHelpers.withAsyncInit<GenUiDemoCubit>(
        create: () => GenUiDemoCubit(agent: factory.genUiDemoAgent),
        init: (cubit) => cubit.initialize(),
        child: const GenUiDemoPage(),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.playlearnPath,
    name: AppRoutes.playlearn,
    builder: (context, state) => PlaylearnPage(
      repository: factory.vocabularyRepository,
      audioService: factory.createAudioPlaybackService(),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: 'vocabulary/:topicId',
        name: AppRoutes.playlearnVocabulary,
        builder: (context, state) {
          final topicId = state.pathParameters['topicId'] ?? '';
          return VocabularyListPage(
            topicId: topicId,
            repository: factory.vocabularyRepository,
            audioService: factory.createAudioPlaybackService(),
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.igamingDemoPath,
    name: AppRoutes.igamingDemo,
    builder: (context, state) {
      final l10n = context.l10n;
      return BlocProviderHelpers.withAsyncInit<LobbyCubit>(
        create: () =>
            LobbyCubit(repository: factory.demoBalanceRepository, l10n: l10n),
        init: (cubit) => cubit.loadBalance(),
        child: const LobbyPage(),
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: 'game',
        name: AppRoutes.igamingDemoGame,
        builder: (context, state) {
          final l10n = context.l10n;
          return BlocProviderHelpers.withAsyncInit<GameCubit>(
            create: () => GameCubit(
              balanceRepository: factory.demoBalanceRepository,
              timerService: factory.timerService,
              l10n: l10n,
            ),
            init: (cubit) => cubit.loadBalance(),
            child: const GamePage(),
          );
        },
      ),
    ],
  ),
];

List<RouteBase> createDemoRoutesTail(DemoRouteFactory factory) => <RouteBase>[
  GoRoute(
    path: AppRoutes.fcmDemoPath,
    name: AppRoutes.fcmDemo,
    builder: (context, state) =>
        BlocProviderHelpers.withAsyncInit<FcmDemoCubit>(
          create: () => FcmDemoCubit(
            messaging: factory.fcmMessagingService,
            coordinator: factory.backgroundSyncCoordinator,
          ),
          init: (cubit) => cubit.initialize(),
          child: const FcmDemoPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.productionReadinessPath,
    name: AppRoutes.productionReadiness,
    builder: (context, state) {
      final FcmSimulationController? simulation =
          factory.fcmSimulationController;
      return BlocProviderHelpers.withAsyncInit<ProductionReadinessCubit>(
        create: () {
          final bool firebaseReady =
              FirebaseBootstrapService.isFirebaseInitialized;
          return ProductionReadinessCubit(
            remoteConfig: factory.remoteConfigService,
            consentRepository: factory.analyticsConsentRepository,
            analytics: factory.productAnalytics,
            memoryAnalytics: factory.memoryAnalytics,
            messaging: factory.fcmMessagingService,
            frameMonitor: factory.frameTimingMonitor,
            simulationController: simulation,
            fcmMode: factory.fcmDemoMode,
            recordNonFatal: firebaseReady
                ? FirebaseCrashlyticsBootstrap
                      .recordProductionReadinessTestNonFatal
                : null,
          );
        },
        init: (cubit) => cubit.initialize(),
        child: ProductionReadinessPage(
          showSimulatedNotificationButton: simulation != null,
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.iotDemoPath,
    name: AppRoutes.iotDemo,
    builder: (context, state) {
      // Gate/policy once; listen only around hub so deferred ticks do not
      // recreate IotDemoCubit.
      final BackendAvailability availability = factory.backendAvailability;
      final Widget hub = BlocProviderHelpers.withAsyncInit<IotDemoCubit>(
        create: () => IotDemoCubit(repository: factory.iotDemoRepository),
        init: (cubit) => cubit.initialize(),
        child: factory._listenBackendAvailability(
          (live) => IotDemoHubPage(
            showBackendDisabledBanner: live.showIotCloudBackendDisabledBanner,
            createIotBleCubit: factory.createIotBleCubit,
          ),
        ),
      );
      if (availability.webNoBackendMode) {
        return hub;
      }
      return IotDemoAuthGate(
        isSupabaseInitialized: SupabaseBootstrapService.isSupabaseInitialized,
        getCurrentUser: () => factory.supabaseAuthRepository.currentUser,
        authStateChanges: factory.supabaseAuthRepository.authStateChanges,
        counterPath: AppRoutes.counterPath,
        supabaseAuthPath: AppRoutes.supabaseAuthPath,
        redirectReturnPath: AppRoutes.iotDemoPath,
        child: hub,
      );
    },
  ),
  GoRoute(
    path: AppRoutes.iapDemoPath,
    name: AppRoutes.iapDemo,
    builder: (context, state) =>
        BlocProviderHelpers.withAsyncInit<InAppPurchaseDemoCubit>(
          create: () {
            final fake = factory.createFakeInAppPurchaseRepository();
            final real = factory.createFlutterInAppPurchaseRepository();
            return InAppPurchaseDemoCubit(
              fakeRepository: fake,
              realRepository: real,
              fakeOutcomeControls: fake,
              realDemoControls: real,
            );
          },
          init: (cubit) => cubit.initialize(),
          child: const InAppPurchaseDemoPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.aiDecisionDemoPath,
    name: AppRoutes.aiDecisionDemo,
    builder: (context, state) =>
        BlocProviderHelpers.withAsyncInit<AiDecisionCubit>(
          create: () =>
              AiDecisionCubit(repository: factory.aiDecisionRepository),
          init: (cubit) => cubit.loadQueue(),
          child: const AiDecisionDemoPage(),
        ),
  ),
  createEventBusDemoRoute(factory),
  createSocialFeedDemoRoute(factory),
  createOnlineTherapyDemoRoute(factory.onlineTherapyDemoRouteFactory),
  createStaffAppDemoShellRoute(factory.staffAppDemoRouteFactory),
  createCaseStudyDemoShellRoute(factory.caseStudyDemoRouteFactory),
  createNativePlatformShowcaseRoute(factory),
  createCertificatePinningDemoRoute(factory.certificatePinningDemoRouteFactory),
];

RouteBase createSocialFeedDemoRoute(DemoRouteFactory factory) => GoRoute(
  path: AppRoutes.socialFeedDemoPath,
  name: AppRoutes.socialFeedDemo,
  pageBuilder: (context, state) => NoTransitionPage<void>(
    key: state.pageKey,
    child: BlocProviderHelpers.routeScopedWithAsyncInit<SocialFeedCubit>(
      create: () => SocialFeedCubit(
        repository: factory.socialFeedRepository,
        realtimeSource: factory.socialFeedRealtimeSource,
        scenario: factory.socialFeedScenarioController,
        clock: () => DateTime.now().toUtc(),
      ),
      init: (cubit) => cubit.initialize(),
      child: const SocialFeedDemoPage(),
    ),
  ),
);

RouteBase createNativePlatformShowcaseRoute(
  DemoRouteFactory factory,
) => GoRoute(
  path: AppRoutes.nativePlatformShowcasePath,
  name: AppRoutes.nativePlatformShowcase,
  builder: (context, state) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProviderHelpers.providerWithAsyncInit<NativePlatformShowcaseCubit>(
        create: () => NativePlatformShowcaseCubit(
          loadShowcase: factory.loadNativePlatformShowcaseUseCase,
          watchTelemetry: factory.watchNativeShowcaseTelemetryUseCase,
          triggerHaptic: factory.triggerNativeShowcaseHapticUseCase,
          shareText: factory.shareNativeShowcaseTextUseCase,
        ),
        init: (cubit) => cubit.load(),
      ),
      BlocProvider<NativeSecurityShowcaseCubit>(
        create: (_) => factory.createNativeSecurityShowcaseCubit(),
      ),
    ],
    child: const NativePlatformShowcasePage(),
  ),
);

RouteBase createEventBusDemoRoute(DemoRouteFactory factory) => GoRoute(
  path: AppRoutes.eventBusDemoPath,
  name: AppRoutes.eventBusDemo,
  builder: (context, state) => EventBusDemoPage(eventBus: factory.eventBus),
);
