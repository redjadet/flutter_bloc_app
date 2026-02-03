part of 'counter_cubit.dart';

abstract class _CounterCubitBase extends Cubit<CounterState>
    with
        CubitSubscriptionMixin<CounterState>,
        StateRestorationMixin<CounterState> {
  _CounterCubitBase({
    required final CounterRepository repository,
    required final TimerService timerService,
    required final DateTime Function() now,
    required final Duration initialLoadDelay,
  }) : _repository = repository,
       _timerService = timerService,
       _now = now,
       _initialLoadDelay = initialLoadDelay,
       super(const CounterState(count: 0));

  // Default auto-decrement interval used on load and manual interactions.
  static const int _defaultIntervalSeconds =
      CounterState.defaultCountdownSeconds;
  // Timer intervals
  static const Duration _countdownTickInterval = Duration(seconds: 1);
  static const int _countdownTickThreshold = 1;

  final CounterRepository _repository;
  final TimerService _timerService;
  final DateTime Function() _now;
  final Duration _initialLoadDelay;

  TimerDisposable? _countdownTicker;
  // ignore: cancel_subscriptions - Subscription is managed by CubitSubscriptionMixin
  StreamSubscription<CounterSnapshot>? _repositorySubscription;
  // Ensures the countdown stays at the full value for one tick after a reset
  // so the progress bar remains visually consistent.
  bool _pauseCountdownForOneTick = false;
  bool _isLifecyclePaused = false;

  /// Starts the 1s countdown ticker if not already running.
  void _ensureCountdownTickerStarted() {
    if (_isLifecyclePaused || state.count <= 0 || state.status.isError) {
      return;
    }
    _countdownTicker ??= _timerService.periodic(_countdownTickInterval, () {
      // Check if cubit is closed before emitting to prevent errors
      if (isClosed) return;
      if (_pauseCountdownForOneTick) {
        _pauseCountdownForOneTick = false;
        _emitCountdown(state.countdownSeconds);
        return;
      }

      final CounterState current = state;
      final int remaining = current.countdownSeconds;
      if (remaining > _countdownTickThreshold) {
        _emitCountdown(remaining - 1);
        return;
      }

      if (current.count > 0) {
        _handleAutoDecrement();
      } else {
        _resetCountdownAndHold();
      }
    });
  }

  void _stopCountdownTicker() {
    _countdownTicker?.dispose();
    _countdownTicker = null;
  }

  void _syncTickerForState(final CounterState nextState) {
    if (_isLifecyclePaused) {
      return;
    }
    if (nextState.count > 0 && !nextState.status.isError) {
      _ensureCountdownTickerStarted();
    } else {
      _stopCountdownTicker();
    }
  }

  /// Emits state with the provided countdown, preserving other fields.
  void _emitCountdown(final int seconds) {
    if (isClosed) return;
    emit(state.copyWith(countdownSeconds: seconds));
  }

  /// Emits a success state normalizing countdown, timestamp and activation flag.
  CounterState _emitCountUpdate({
    required final int count,
    final DateTime? timestamp,
  }) {
    if (isClosed) {
      // Return current state if cubit is closed to prevent errors
      return state;
    }
    _pauseCountdownForOneTick = false;
    final CounterError? existingError = state.error;
    final bool preserveError =
        existingError != null &&
        existingError.type != CounterErrorType.cannotGoBelowZero;
    final CounterState next = state.copyWith(
      count: count,
      lastChanged: timestamp ?? _now(),
      lastSyncedAt: state.lastSyncedAt,
      changeId: state.changeId,
      countdownSeconds: _defaultIntervalSeconds,
      status: preserveError ? ViewStatus.error : ViewStatus.success,
      error: preserveError ? existingError : null,
    );
    emit(next);
    _syncTickerForState(next);
    return next;
  }

  /// Handles the auto-decrement cycle and resets the countdown.
  void _handleAutoDecrement() {
    final CounterState current = state;
    if (current.count <= 0) {
      _resetCountdownAndHold();
      return;
    }
    final int decremented = current.count - 1;
    final CounterState next = _emitCountUpdate(count: decremented);
    unawaited(_persistState(next));
  }

  /// Resets to the default interval and holds one tick at that value when inactive.
  void _resetCountdownAndHold() {
    if (isClosed) return;
    _pauseCountdownForOneTick = true;
    final CounterState next = state.copyWith(
      countdownSeconds: _defaultIntervalSeconds,
    );
    emit(next);
    _syncTickerForState(next);
  }

  Future<void> _persistState(final CounterState snapshotState) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.save(
        CounterSnapshot(
          count: snapshotState.count,
          lastChanged: snapshotState.lastChanged,
          lastSyncedAt: snapshotState.lastSyncedAt,
          changeId: snapshotState.changeId,
        ),
      ),
      onError: (_) {},
      onErrorWithDetails: (final error, final stackTrace) {
        _handleError(
          error,
          stackTrace ?? StackTrace.current,
          CounterError.save,
          'CounterCubit._persistState failed',
        );
      },
      logContext: 'CounterCubit._persistState',
    );
  }

  void _handleError(
    final Object error,
    final StackTrace stackTrace,
    final CounterError Function({Object? originalError}) errorFactory,
    final String message,
  ) {
    AppLogger.error(message, error, stackTrace);
    if (isClosed) return;
    final CounterError counterError = error is CounterError
        ? error
        : errorFactory(originalError: error);
    emit(state.copyWith(error: counterError, status: ViewStatus.error));
    _stopCountdownTicker();
  }

  void _subscribeToRepository() {
    // Store old subscription and nullify reference to prevent race conditions
    final StreamSubscription<CounterSnapshot>? oldSubscription =
        _repositorySubscription;
    _repositorySubscription = null;
    // Cancel old subscription asynchronously (don't await to avoid blocking)
    unawaited(oldSubscription?.cancel());
    // Set up new subscription immediately
    _repositorySubscription = _repository.watch().listen(
      (final snapshot) {
        // Check if cubit is closed before emitting to prevent errors
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
          ),
        );
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error('CounterCubit.watch failed', error, stackTrace);
      },
    );
    registerSubscription(_repositorySubscription);
  }
}
