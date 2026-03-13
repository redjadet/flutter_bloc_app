import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/app/router/auth_redirect.dart';
import 'package:flutter_bloc_app/app/router/go_router_refresh_stream.dart';
import 'package:flutter_bloc_app/app/router/routes.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:go_router/go_router.dart';

/// Main application widget
class MyApp extends StatefulWidget {
  const MyApp({super.key, this.requireAuth = true});

  final bool requireAuth;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouterRefreshStream? _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  /// Creates and configures the GoRouter instance with all application routes.
  ///
  /// **Route Structure:**
  /// - Public routes (accessible without authentication): All routes except `/auth`
  /// - Protected routes: Require authentication (handled by redirect logic)
  /// - Deep link support: Deep links are allowed even when not authenticated
  ///
  /// See [createAppRoutes] for route definitions and [createAuthRedirect] for
  /// authentication redirect logic documentation.
  GoRouter _createRouter() {
    final List<GoRoute> routes = createAppRoutes();

    // When auth is not required or Firebase is not initialized, run without
    // auth redirect so the app still runs (Firebase-dependent features disabled).
    final bool useAuth = widget.requireAuth && Firebase.apps.isNotEmpty;

    if (!useAuth) {
      return GoRouter(initialLocation: AppRoutes.counterPath, routes: routes);
    }

    final authRepository = getIt<AuthRepository>();
    // Listen to auth state changes and refresh router when auth state changes
    // This ensures navigation updates when user logs in/out
    final authRefresh = GoRouterRefreshStream(authRepository.authStateChanges);
    _authRefresh = authRefresh;

    return GoRouter(
      initialLocation: AppRoutes.counterPath,
      // Refresh router when auth state changes (login/logout)
      refreshListenable: authRefresh,
      redirect: createAuthRedirect(authRepository),
      routes: routes,
    );
  }

  @override
  Widget build(final BuildContext context) => AppScope(router: _router);

  @override
  void dispose() {
    _authRefresh?.dispose();
    super.dispose();
  }
}
