import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:auth/auth.dart' hide AuthRepository;
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/http/auth/auth_token_manager.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';

part 'session_lifecycle_coordinator_auth.part.dart';
part 'session_lifecycle_coordinator_session.part.dart';

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

/// Why local offline/session data is being cleared.
enum SessionLocalCleanupReason {
  /// Provider signed out to null / explicit sign-out completed.
  signOut,

  /// Authenticated user id changed without an intermediate null hop (A→B).
  accountSwitch,
}

/// Clears device-local offline data that must not survive auth transitions.
typedef SessionLocalDataCleanup =
    Future<void> Function({
      required AuthProviderKind provider,
      required SessionLocalCleanupReason reason,
    });

/// Central session cleanup and invalidation for Firebase and Supabase stacks.
abstract interface class SessionLifecycleCoordinator {
  Stream<SessionInvalidationEvent> get invalidationEvents;

  /// Auth identity stream that only emits after local session cleanup settles.
  ///
  /// Listeners (router, AppAuthCubit) must use this instead of the raw
  /// provider stream so account-switch cannot observe the previous user's
  /// Hive/pending-sync data mid-clear.
  Stream<AuthUser?> get sessionReadyAuthStateChanges;

  /// Last identity published on [sessionReadyAuthStateChanges].
  ///
  /// [AuthRepository.currentUser] must read this (not the raw provider user)
  /// so redirects and route gates cannot observe account B while local stores
  /// still hold account A during cleanup.
  AuthUser? get sessionReadyCurrentUser;

  void bindAuthTokenManager(AuthTokenManager manager);

  void bindTokenRepository(TokenRepository repository);

  void bindHfTokenProvider(RenderOrchestrationHfTokenProvider? provider);

  /// Optional cleanup for Hive/pending-sync state that is not token-scoped.
  void bindLocalSessionDataCleanup(SessionLocalDataCleanup cleanup);

  /// Idempotent cache cleanup after any sign-out (explicit or SDK-driven).
  Future<void> onSignOutCompleted({required AuthProviderKind provider});

  /// Refresh/auth failure path — may sign out on provider; always emits event.
  Future<void> invalidateSession({
    required AuthProviderKind provider,
    required SessionInvalidationReason reason,
  });

  /// Subscribe once to the raw [AuthRepository.authStateChanges] for SDK-driven
  /// sign-out / account-switch. Pass the undecorated repository (not a gated
  /// wrapper) to avoid deadlock with session-ready auth changes.
  void attachAuthRepository(AuthRepository repository);
}

class SessionLifecycleCoordinatorImpl implements SessionLifecycleCoordinator {
  SessionLifecycleCoordinatorImpl();

  final StreamController<SessionInvalidationEvent> _invalidationController =
      StreamController<SessionInvalidationEvent>.broadcast();
  final StreamController<AuthUser?> _sessionReadyFanout =
      StreamController<AuthUser?>.broadcast();

  AuthTokenManager? _authTokenManager;
  TokenRepository? _tokenRepository;
  RenderOrchestrationHfTokenProvider? _hfTokenProvider;
  SessionLocalDataCleanup? _localSessionDataCleanup;
  StreamSubscription<AuthUser?>? _authSubscription;
  AuthUser? _previousUser;
  AuthUser? _sessionReadyUser;
  bool _hasSessionReadyUser = false;
  Completer<void>? _localCleanupBarrier;
  Future<void> _authTransitionChain = Future<void>.value();
  int _authTransitionGeneration = 0;
  Future<void>? _onSignOutCompletedInFlight;
  final Set<AuthProviderKind> _invalidationInFlight = <AuthProviderKind>{};
  bool _authRepositoryAttached = false;

  @override
  Stream<SessionInvalidationEvent> get invalidationEvents =>
      _invalidationController.stream;

  @override
  AuthUser? get sessionReadyCurrentUser =>
      _hasSessionReadyUser ? _sessionReadyUser : null;

  @override
  Stream<AuthUser?> get sessionReadyAuthStateChanges => Stream<AuthUser?>.multi(
    (controller) {
      if (_hasSessionReadyUser) {
        controller.add(_sessionReadyUser);
      }
      final StreamSubscription<AuthUser?> sub = _sessionReadyFanout.stream
          .listen(
            controller.add,
            onError: controller.addError,
            onDone: controller.close,
          );
      controller.onCancel = sub.cancel;
    },
  );

  @override
  void bindAuthTokenManager(final AuthTokenManager manager) {
    _authTokenManager = manager;
  }

  @override
  void bindTokenRepository(final TokenRepository repository) {
    _tokenRepository = repository;
  }

  @override
  void bindHfTokenProvider(final RenderOrchestrationHfTokenProvider? provider) {
    _hfTokenProvider = provider;
  }

  @override
  void bindLocalSessionDataCleanup(final SessionLocalDataCleanup cleanup) {
    _localSessionDataCleanup = cleanup;
  }

  @override
  void attachAuthRepository(final AuthRepository repository) =>
      attachAuthRepositoryBody(repository);

  @override
  Future<void> onSignOutCompleted({
    required final AuthProviderKind provider,
  }) => onSignOutCompletedBody(provider: provider);

  @override
  Future<void> invalidateSession({
    required final AuthProviderKind provider,
    required final SessionInvalidationReason reason,
  }) => invalidateSessionBody(provider: provider, reason: reason);

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _invalidationController.close();
    await _sessionReadyFanout.close();
  }
}
