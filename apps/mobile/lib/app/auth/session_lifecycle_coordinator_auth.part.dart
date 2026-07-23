part of 'session_lifecycle_coordinator.dart';

extension _SessionLifecycleCoordinatorAuth on SessionLifecycleCoordinatorImpl {
  void attachAuthRepositoryBody(final AuthRepository repository) {
    if (_authRepositoryAttached) {
      return;
    }
    _authRepositoryAttached = true;
    _previousUser = repository.currentUser;
    // Seed session-ready so gated listeners do not hang before the first
    // provider emission (e.g. cold-start / local guest auth).
    _publishSessionReady(repository.currentUser);
    _authSubscription = repository.authStateChanges.listen(
      (final user) {
        final int generation = ++_authTransitionGeneration;
        _authTransitionChain = _authTransitionChain
            .catchError((final Object _) {})
            .then(
              (final _) => _handleAuthUserChanged(user, generation: generation),
            );
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

  Future<void> _handleAuthUserChanged(
    final AuthUser? user, {
    required final int generation,
  }) async {
    final AuthUser? previous = _previousUser;
    if (previous != null && user == null) {
      await _runLocalCleanupThenPublish(
        user: null,
        generation: generation,
        cleanup: () => onSignOutCompleted(provider: AuthProviderKind.firebase),
      );
    } else if (previous != null && user != null && previous.id != user.id) {
      // Firebase can hop A→B without emitting null; tokens are uid-keyed
      // but shared Hive/pending-sync stores are not.
      await _runLocalCleanupThenPublish(
        user: user,
        generation: generation,
        cleanup: () => _clearLocalSessionData(
          provider: AuthProviderKind.firebase,
          reason: SessionLocalCleanupReason.accountSwitch,
        ),
      );
    } else if (generation == _authTransitionGeneration) {
      _previousUser = user;
      _publishSessionReady(user);
    }
  }

  Future<void> _runLocalCleanupThenPublish({
    required final AuthUser? user,
    required final int generation,
    required final Future<void> Function() cleanup,
  }) async {
    final Completer<void> barrier = Completer<void>();
    _localCleanupBarrier = barrier;
    try {
      await cleanup();
      // A newer auth event arrived while cleanup ran — do not publish stale id.
      if (generation != _authTransitionGeneration) {
        return;
      }
      _previousUser = user;
      _publishSessionReady(user);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'SessionLifecycleCoordinator: local session cleanup failed closed',
        error,
        stackTrace,
      );
      if (generation != _authTransitionGeneration) {
        return;
      }
      // Fail closed: never publish the next identity while previous-user local
      // data may still be present.
      _previousUser = null;
      _publishSessionReady(null);
    } finally {
      if (!barrier.isCompleted) {
        barrier.complete();
      }
      if (identical(_localCleanupBarrier, barrier)) {
        _localCleanupBarrier = null;
      }
    }
  }

  void _publishSessionReady(final AuthUser? user) {
    _sessionReadyUser = user;
    _hasSessionReadyUser = true;
    if (!_sessionReadyFanout.isClosed) {
      _sessionReadyFanout.add(user);
    }
  }
}
