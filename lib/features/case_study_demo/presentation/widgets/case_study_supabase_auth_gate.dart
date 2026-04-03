import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/shared/utils/disposable_bag.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:go_router/go_router.dart';

/// Gate that shows [child] when either Supabase is not configured (local-only
/// mode) or Supabase is initialized and [getCurrentUser] returns a non-null
/// user; otherwise redirects to Supabase auth.
///
/// Dependencies are injected so the widget is DI-free and reusable.
class CaseStudySupabaseAuthGate extends StatefulWidget {
  const CaseStudySupabaseAuthGate({
    required this.isSupabaseInitialized,
    required this.getCurrentUser,
    required this.authStateChanges,
    required this.fallbackPath,
    required this.supabaseAuthPath,
    required this.redirectReturnPath,
    required this.child,
    super.key,
  });

  final bool isSupabaseInitialized;
  final AuthUser? Function() getCurrentUser;
  final Stream<AuthUser?> authStateChanges;

  /// Where to send the user if the gate fails unexpectedly.
  final String fallbackPath;

  final String supabaseAuthPath;

  /// Path to return to after successful Supabase sign-in.
  final String redirectReturnPath;

  final Widget child;

  @override
  State<CaseStudySupabaseAuthGate> createState() =>
      _CaseStudySupabaseAuthGateState();
}

class _CaseStudySupabaseAuthGateState extends State<CaseStudySupabaseAuthGate> {
  final DisposableBag _disposables = DisposableBag();
  bool _allowed = false;
  // ignore: cancel_subscriptions - Lifecycle is centralized via DisposableBag.
  StreamSubscription<AuthUser?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToAuthStateChanges();
    WidgetsBinding.instance.addPostFrameCallback(_checkAndRedirect);
  }

  @override
  void didUpdateWidget(covariant final CaseStudySupabaseAuthGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authStateChanges != widget.authStateChanges) {
      final StreamSubscription<AuthUser?>? previousSubscription =
          _authStateSubscription;
      _authStateSubscription = null;
      _disposables.untrackSubscription(previousSubscription);
      unawaited(previousSubscription?.cancel());
      _subscribeToAuthStateChanges();
    }
  }

  void _subscribeToAuthStateChanges() {
    _authStateSubscription = _disposables.trackSubscription(
      widget.authStateChanges.listen(
        (final _) => _checkAndRedirect(null),
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error(
            'CaseStudySupabaseAuthGate: auth state listener failed',
            error,
            stackTrace,
          );
        },
        cancelOnError: false,
      ),
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
        'CaseStudySupabaseAuthGate: auth check failed, redirecting to fallback',
        error,
        stackTrace,
      );
      context.go(widget.fallbackPath);
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
    _authStateSubscription = null;
    unawaited(_disposables.dispose());
    super.dispose();
  }
}
