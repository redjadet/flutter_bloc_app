part of 'counter_cubit.dart';

abstract class _CounterCubitBase extends Cubit<CounterState> {
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
  StreamSubscription<CounterSnapshot>? _repositorySubscription;
  // Ensures the countdown stays at the full value for one tick after a reset
  // so the progress bar remains visually consistent.
  bool _pauseCountdownForOneTick = false;
  bool _isLifecyclePaused = false;

  /// Starts the 1s countdown ticker if not already running.
  void _ensureCountdownTickerStarted() {
    if (_isLifecyclePaused ||
        state.count <= 0 ||
        state.status == CounterStatus.error) {
      return;
    }
    _countdownTicker ??= _timerService.periodic(_countdownTickInterval, () {
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
    if (nextState.count > 0 && nextState.status != CounterStatus.error) {
      _ensureCountdownTickerStarted();
    } else {
      _stopCountdownTicker();
    }
  }

  /// Emits state with the provided countdown, preserving other fields.
  void _emitCountdown(final int seconds) {
    emit(state.copyWith(countdownSeconds: seconds));
  }

  /// Emits a success state normalizing countdown, timestamp and activation flag.
  CounterState _emitCountUpdate({
    required final int count,
    final DateTime? timestamp,
  }) {
    _pauseCountdownForOneTick = false;
    final bool hasError = state.error != null;
    final CounterState next = state.copyWith(
      count: count,
      lastChanged: timestamp ?? _now(),
      countdownSeconds: _defaultIntervalSeconds,
      status: hasError ? CounterStatus.error : CounterStatus.success,
      error: hasError ? state.error : null,
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
    _pauseCountdownForOneTick = true;
    final CounterState next = state.copyWith(
      countdownSeconds: _defaultIntervalSeconds,
    );
    emit(next);
    _syncTickerForState(next);
  }

  Future<void> _persistState(final CounterState snapshotState) async {
    try {
      await _repository.save(
        CounterSnapshot(
          count: snapshotState.count,
          lastChanged: snapshotState.lastChanged,
        ),
      );
    } on CounterError catch (error, stackTrace) {
      _handleError(
        error,
        stackTrace,
        CounterError.save,
        'CounterCubit._persistState failed',
      );
    } on Exception catch (error, stackTrace) {
      _handleError(
        error,
        stackTrace,
        CounterError.save,
        'CounterCubit._persistState failed',
      );
    }
  }

  void _handleError(
    final Object error,
    final StackTrace stackTrace,
    final CounterError Function({Object? originalError}) errorFactory,
    final String message,
  ) {
    AppLogger.error(message, error, stackTrace);
    final CounterError counterError = error is CounterError
        ? error
        : errorFactory(originalError: error);
    emit(state.copyWith(error: counterError, status: CounterStatus.error));
    _stopCountdownTicker();
  }

  void _subscribeToRepository() {
    _repositorySubscription?.cancel();
    _repositorySubscription = _repository.watch().listen(
      (final CounterSnapshot snapshot) {
        if (shouldIgnoreRemoteSnapshot(state, snapshot)) {
          return;
        }
        final RestorationResult restoration = restoreStateFromSnapshot(
          snapshot,
        );
        _pauseCountdownForOneTick = restoration.holdCountdown;
        emit(restoration.state);
        _syncTickerForState(restoration.state);
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error('CounterCubit.watch failed', error, stackTrace);
      },
    );
  }
}
