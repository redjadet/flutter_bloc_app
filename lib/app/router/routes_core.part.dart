part of 'routes_core.dart';

List<RouteBase> _coreRoutesSettingsAndProfile() => <RouteBase>[
  GoRoute(
    path: AppRoutes.settingsPath,
    name: AppRoutes.settings,
    builder: (final context, final state) => AppRouteAuthGate(
      policy: AppRoutePolicies.settings,
      getCurrentUser: () => getIt<AuthRepository>().currentUser,
      authStateChanges: getIt<AuthRepository>().authStateChanges,
      authPath: AppRoutes.authPath,
      child: SettingsPage(
        appInfoRepository: getIt<AppInfoRepository>(),
        buildQaExtras: (final ctx) => <Widget>[
          GraphqlCacheControlsSection(
            key: const ValueKey('settings-qa-graphql-cache-controls'),
            cacheRepository: getIt<GraphqlCacheClearPort>(),
          ),
          SizedBox(
            key: const ValueKey('settings-qa-gap-graphql-profile'),
            height: ctx.responsiveGapL,
          ),
          ProfileCacheControlsSection(
            key: const ValueKey('settings-qa-profile-cache-controls'),
            profileCacheRepository: getIt<ProfileCacheControlsPort>(),
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
        ],
      ),
    ),
  ),
  GoRoute(
    path: AppRoutes.manageAccountPath,
    name: AppRoutes.manageAccount,
    builder: (final context, final state) => AppRouteAuthGate(
      policy: AppRoutePolicies.manageAccount,
      getCurrentUser: () => getIt<AuthRepository>().currentUser,
      authStateChanges: getIt<AuthRepository>().authStateChanges,
      authPath: AppRoutes.authPath,
      child: const AuthProfilePage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.profilePath,
    name: AppRoutes.profile,
    builder: (final context, final state) => AppRouteAuthGate(
      policy: AppRoutePolicies.profile,
      getCurrentUser: () => getIt<AuthRepository>().currentUser,
      authStateChanges: getIt<AuthRepository>().authStateChanges,
      authPath: AppRoutes.authPath,
      child: BlocProviderHelpers.withAsyncInit<ProfileCubit>(
        create: () => ProfileCubit(
          repository: getIt<ProfileRepository>(),
        ),
        init: (final cubit) => cubit.loadProfile(),
        child: const ProfilePage(),
      ),
    ),
  ),
  GoRoute(
    path: AppRoutes.registerPath,
    name: AppRoutes.register,
    builder: (final context, final state) => const RegisterPage(),
  ),
  GoRoute(
    path: AppRoutes.loggedOutPath,
    name: AppRoutes.loggedOut,
    builder: (final context, final state) => const LoggedOutPage(),
  ),
  GoRoute(
    path: AppRoutes.libraryDemoPath,
    name: AppRoutes.libraryDemo,
    builder: (final context, final state) => BlocProvider<ScapesCubit>(
      create: (_) => ScapesCubit(
        repository: getIt<ScapesRepository>(),
        timerService: getIt<TimerService>(),
      ),
      child: LibraryDemoPage(
        timerService: getIt<TimerService>(),
        gridTrailingSlivers: const [ScapesGridSliverContent()],
      ),
    ),
  ),
];
