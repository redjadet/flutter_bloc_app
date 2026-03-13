import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:go_router/go_router.dart';

/// Gate that shows [child] when either Supabase is not configured (local-only
/// mode) or Supabase is initialized and [getCurrentUser] returns a non-null
/// user; otherwise redirects to auth.
///
/// Dependencies are injected so the feature stays free of DI (SoC).
/// Route layer supplies paths and getCurrentUser from SupabaseAuthRepository.
class IotDemoAuthGate extends StatefulWidget {
  const IotDemoAuthGate({
    required this.isSupabaseInitialized,
    required this.getCurrentUser,
    required this.authStateChanges,
    required this.counterPath,
    required this.supabaseAuthPath,
    required this.redirectReturnPath,
    required this.child,
    super.key,
  });

  final bool isSupabaseInitialized;
  final AuthUser? Function() getCurrentUser;
  final Stream<AuthUser?> authStateChanges;
  final String counterPath;
  final String supabaseAuthPath;
  final String redirectReturnPath;
  final Widget child;

  @override
  State<IotDemoAuthGate> createState() => _IotDemoAuthGateState();
}

class _IotDemoAuthGateState extends State<IotDemoAuthGate> {
  bool _allowed = false;
  StreamSubscription<AuthUser?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToAuthStateChanges();
    WidgetsBinding.instance.addPostFrameCallback(_checkAndRedirect);
  }

  @override
  void didUpdateWidget(covariant final IotDemoAuthGate oldWidget) {
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
          'IotDemoAuthGate: auth state listener failed',
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
      if (!widget.isSupabaseInitialized) {
        if (mounted && !_allowed) setState(() => _allowed = true);
        return;
      }
      if (widget.getCurrentUser() == null) {
        final encoded = Uri.encodeComponent(widget.redirectReturnPath);
        context.go('${widget.supabaseAuthPath}?redirect=$encoded');
        return;
      }
      if (!mounted || _allowed) return;
      setState(() => _allowed = true);
    } on Object catch (error, stackTrace) {
      if (!mounted) return;
      AppLogger.error(
        'IotDemoAuthGate: auth check failed, redirecting to counter',
        error,
        stackTrace,
      );
      context.go(widget.counterPath);
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
