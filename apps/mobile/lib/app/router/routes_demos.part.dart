part of 'routes_demos.dart';

List<RouteBase> createDemoRoutesHead(DemoRouteFactory factory) => <RouteBase>[
  RouteScopedPage.route(
    path: AppRoutes.chatPath,
    name: AppRoutes.chat,
    builder: (context, state) => factory._chatGate(
      state: state,
      child: factory
          ._listenBackendAvailability(
            (live) => ChatPage(
              errorNotificationService: factory.errorNotificationService,
              showBackendDisabledBanner: live.showChatBackendDisabledBanner,
              renderTransportDemoStrict: SecretConfig.chatRenderDemoStrict,
              chatRenderDemoBaseUrl: SecretConfig.chatRenderDemoBaseUrl,
            ),
          )
          .routeScoped(
            create: factory._createChatCubit,
            init: (cubit) => cubit.loadHistory(),
          )
          .routeScoped(
            create: factory._createChatSyncStatusCubit,
            init: (cubit) => cubit.refresh(),
          ),
    ),
  ),
  RouteScopedPage.route(
    path: AppRoutes.chatListPath,
    name: AppRoutes.chatList,
    builder: (context, state) => factory._chatGate(
      state: state,
      child: factory
          ._listenBackendAvailability(
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
          )
          .routeScoped(
            create: factory._createChatSyncStatusCubit,
            init: (cubit) => cubit.refresh(),
          ),
    ),
  ),
  RouteScopedPage.route(
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
      return const GenUiDemoPage().routeScoped(
        create: () => GenUiDemoCubit(agent: factory.genUiDemoAgent),
        init: (cubit) => cubit.initialize(),
      );
    },
  ),
  RouteScopedPage.route(
    path: AppRoutes.playlearnPath,
    name: AppRoutes.playlearn,
    builder: (context, state) => PlaylearnPage(
      repository: factory.vocabularyRepository,
      audioService: factory.createAudioPlaybackService(),
    ),
    routes: <RouteBase>[
      RouteScopedPage.route(
        path: 'vocabulary/:topicId',
        name: AppRoutes.playlearnVocabulary,
        builder: (context, state) => VocabularyListPage(
          topicId: state.pathParameters['topicId'] ?? '',
          repository: factory.vocabularyRepository,
          audioService: factory.createAudioPlaybackService(),
        ),
      ),
    ],
  ),
  RouteScopedPage.route(
    path: AppRoutes.igamingDemoPath,
    name: AppRoutes.igamingDemo,
    builder: (context, state) {
      final l10n = context.l10n;
      return const LobbyPage().routeScoped(
        create: () => LobbyCubit(
          repository: factory.demoBalanceRepository,
          l10n: l10n,
        ),
        init: (cubit) => cubit.loadBalance(),
      );
    },
    routes: <RouteBase>[
      RouteScopedPage.route(
        path: 'game',
        name: AppRoutes.igamingDemoGame,
        builder: (context, state) {
          final l10n = context.l10n;
          return const GamePage().routeScoped(
            create: () => GameCubit(
              balanceRepository: factory.demoBalanceRepository,
              timerService: factory.timerService,
              l10n: l10n,
            ),
            init: (cubit) => cubit.loadBalance(),
          );
        },
      ),
    ],
  ),
];

List<RouteBase> createDemoRoutesTail(DemoRouteFactory factory) => <RouteBase>[
  RouteScopedPage.routeWithCubit<FcmDemoCubit>(
    path: AppRoutes.fcmDemoPath,
    name: AppRoutes.fcmDemo,
    create: (_, _) => FcmDemoCubit(
      messaging: factory.fcmMessagingService,
      coordinator: factory.backgroundSyncCoordinator,
    ),
    init: (cubit) => cubit.initialize(),
    child: const FcmDemoPage(),
  ),
  RouteScopedPage.route(
    path: AppRoutes.productionReadinessPath,
    name: AppRoutes.productionReadiness,
    builder: (context, state) {
      final simulation = factory.fcmSimulationController;
      return ProductionReadinessPage(
        showSimulatedNotificationButton: simulation != null,
      ).routeScoped(
        create: () => ProductionReadinessCubit(
          remoteConfig: factory.remoteConfigService,
          consentRepository: factory.analyticsConsentRepository,
          analytics: factory.productAnalytics,
          memoryAnalytics: factory.memoryAnalytics,
          messaging: factory.fcmMessagingService,
          frameMonitor: factory.frameTimingMonitor,
          simulationController: simulation,
          fcmMode: factory.fcmDemoMode,
          recordNonFatal: FirebaseBootstrapService.isFirebaseInitialized
              ? FirebaseCrashlyticsBootstrap
                    .recordProductionReadinessTestNonFatal
              : null,
        ),
        init: (cubit) => cubit.initialize(),
      );
    },
  ),
  RouteScopedPage.route(
    path: AppRoutes.iotDemoPath,
    name: AppRoutes.iotDemo,
    builder: (context, state) {
      // Gate/policy once; listen only around hub so deferred ticks do not
      // recreate IotDemoCubit.
      final hub = factory
          ._listenBackendAvailability(
            (live) => IotDemoHubPage(
              showBackendDisabledBanner: live.showIotCloudBackendDisabledBanner,
              createIotBleCubit: factory.createIotBleCubit,
            ),
          )
          .routeScoped(
            create: () => IotDemoCubit(repository: factory.iotDemoRepository),
            init: (cubit) => cubit.initialize(),
          );
      if (factory.backendAvailability.webNoBackendMode) return hub;
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
  RouteScopedPage.routeWithCubit<InAppPurchaseDemoCubit>(
    path: AppRoutes.iapDemoPath,
    name: AppRoutes.iapDemo,
    create: (_, _) {
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
  RouteScopedPage.routeWithCubit<AiDecisionCubit>(
    path: AppRoutes.aiDecisionDemoPath,
    name: AppRoutes.aiDecisionDemo,
    create: (_, _) => AiDecisionCubit(repository: factory.aiDecisionRepository),
    init: (cubit) => cubit.loadQueue(),
    child: const AiDecisionDemoPage(),
  ),
  createEventBusDemoRoute(factory),
  createSocialFeedDemoRoute(factory),
  createOnlineTherapyDemoRoute(factory.onlineTherapyDemoRouteFactory),
  createStaffAppDemoShellRoute(factory.staffAppDemoRouteFactory),
  createCaseStudyDemoShellRoute(factory.caseStudyDemoRouteFactory),
  createNativePlatformShowcaseRoute(factory),
  createCertificatePinningDemoRoute(factory.certificatePinningDemoRouteFactory),
];

RouteBase createSocialFeedDemoRoute(DemoRouteFactory factory) =>
    RouteScopedPage.routeWithCubit<SocialFeedCubit>(
      path: AppRoutes.socialFeedDemoPath,
      name: AppRoutes.socialFeedDemo,
      create: (_, _) => SocialFeedCubit(
        repository: factory.socialFeedRepository,
        realtimeSource: factory.socialFeedRealtimeSource,
        scenario: factory.socialFeedScenarioController,
        clock: () => DateTime.now().toUtc(),
      ),
      init: (cubit) => cubit.initialize(),
      child: const SocialFeedDemoPage(),
    );

RouteBase createNativePlatformShowcaseRoute(DemoRouteFactory factory) =>
    RouteScopedPage.route(
      path: AppRoutes.nativePlatformShowcasePath,
      name: AppRoutes.nativePlatformShowcase,
      builder: (context, state) => const NativePlatformShowcasePage()
          .routeScoped(create: factory.createNativeSecurityShowcaseCubit)
          .routeScoped(
            create: () => NativePlatformShowcaseCubit(
              loadShowcase: factory.loadNativePlatformShowcaseUseCase,
              watchTelemetry: factory.watchNativeShowcaseTelemetryUseCase,
              triggerHaptic: factory.triggerNativeShowcaseHapticUseCase,
              shareText: factory.shareNativeShowcaseTextUseCase,
            ),
            init: (cubit) => cubit.load(),
          ),
    );

RouteBase createEventBusDemoRoute(DemoRouteFactory factory) =>
    RouteScopedPage.route(
      path: AppRoutes.eventBusDemoPath,
      name: AppRoutes.eventBusDemo,
      builder: (context, state) => EventBusDemoPage(eventBus: factory.eventBus),
    );
