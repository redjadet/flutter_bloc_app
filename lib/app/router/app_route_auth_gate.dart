import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:go_router/go_router.dart';

/// Enforces a route-level auth policy for both normal navigation and deep links.
class AppRouteAuthGate extends StatefulWidget {
  const AppRouteAuthGate({
    required this.policy,
    required this.getCurrentUser,
    required this.authStateChanges,
    required this.authPath,
    required this.child,
    super.key,
  });

  final AppRoutePolicy policy;
  final AuthUser? Function() getCurrentUser;
  final Stream<AuthUser?> authStateChanges;
  final String authPath;
  final Widget child;

  @override
  State<AppRouteAuthGate> createState() => _AppRouteAuthGateState();
}

class _AppRouteAuthGateState extends State<AppRouteAuthGate> {
  bool _allowed = false;
  StreamSubscription<AuthUser?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToAuthStateChanges();
    WidgetsBinding.instance.addPostFrameCallback(_checkAndRedirect);
  }

  @override
  void didUpdateWidget(covariant final AppRouteAuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authStateChanges != widget.authStateChanges) {
      unawaited(_authStateSubscription?.cancel());
      _subscribeToAuthStateChanges();
    }
  }

  void _subscribeToAuthStateChanges() {
    _authStateSubscription = widget.authStateChanges.listen(
      (final _) => _checkAndRedirect(null),
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'AppRouteAuthGate: auth state listener failed',
          error,
          stackTrace,
        );
      },
      cancelOnError: false,
    );
  }

  void _checkAndRedirect(_) {
    if (!mounted) return;

    try {
      if (!widget.policy.requiresAuthentication) {
        if (!_allowed) {
          setState(() => _allowed = true);
        }
        return;
      }

      if (widget.getCurrentUser() == null) {
        final String redirectTarget = widget.policy.path;
        if (AppRoutes.isSafeRedirectPath(redirectTarget)) {
          final String encoded = Uri.encodeComponent(redirectTarget);
          context.go('${widget.authPath}?redirect=$encoded');
          return;
        }
        context.go(widget.authPath);
        return;
      }

      if (_allowed) return;
      setState(() => _allowed = true);
    } on Object catch (error, stackTrace) {
      if (!mounted) return;
      AppLogger.error(
        'AppRouteAuthGate: auth check failed, redirecting to auth',
        error,
        stackTrace,
      );
      context.go(widget.authPath);
    }
  }

  @override
  Widget build(final BuildContext context) {
    if (!_allowed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child;
  }

  @override
  void dispose() {
    unawaited(_authStateSubscription?.cancel());
    super.dispose();
  }
}
