part of 'counter_cubit.dart';

mixin _CounterCubitSyncMixin on _CounterCubitBase {
  Future<void> refreshPendingSyncCount() async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        final int count = await _repository.pendingSyncOperationCount();
        if (isClosed) {
          return;
        }
        emit(state.copyWith(pendingSyncCount: count));
      },
      isAlive: () => !isClosed,
      onError: (_) {},
      logContext: 'CounterCubit.refreshPendingSyncCount',
    );
  }

  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries() =>
      _repository.pendingSyncQueueEntries();

  void _subscribeToRepository() {
    final StreamSubscription<CounterSnapshot>? oldSubscription =
        _repositorySubscription;
    _repositorySubscription = null;
    unawaited(cancelRegisteredSubscription(oldSubscription));
    _repositorySubscription = registerSubscription(
      _repository.watch().listen(
        (final snapshot) {
          if (isClosed) return;
          if (shouldIgnoreRemoteSnapshot(state, snapshot)) return;

          final RestorationResult restoration = restoreStateFromSnapshot(
            snapshot,
          );
          unawaited(
            applyRestorationOutcome(
              restoration,
              onHoldChanged: ({required final holdSideEffects}) =>
                  _pauseCountdownForOneTick = holdSideEffects,
              onAfterEmit: _syncTickerForState,
              logContext: 'CounterCubit._subscribeToRepository',
            ).then((_) => refreshPendingSyncCount()),
          );
        },
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error('CounterCubit.watch failed', error, stackTrace);
        },
      ),
    );
  }
}
