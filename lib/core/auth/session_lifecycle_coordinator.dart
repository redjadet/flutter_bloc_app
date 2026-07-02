import 'dart:async';

import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/auth/remote_backend_auth_port.dart';
import 'package:flutter_bloc_app/core/auth/session_invalidation_reason.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Emitted when a provider session is invalidated (refresh failure, remote 401, etc.).
class SessionInvalidationEvent {
  const SessionInvalidationEvent({
    required this.provider,
    required this.reason,
    required this.occurredAt,
  });

  final AuthProviderKind provider;
  final SessionInvalidationReason reason;
  final DateTime occurredAt;
}

/// Central session cleanup and invalidation for Firebase and Supabase stacks.
abstract interface class SessionLifecycleCoordinator {
  Stream<SessionInvalidationEvent> get invalidationEvents;

  void bindAuthTokenManager(AuthTokenManager manager);

  void bindHfTokenProvider(RenderOrchestrationHfTokenProvider? provider);

  /// Idempotent cache cleanup after any sign-out (explicit or SDK-driven).
  Future<void> onSignOutCompleted({required AuthProviderKind provider});

  /// Refresh/auth failure path — may sign out on provider; always emits event.
  Future<void> invalidateSession({
    required AuthProviderKind provider,
    required SessionInvalidationReason reason,
  });

  /// Subscribe once to [AuthRepository.authStateChanges] for SDK-driven sign-out.
  void attachAuthRepository(AuthRepository repository);
}

class SessionLifecycleCoordinatorImpl implements SessionLifecycleCoordinator {
  SessionLifecycleCoordinatorImpl();

  final StreamController<SessionInvalidationEvent> _invalidationController =
      StreamController<SessionInvalidationEvent>.broadcast();

  AuthTokenManager? _authTokenManager;
  RenderOrchestrationHfTokenProvider? _hfTokenProvider;
  StreamSubscription<AuthUser?>? _authSubscription;
  AuthUser? _previousUser;
  bool _invalidationInFlight = false;
  bool _authRepositoryAttached = false;

  @override
  Stream<SessionInvalidationEvent> get invalidationEvents =>
      _invalidationController.stream;

  @override
  void bindAuthTokenManager(final AuthTokenManager manager) {
    _authTokenManager = manager;
  }

  @override
  void bindHfTokenProvider(final RenderOrchestrationHfTokenProvider? provider) {
    _hfTokenProvider = provider;
  }

  @override
  void attachAuthRepository(final AuthRepository repository) {
    if (_authRepositoryAttached) {
      return;
    }
    _authRepositoryAttached = true;
    _previousUser = repository.currentUser;
    _authSubscription = repository.authStateChanges.listen(
      (final user) async {
        final AuthUser? previous = _previousUser;
        _previousUser = user;
        if (previous != null && user == null) {
          await onSignOutCompleted(provider: AuthProviderKind.firebase);
        }
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'SessionLifecycleCoordinator.authStateChanges',
          error,
          stackTrace,
        );
      },
      cancelOnError: false,
    );
  }

  @override
  Future<void> onSignOutCompleted({
    required final AuthProviderKind provider,
  }) async {
    if (provider == AuthProviderKind.firebase) {
      _authTokenManager?.clearCache();
    }
    final RenderOrchestrationHfTokenProvider? hfProvider = _hfTokenProvider;
    if (hfProvider != null) {
      try {
        await hfProvider.clearRenderOrchestrationTokenCache();
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          'SessionLifecycleCoordinator: HF token cache clear failed',
          error,
          stackTrace,
        );
      }
    }
  }

  @override
  Future<void> invalidateSession({
    required final AuthProviderKind provider,
    required final SessionInvalidationReason reason,
  }) async {
    if (_invalidationInFlight) {
      return;
    }
    _invalidationInFlight = true;
    try {
      switch (provider) {
        case AuthProviderKind.firebase:
          if (getIt.isRegistered<AuthRepository>()) {
            await getIt<AuthRepository>().signOut();
          }
        case AuthProviderKind.supabase:
          if (getIt.isRegistered<RemoteBackendAuthPort>()) {
            await getIt<RemoteBackendAuthPort>().signOut();
          } else {
            AppLogger.debug(
              'SessionLifecycleCoordinator: skip supabase signOut (port not registered)',
            );
          }
      }
      // Emit after sign-out so session-expired UX does not race a still-valid
      // AuthRepository.currentUser (which would bounce users off /auth).
      _invalidationController.add(
        SessionInvalidationEvent(
          provider: provider,
          reason: reason,
          occurredAt: DateTime.now().toUtc(),
        ),
      );
    } finally {
      _invalidationInFlight = false;
    }
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _invalidationController.close();
  }
}
