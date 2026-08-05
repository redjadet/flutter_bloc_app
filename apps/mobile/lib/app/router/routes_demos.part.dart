part of 'routes_demos.dart';

List<RouteBase> createDemoRoutesTail() => <RouteBase>[
  GoRoute(
    path: AppRoutes.fcmDemoPath,
    name: AppRoutes.fcmDemo,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<FcmDemoCubit>(
          create: () => FcmDemoCubit(
            messaging: getIt<FcmMessagingService>(),
            coordinator: getIt<BackgroundSyncCoordinator>(),
          ),
          init: (final cubit) => cubit.initialize(),
          child: const FcmDemoPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.productionReadinessPath,
    name: AppRoutes.productionReadiness,
    builder: (final context, final state) {
      final FcmSimulationController? simulation =
          getIt.isRegistered<FcmSimulationController>()
          ? getIt<FcmSimulationController>()
          : null;
      return BlocProviderHelpers.withAsyncInit<ProductionReadinessCubit>(
        create: () {
          final bool firebaseReady =
              FirebaseBootstrapService.isFirebaseInitialized;
          return ProductionReadinessCubit(
            remoteConfig: getIt<RemoteConfigService>(),
            consentRepository: getIt<AnalyticsConsentRepository>(),
            analytics: getIt<ProductAnalytics>(),
            memoryAnalytics: getIt.isRegistered<InMemoryProductAnalytics>()
                ? getIt<InMemoryProductAnalytics>()
                : null,
            messaging: getIt<FcmMessagingService>(),
            frameMonitor: getIt<FrameTimingMonitor>(),
            simulationController: simulation,
            fcmMode: getIt.isRegistered<FcmDemoMode>()
                ? getIt<FcmDemoMode>()
                : FcmDemoMode.simulated,
            recordNonFatal: firebaseReady
                ? (
                    exception,
                    stack, {
                    required fatal,
                    required reason,
                  }) =>
                      FirebaseCrashlyticsBootstrap.recordProductionReadinessTestNonFatal()
                : null,
          );
        },
        init: (final cubit) => cubit.initialize(),
        child: ProductionReadinessPage(
          showSimulatedNotificationButton: simulation != null,
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.iotDemoPath,
    name: AppRoutes.iotDemo,
    builder: (final context, final state) {
      // Gate/policy once; listen only around hub so deferred ticks do not
      // recreate IotDemoCubit.
      final BackendAvailability availability = getIt<BackendAvailability>();
      final Widget hub = BlocProviderHelpers.withAsyncInit<IotDemoCubit>(
        create: () => IotDemoCubit(repository: getIt<IotDemoRepository>()),
        init: (final cubit) => cubit.initialize(),
        child: _listenBackendAvailability(
          (final live) => IotDemoHubPage(
            showBackendDisabledBanner: live.showIotCloudBackendDisabledBanner,
          ),
        ),
      );
      if (availability.webNoBackendMode) {
        return hub;
      }
      return IotDemoAuthGate(
        isSupabaseInitialized: SupabaseBootstrapService.isSupabaseInitialized,
        getCurrentUser: () => getIt<SupabaseAuthRepository>().currentUser,
        authStateChanges: getIt<SupabaseAuthRepository>().authStateChanges,
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
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<InAppPurchaseDemoCubit>(
          create: () {
            final fake = getIt<FakeInAppPurchaseRepository>();
            final real = getIt<FlutterInAppPurchaseRepository>();
            return InAppPurchaseDemoCubit(
              fakeRepository: fake,
              realRepository: real,
              fakeOutcomeControls: fake,
              realDemoControls: real,
            );
          },
          init: (final cubit) => cubit.initialize(),
          child: const InAppPurchaseDemoPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.aiDecisionDemoPath,
    name: AppRoutes.aiDecisionDemo,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<AiDecisionCubit>(
          create: () =>
              AiDecisionCubit(repository: getIt<AiDecisionRepository>()),
          init: (final cubit) => cubit.loadQueue(),
          child: const AiDecisionDemoPage(),
        ),
  ),
  createEventBusDemoRoute(),
  createOnlineTherapyDemoRoute(),
  createStaffAppDemoShellRoute(),
  createCaseStudyDemoShellRoute(),
  createNativePlatformShowcaseRoute(),
  createCertificatePinningDemoRoute(),
];

RouteBase createNativePlatformShowcaseRoute() => GoRoute(
  path: AppRoutes.nativePlatformShowcasePath,
  name: AppRoutes.nativePlatformShowcase,
  builder: (final context, final state) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProviderHelpers.providerWithAsyncInit<NativePlatformShowcaseCubit>(
        create: () => NativePlatformShowcaseCubit(
          loadShowcase: getIt<LoadNativePlatformShowcaseUseCase>(),
          watchTelemetry: getIt<WatchNativeShowcaseTelemetryUseCase>(),
          triggerHaptic: getIt<TriggerNativeShowcaseHapticUseCase>(),
          shareText: getIt<ShareNativeShowcaseTextUseCase>(),
        ),
        init: (final cubit) => cubit.load(),
      ),
      BlocProvider<NativeSecurityShowcaseCubit>(
        create: (_) => createNativeSecurityShowcaseCubit(),
      ),
    ],
    child: const NativePlatformShowcasePage(),
  ),
);

RouteBase createEventBusDemoRoute() => GoRoute(
  path: AppRoutes.eventBusDemoPath,
  name: AppRoutes.eventBusDemo,
  builder: (final context, final state) =>
      EventBusDemoPage(eventBus: getIt<EventBus>()),
);

ChatCubit _createChatCubit() => ChatCubit(
  repository: getIt<ChatRepository>(),
  historyRepository: getIt<ChatHistoryRepository>(),
  renderOrchestrationHfTokenProvider:
      getIt.isRegistered<RenderOrchestrationHfTokenProvider>()
      ? getIt<RenderOrchestrationHfTokenProvider>()
      : null,
  authSessionPort: getIt<ChatAuthSessionPort>(),
  renderOrchestrationDiagnostics:
      getIt<ChatRenderOrchestrationDiagnosticsPort>(),
  initialModel: SecretConfig.huggingfaceModel,
);

/// When Supabase is configured ([SupabaseAuthRepository.isConfigured]), requires
/// a Supabase session before showing chat; otherwise redirects to
/// [AppRoutes.supabaseAuthPath] with return [GoRouterState.matchedLocation].
Widget _withChatSupabaseSessionGate({
  required final GoRouterState state,
  required final BackendAvailability availability,
  required final Widget child,
}) {
  if (availability.webNoBackendMode) {
    return child;
  }
  final SupabaseAuthRepository supa = getIt<SupabaseAuthRepository>();
  return IotDemoAuthGate(
    isSupabaseInitialized: supa.isConfigured,
    getCurrentUser: () => supa.currentUser,
    authStateChanges: supa.authStateChanges,
    counterPath: AppRoutes.counterPath,
    supabaseAuthPath: AppRoutes.supabaseAuthPath,
    redirectReturnPath: state.matchedLocation,
    child: child,
  );
}

Widget _listenBackendAvailability(
  final Widget Function(BackendAvailability availability) builder,
) {
  return ListenableBuilder(
    listenable: BackendAvailabilityUpdates.instance,
    builder: (final context, final _) => builder(getIt<BackendAvailability>()),
  );
}
