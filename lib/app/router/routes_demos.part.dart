part of 'routes_demos.dart';

List<RouteBase> createDemoRoutesTail() => <RouteBase>[
  GoRoute(
    path: AppRoutes.iotDemoPath,
    name: AppRoutes.iotDemo,
    builder: (final context, final state) {
      final l10n = context.l10n;
      return IotDemoAuthGate(
        isSupabaseInitialized: SupabaseBootstrapService.isSupabaseInitialized,
        getCurrentUser: () => getIt<SupabaseAuthRepository>().currentUser,
        authStateChanges: getIt<SupabaseAuthRepository>().authStateChanges,
        counterPath: AppRoutes.counterPath,
        supabaseAuthPath: AppRoutes.supabaseAuthPath,
        redirectReturnPath: AppRoutes.iotDemoPath,
        child: BlocProviderHelpers.withAsyncInit<IotDemoCubit>(
          create: () => IotDemoCubit(
            repository: getIt<IotDemoRepository>(),
            l10n: l10n,
          ),
          init: (final cubit) => cubit.initialize(),
          child: const IotDemoPage(),
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.iapDemoPath,
    name: AppRoutes.iapDemo,
    builder: (final context, final state) =>
        BlocProviderHelpers.withAsyncInit<InAppPurchaseDemoCubit>(
          create: () => InAppPurchaseDemoCubit(
            fakeRepository: getIt<FakeInAppPurchaseRepository>(),
            realRepository: getIt<FlutterInAppPurchaseRepository>(),
          ),
          init: (final cubit) => cubit.initialize(),
          child: const InAppPurchaseDemoPage(),
        ),
  ),
  GoRoute(
    path: AppRoutes.aiDecisionDemoPath,
    name: AppRoutes.aiDecisionDemo,
    builder: (final context, final state) => const AiDecisionDemoPage(),
  ),
  createEventBusDemoRoute(),
  createOnlineTherapyDemoRoute(),
];

RouteBase createEventBusDemoRoute() => GoRoute(
  path: AppRoutes.eventBusDemoPath,
  name: AppRoutes.eventBusDemo,
  builder: (final context, final state) => const EventBusDemoPage(),
);

/// When Supabase is configured ([SupabaseAuthRepository.isConfigured]), requires
/// a Supabase session before showing chat; otherwise redirects to
/// [AppRoutes.supabaseAuthPath] with return [GoRouterState.matchedLocation].
Widget _withChatSupabaseSessionGate({
  required final GoRouterState state,
  required final Widget child,
}) {
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

/// Shown when user reaches FCM demo route but Firebase is not initialized;
/// redirects to counter so the app does not crash.
class _FcmDemoRedirectWhenUnavailable extends StatefulWidget {
  const _FcmDemoRedirectWhenUnavailable();

  @override
  State<_FcmDemoRedirectWhenUnavailable> createState() =>
      _FcmDemoRedirectWhenUnavailableState();
}

class _FcmDemoRedirectWhenUnavailableState
    extends State<_FcmDemoRedirectWhenUnavailable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(AppRoutes.counterPath);
    });
  }

  @override
  Widget build(final BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}
