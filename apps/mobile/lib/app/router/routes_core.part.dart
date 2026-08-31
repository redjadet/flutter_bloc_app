part of 'routes_core.dart';

List<RouteBase> _coreRoutesSettingsAndProfile(CoreRouteFactory factory) =>
    <RouteBase>[
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) => AppRouteAuthGate(
          policy: AppRoutePolicies.settings,
          getCurrentUser: () => factory.authRepository.currentUser,
          authStateChanges: factory.authRepository.authStateChanges,
          authPath: AppRoutes.authPath,
          child: SettingsPage(
            appInfoRepository: factory.appInfoRepository,
            authRepository: factory.authRepository,
            analyticsConsentRepository: factory.analyticsConsentRepository,
            productAnalytics: factory.productAnalytics,
            showQaExtras: FlavorManager.I.isDev || FlavorManager.I.isQa,
            buildQaExtras: (ctx) => <Widget>[
              GraphqlCacheControlsSection(
                key: const ValueKey('settings-qa-graphql-cache-controls'),
                cacheRepository: factory.graphqlCacheClearPort,
              ),
              SizedBox(
                key: const ValueKey('settings-qa-gap-graphql-profile'),
                height: ctx.responsiveGapL,
              ),
              ProfileCacheControlsSection(
                key: const ValueKey('settings-qa-profile-cache-controls'),
                profileCacheRepository: factory.profileCacheControlsPort,
              ),
              SizedBox(
                key: const ValueKey('settings-qa-gap-profile-remote-config'),
                height: ctx.responsiveGapL,
              ),
              const RemoteConfigDiagnosticsSection(
                key: ValueKey('settings-qa-remote-config-diagnostics'),
              ),
              SizedBox(
                key: const ValueKey('settings-qa-gap-remote-config-sync'),
                height: ctx.responsiveGapL,
              ),
              const SyncDiagnosticsSection(
                key: ValueKey('settings-qa-sync-diagnostics'),
              ),
              SizedBox(
                key: const ValueKey('settings-qa-gap-sync-counter-inspector'),
                height: ctx.responsiveGapL,
              ),
              CounterSyncQueueInspectorButton(
                key: const ValueKey('settings-qa-counter-sync-queue-inspector'),
                repository: factory.counterSyncDiagnosticsPort,
                onPendingSyncEnqueued:
                    factory.pendingSyncRepository.onOperationEnqueued,
              ),
            ],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.manageAccountPath,
        name: AppRoutes.manageAccount,
        builder: (context, state) => AppRouteAuthGate(
          policy: AppRoutePolicies.manageAccount,
          getCurrentUser: () => factory.authRepository.currentUser,
          authStateChanges: factory.authRepository.authStateChanges,
          authPath: AppRoutes.authPath,
          child: const AuthProfilePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (context, state) => AppRouteAuthGate(
          policy: AppRoutePolicies.profile,
          getCurrentUser: () => factory.authRepository.currentUser,
          authStateChanges: factory.authRepository.authStateChanges,
          authPath: AppRoutes.authPath,
          child: BlocProviderHelpers.withAsyncInit<ProfileCubit>(
            create: () => ProfileCubit(repository: factory.profileRepository),
            init: (cubit) => cubit.loadProfile(),
            child: const ProfilePage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.loggedOutPath,
        name: AppRoutes.loggedOut,
        builder: (context, state) => const LoggedOutPage(),
      ),
      GoRoute(
        path: AppRoutes.libraryDemoPath,
        name: AppRoutes.libraryDemo,
        builder: (context, state) => BlocProvider<ScapesCubit>(
          create: (_) => ScapesCubit(
            repository: factory.scapesRepository,
            timerService: factory.timerService,
          ),
          child: LibraryDemoPage(
            timerService: factory.timerService,
            gridTrailingSlivers: const [ScapesGridSliverContent()],
          ),
        ),
      ),
    ];
