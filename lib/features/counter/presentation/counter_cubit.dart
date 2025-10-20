import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';
import 'package:flutter_bloc_app/features/counter/presentation/helpers/counter_snapshot_utils.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

export 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';

/// Presenter (Cubit) orchestrating counter state, persistence and timers.
class CounterCubit extends Cubit<CounterState> {
  CounterCubit({
    required CounterRepository repository,
    TimerService? timerService,
    bool startTicker = true,
    Duration loadDelay = Duration.zero,
    DateTime Function()? now,
  }) : _repository = repository,
       _timerService = timerService ?? DefaultTimerService(),
       _now = now ?? DateTime.now,
       _initialLoadDelay = loadDelay,
       super(const CounterState(count: 0)) {
    if (startTicker) {
      _ensureCountdownTickerStarted();
    }
  }

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
    if (_isLifecyclePaused || state.count <= 0) {
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

      // Reaches zero now.
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

  void _syncTickerForState(CounterState nextState) {
    if (_isLifecyclePaused) {
      return;
    }
    if (nextState.count > 0) {
      _ensureCountdownTickerStarted();
    } else {
      _stopCountdownTicker();
    }
  }

  /// Emits state with the provided countdown, preserving other fields.
  void _emitCountdown(int seconds) {
    emit(state.copyWith(countdownSeconds: seconds));
  }

  /// Emits a success state normalizing countdown, timestamp and activation flag.
  CounterState _emitCountUpdate({required int count, DateTime? timestamp}) {
    _pauseCountdownForOneTick = false;
    final CounterState next = CounterState.success(
      count: count,
      lastChanged: timestamp ?? _now(),
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

  Future<void> loadInitial() async {
    try {
      emit(state.copyWith(status: CounterStatus.loading));
      if (_initialLoadDelay > Duration.zero) {
        await Future<void>.delayed(_initialLoadDelay);
      }
      final CounterSnapshot snapshot = await _repository.load();
      final RestorationResult restoration = restoreStateFromSnapshot(snapshot);
      _pauseCountdownForOneTick = restoration.holdCountdown;
      emit(restoration.state);
      _syncTickerForState(restoration.state);
      if (restoration.shouldPersist) {
        await _persistState(restoration.state);
      }
      _subscribeToRepository();
    } on CounterError catch (error, stackTrace) {
      _handleError(
        error,
        stackTrace,
        CounterError.load,
        'CounterCubit.loadInitial failed',
      );
    } on Exception catch (error, stackTrace) {
      _handleError(
        error,
        stackTrace,
        CounterError.load,
        'CounterCubit.loadInitial failed',
      );
    }
  }

  Future<void> _persistState(CounterState snapshotState) async {
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
    Object error,
    StackTrace stackTrace,
    CounterError Function({Object? originalError}) errorFactory,
    String message,
  ) {
    AppLogger.error(message, error, stackTrace);
    final CounterError counterError = error is CounterError
        ? error
        : errorFactory(originalError: error);
    emit(state.copyWith(error: counterError, status: CounterStatus.error));
  }

  @override
  Future<void> close() {
    _stopCountdownTicker();
    _repositorySubscription?.cancel();
    return super.close();
  }

  Future<void> increment() async {
    final CounterState next = _emitCountUpdate(count: state.count + 1);
    await _persistState(next);
  }

  Future<void> decrement() async {
    final CounterState current = state;
    if (current.count == 0) {
      emit(state.copyWith(error: const CounterError.cannotGoBelowZero()));
      return;
    }
    final int newCount = current.count - 1;
    final CounterState next = _emitCountUpdate(count: newCount);
    await _persistState(next);
  }

  void clearError() {
    if (state.error == null) {
      return;
    }

    // Reset status only when we previously exposed the error state.
    final CounterState next = state.status == CounterStatus.idle
        ? state.copyWith(error: null)
        : state.copyWith(error: null, status: CounterStatus.idle);
    emit(next);
  }

  void pauseAutoDecrement() {
    _isLifecyclePaused = true;
    _stopCountdownTicker();
  }

  void resumeAutoDecrement() {
    _isLifecyclePaused = false;
    _syncTickerForState(state);
  }

  void _subscribeToRepository() {
    _repositorySubscription?.cancel();
    _repositorySubscription = _repository.watch().listen(
      (CounterSnapshot snapshot) {
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
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error('CounterCubit.watch failed', error, stackTrace);
      },
    );
  }
}
