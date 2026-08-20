import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/app/app_scope.dart' show AppScope;
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/composition/app_composition_root_demo_route_factory.dart'
    as demo_route_factories;
import 'package:flutter_bloc_app/app/composition/app_composition_root_route_factories.dart'
    as route_factories;
import 'package:flutter_bloc_app/app/composition/app_scope_dependencies.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/supabase_config_coordinator.dart';
import 'package:flutter_bloc_app/app/router/app_navigator_keys.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/auth_redirect.dart';
import 'package:flutter_bloc_app/app/router/go_router_refresh_stream.dart';
import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/app/router/routes.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:flutter_bloc_app/app/services/app_memory_service.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/deeplink/deeplink.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/settings/settings.dart';
import 'package:go_router/go_router.dart' show GoRouter, RouteBase;
import 'package:networking/networking.dart';

/// App composition boundary.
///
/// Centralizes decisions that wire infrastructure into navigation and the
/// app shell:
/// - whether auth redirect is enabled
/// - GoRouter instance creation
/// - auth stream -> router refresh wiring
/// - [AppScope] dependency resolution
///
/// Widgets below should remain "dumb": they render with injected instances
/// instead of assembling infrastructure themselves.
class AppCompositionRoot {
  const AppCompositionRoot._();

  /// Resolves app-shell dependencies from the configured locator.
  ///
  /// Call after DI registration (and any test overrides) so [AppScope] never
  /// needs to query the locator.
  static AppScopeDependencies resolveAppScopeDependencies() {
    return AppScopeDependencies(
      syncCoordinator: getIt<BackgroundSyncCoordinator>(),
      memoryService: getIt<AppMemoryService>(),
      timerService: getIt<TimerService>(),
      authRepository: getIt<AuthRepository>(),
      sessionCoordinator: getIt<SessionLifecycleCoordinator>(),
      networkStatusService: getIt<NetworkStatusService>(),
      localeRepository: getIt<LocaleRepository>(),
      themeRepository: getIt<ThemeRepository>(),
      createRemoteConfigCubit: () => getIt<RemoteConfigCubit>(),
      deepLinkService: getIt<DeepLinkService>(),
      deepLinkParser: getIt<DeepLinkParser>(),
      retryNotificationService: getIt<RetryNotificationService>(),
      supabaseConfigCoordinator: getIt.isRegistered<SupabaseConfigCoordinator>()
          ? getIt<SupabaseConfigCoordinator>()
          : null,
    );
  }

  static AppCompositionRootGraph _createRouterGraph({
    required bool requireAuth,
  }) {
    final List<RouteBase> routes = createAppRoutes(resolveRouteFactories());

    final bool useAuth =
        requireAuth &&
        (Firebase.apps.isNotEmpty ||
            FirebaseBootstrapService.supportsDebugLocalGuestAuth);

    if (!useAuth) {
      return AppCompositionRootGraph(
        router: GoRouter(
          initialLocation: AppRoutes.counterPath,
          navigatorKey: rootNavigatorKey,
          routes: routes,
        ),
      );
    }

    final authRepository = getIt<AuthRepository>();
    final authRefresh = GoRouterRefreshStream(authRepository.authStateChanges);

    return AppCompositionRootGraph(
      router: GoRouter(
        initialLocation: AppRoutes.counterPath,
        navigatorKey: rootNavigatorKey,
        // Refresh router when auth state changes (login/logout).
        refreshListenable: authRefresh,
        redirect: createAuthRedirect(authRepository),
        routes: routes,
      ),
      authRefresh: authRefresh,
    );
  }

  /// Creates the root widget with wired navigation and app-shell dependencies.
  static Widget createApp({bool requireAuth = true}) {
    final graph = _createRouterGraph(requireAuth: requireAuth);
    return MyApp(
      router: graph.router,
      authRefresh: graph.authRefresh,
      dependencies: resolveAppScopeDependencies(),
    );
  }

  static AppRouteFactories resolveRouteFactories() =>
      route_factories.resolveAppRouteFactories();

  static CoreRouteFactory resolveCoreRouteFactory({
    AuthRepository? authRepository,
    TimerService? timerService,
  }) => route_factories.resolveCoreRouteFactory(
    authRepository: authRepository,
    timerService: timerService,
  );

  static AuxiliaryRouteFactory resolveAuxiliaryRouteFactory({
    AuthRepository? authRepository,
    TimerService? timerService,
  }) => route_factories.resolveAuxiliaryRouteFactory(
    authRepository: authRepository,
    timerService: timerService,
  );

  static DemoRouteFactory resolveDemoRouteFactory({
    AuthRepository? authRepository,
    TimerService? timerService,
  }) => demo_route_factories.resolveDemoRouteFactory(
    authRepository: authRepository,
    timerService: timerService,
  );
}

class AppCompositionRootGraph {
  const AppCompositionRootGraph({
    required this.router,
    this.authRefresh,
  });

  final GoRouter router;
  final GoRouterRefreshStream? authRefresh;
}
