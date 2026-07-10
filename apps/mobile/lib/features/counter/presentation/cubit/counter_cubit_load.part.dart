part of 'counter_cubit.dart';

mixin _CounterCubitLoadMixin on _CounterCubitBase, _CounterCubitSyncMixin {
  Future<void> loadInitial() async {
    final int requestId = ++_initialLoadRequestId;
    final int startingRevision = _localMutationRevision;
    emit(state.asLoading());

    if (_initialLoadDelay > Duration.zero) {
      _initialLoadHandle?.dispose();
      unregisterTimer(_initialLoadHandle);
      late final TimerDisposable handle;
      handle = _timerService.runOnce(_initialLoadDelay, () {
        unregisterTimer(handle);
        if (identical(_initialLoadHandle, handle)) {
          _initialLoadHandle = null;
        }
        if (isClosed) return;
        unawaited(
          _runLoadInitialAfterDelay(
            requestId: requestId,
            startingRevision: startingRevision,
          ),
        );
      });
      _initialLoadHandle = registerTimer(handle);
      return;
    }

    await _runLoadInitialAfterDelay(
      requestId: requestId,
      startingRevision: startingRevision,
    );
  }

  Future<void> _runLoadInitialAfterDelay({
    required final int requestId,
    required final int startingRevision,
  }) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        final CounterSnapshot snapshot = await _repository.load();
        if (isClosed || requestId != _initialLoadRequestId) {
          return;
        }
        if (_localMutationRevision != startingRevision) {
          _subscribeToRepository();
          _finishAbortedInitialLoad();
          return;
        }
        final RestorationResult restoration = restoreStateFromSnapshot(
          snapshot,
        );
        await applyRestorationOutcome(
          restoration,
          onHoldChanged: ({required final holdSideEffects}) =>
              _pauseCountdownForOneTick = holdSideEffects,
          onAfterEmit: _syncTickerForState,
          onPersist: _persistState,
          logContext: 'CounterCubit.loadInitial',
        );
        _subscribeToRepository();
        await refreshPendingSyncCount();
      },
      isAlive: () => !isClosed,
      onError: (_) {},
      logContext: 'CounterCubit.loadInitial',
      onErrorWithDetails: (final error, final stackTrace) {
        _handleError(
          error,
          stackTrace ?? StackTrace.current,
          CounterError.load,
          'CounterCubit.loadInitial failed',
        );
      },
    );
  }

  /// Resolves loading when a late load result is discarded because
  /// the user mutated state while the load was in flight.
  void _finishAbortedInitialLoad() {
    if (!state.isLoading) {
      return;
    }
    final CounterError? error = state.error;
    final CounterState next;
    if (error == null) {
      next = state.asReady();
    } else if (error.type == CounterErrorType.cannotGoBelowZero) {
      next = state.asInitial();
    } else {
      next = state.asFailure(error);
    }
    emit(next);
    _syncTickerForState(next);
  }
}
