part of 'production_readiness_cubit.dart';

mixin _ProductionReadinessCubitConsent on _ProductionReadinessCubitBase {
  Future<void> setAnalyticsConsent({required final bool enabled}) async {
    await _consentRepository.save(enabled: enabled);
    await _analytics.setCollectionEnabled(enabled: enabled);
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        analyticsConsentEnabled: enabled,
        localEventCount: _memoryAnalytics?.eventCount ?? 0,
      ),
    );
  }

  void _subscribeToConsentChanges() {
    registerSubscription(
      _consentRepository.changes.listen(
        (final bool enabled) {
          if (isClosed) {
            return;
          }
          unawaited(_applyExternalConsent(enabled: enabled));
        },
        onError: (final Object _, final StackTrace _) {
          // Consent stream errors are non-fatal; keep last known toggle state.
        },
      ),
    );
  }

  Future<void> _applyExternalConsent({required final bool enabled}) async {
    await _analytics.setCollectionEnabled(enabled: enabled);
    if (isClosed || state.analyticsConsentEnabled == enabled) {
      return;
    }
    emit(
      state.copyWith(
        analyticsConsentEnabled: enabled,
        localEventCount: _memoryAnalytics?.eventCount ?? 0,
      ),
    );
  }
}
