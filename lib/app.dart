import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/app/router/auth_redirect.dart';
import 'package:flutter_bloc_app/app/router/go_router_refresh_stream.dart';
import 'package:flutter_bloc_app/app/router/routes.dart';
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
  late final FirebaseAuth _auth;
  late final GoRouterRefreshStream _authRefresh;
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

    if (!widget.requireAuth) {
      return GoRouter(initialLocation: AppRoutes.counterPath, routes: routes);
    }

    _auth = FirebaseAuth.instance;
    // Listen to auth state changes and refresh router when auth state changes
    // This ensures navigation updates when user logs in/out
    _authRefresh = GoRouterRefreshStream(_auth.authStateChanges());

    return GoRouter(
      initialLocation: AppRoutes.counterPath,
      // Refresh router when auth state changes (login/logout)
      refreshListenable: _authRefresh,
      redirect: createAuthRedirect(_auth),
      routes: routes,
    );
  }

  @override
  Widget build(final BuildContext context) => AppScope(router: _router);

  @override
  void dispose() {
    if (widget.requireAuth) {
      _authRefresh.dispose();
    }
    super.dispose();
  }
}
