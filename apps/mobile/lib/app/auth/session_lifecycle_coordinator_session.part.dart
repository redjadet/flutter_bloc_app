part of 'session_lifecycle_coordinator.dart';

extension _SessionLifecycleCoordinatorSession
    on SessionLifecycleCoordinatorImpl {
  Future<void> onSignOutCompletedBody({
    required final AuthProviderKind provider,
  }) async {
    if (_onSignOutCompletedInFlight != null) {
      return _onSignOutCompletedInFlight!;
    }
    final Completer<void> gate = Completer<void>();
    _onSignOutCompletedInFlight = gate.future;
    try {
      if (provider == AuthProviderKind.firebase) {
        _authTokenManager?.clearCache();
      }
      _tokenRepository?.clearProvider(provider);
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
      await _clearLocalSessionData(
        provider: provider,
        reason: SessionLocalCleanupReason.signOut,
      );
    } finally {
      _onSignOutCompletedInFlight = null;
      if (!gate.isCompleted) {
        gate.complete();
      }
    }
  }

  Future<void> _clearLocalSessionData({
    required final AuthProviderKind provider,
    required final SessionLocalCleanupReason reason,
  }) async {
    final SessionLocalDataCleanup? cleanup = _localSessionDataCleanup;
    if (cleanup == null) {
      return;
    }
    // Fail closed: do not swallow cleanup errors (session gate / callers depend
    // on success before publishing the next authenticated identity).
    await cleanup(provider: provider, reason: reason);
  }

  Future<void> invalidateSessionBody({
    required final AuthProviderKind provider,
    required final SessionInvalidationReason reason,
  }) async {
    if (_invalidationInFlight.contains(provider)) {
      return;
    }
    _invalidationInFlight.add(provider);
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
      _invalidationInFlight.remove(provider);
    }
  }
}
