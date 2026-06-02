part of 'routes_demos.dart';

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
