part of 'background_sync_coordinator.dart';

extension _BackgroundSyncCoordinatorSummary on BackgroundSyncCoordinator {
  Future<void> _processPendingOperations() async {
    final SyncCycleSummary summary = await _syncJobRunner.run(
      emitStatus: _emit,
      telemetry: _telemetry,
      supabaseUserIdForUserScopedSync: _getSyncSupabaseUserId?.call(),
    );
    final int pruned = await _repository.prune(
      maxRetryCount: _maxRetryCount,
      maxAge: _maxOperationAge,
    );
    final SyncCycleSummary enriched = summary.copyWith(prunedCount: pruned);
    _telemetry('sync_prune_completed', <String, Object?>{
      'pruned': pruned,
      'maxRetryCount': _maxRetryCount,
      'maxAgeDays': _maxOperationAge.inDays,
    });
    _publishSummary(enriched);
  }

  void _emit(final SyncStatus status) {
    if (_currentStatus == status) {
      return;
    }
    _currentStatus = status;
    StreamControllerSafeEmit.safeAdd(_statusController, status);
  }

  void _publishSummary(final SyncCycleSummary summary) {
    _latestSummary = summary;
    _history.add(summary);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
    StreamControllerSafeEmit.safeAdd(_summaryController, summary);
  }
}
