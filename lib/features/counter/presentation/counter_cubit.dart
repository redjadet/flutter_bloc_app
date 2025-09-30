import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

export 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';

typedef _RestorationResult = ({
  CounterState state,
  bool shouldPersist,
  bool holdCountdown,
});

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
    // Ensure first emission occurs after listeners subscribe.
    Future.microtask(() {
      if (!isClosed) {
        emit(state.copyWith());
      }
    });
    if (startTicker) {
      _ensureCountdownTickerStarted();
    }
  }

  // Default auto-decrement interval used on load and manual interactions.
  static const int _defaultIntervalSeconds =
      CounterState.defaultCountdownSeconds;
  // Timer intervals
  static const Duration _countdownTickInterval = Duration(seconds: 1);

  final CounterRepository _repository;
  final TimerService _timerService;
  final DateTime Function() _now;
  final Duration _initialLoadDelay;

  TimerDisposable? _countdownTicker;
  StreamSubscription<CounterSnapshot>? _repositorySubscription;
  // Ensures the countdown stays at the full value for one tick after a reset
  // so the progress bar remains visually consistent.
  bool _holdCountdownAtFullCycle = false;
  bool _isLifecyclePaused = false;

  /// Starts the 1s countdown ticker if not already running.
  void _ensureCountdownTickerStarted() {
    if (_isLifecyclePaused) {
      return;
    }
    _countdownTicker ??= _timerService.periodic(_countdownTickInterval, () {
      if (_holdCountdownAtFullCycle) {
        _holdCountdownAtFullCycle = false;
        _emitCountdown(state.countdownSeconds);
        return;
      }

      final CounterState current = state;
      final int remaining = current.countdownSeconds;
      if (remaining > 1) {
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

  /// Emits state with the provided countdown, preserving other fields.
  void _emitCountdown(int seconds) {
    emit(state.copyWith(countdownSeconds: seconds));
  }

  /// Emits a success state normalizing countdown, timestamp and activation flag.
  CounterState _emitCountUpdate({required int count, DateTime? timestamp}) {
    _holdCountdownAtFullCycle = false;
    final CounterState next = CounterState.success(
      count: count,
      lastChanged: timestamp ?? _now(),
    );
    emit(next);
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
    _persistState(next);
  }

  /// Resets to the default interval and holds one tick at that value when inactive.
  void _resetCountdownAndHold() {
    _holdCountdownAtFullCycle = true;
    emit(
      state.copyWith(
        countdownSeconds: _defaultIntervalSeconds,
        isAutoDecrementActive: false,
      ),
    );
  }

  Future<void> loadInitial() async {
    try {
      emit(state.copyWith(status: CounterStatus.loading));
      if (_initialLoadDelay > Duration.zero) {
        await Future<void>.delayed(_initialLoadDelay);
      }
      final CounterSnapshot snapshot = await _repository.load();
      final _RestorationResult restoration = _restoreStateFromSnapshot(
        snapshot,
        now: _now(),
      );
      _holdCountdownAtFullCycle = restoration.holdCountdown;
      emit(restoration.state);
      _ensureCountdownTickerStarted();
      if (restoration.shouldPersist) {
        await _persistState(restoration.state);
      }
      _subscribeToRepository();
    } catch (e, s) {
      AppLogger.error('CounterCubit.loadInitial failed', e, s);
      emit(
        state.copyWith(
          error: CounterError.load(originalError: e),
          status: CounterStatus.error,
        ),
      );
    }
  }

  _RestorationResult _restoreStateFromSnapshot(
    CounterSnapshot snapshot, {
    required DateTime now,
  }) {
    final int safeCount = snapshot.count < 0 ? 0 : snapshot.count;
    final DateTime? lastChanged = snapshot.lastChanged;
    bool holdCountdown = false;
    bool shouldPersist = safeCount != snapshot.count;

    if (lastChanged == null) {
      return (
        state: CounterState.success(count: safeCount),
        shouldPersist: shouldPersist,
        holdCountdown: holdCountdown,
      );
    }

    if (safeCount == 0) {
      holdCountdown = true;
      return (
        state: CounterState.success(count: 0, lastChanged: lastChanged),
        shouldPersist: shouldPersist,
        holdCountdown: holdCountdown,
      );
    }

    final Duration elapsed = now.difference(lastChanged);
    if (elapsed.inSeconds <= 0) {
      return (
        state: CounterState.success(count: safeCount, lastChanged: lastChanged),
        shouldPersist: shouldPersist,
        holdCountdown: holdCountdown,
      );
    }

    final int elapsedSeconds = elapsed.inSeconds;
    final int intervalsElapsed = elapsedSeconds ~/ _defaultIntervalSeconds;
    final int decrements = intervalsElapsed > safeCount
        ? safeCount
        : intervalsElapsed;
    final int newCount = safeCount - decrements;
    final DateTime resolvedLastChanged = lastChanged.add(
      Duration(seconds: decrements * _defaultIntervalSeconds),
    );

    shouldPersist = shouldPersist || decrements > 0;

    if (newCount == 0) {
      holdCountdown = true;
      return (
        state: CounterState.success(count: 0, lastChanged: resolvedLastChanged),
        shouldPersist: shouldPersist,
        holdCountdown: holdCountdown,
      );
    }

    final int remainderSeconds =
        elapsedSeconds - (decrements * _defaultIntervalSeconds);
    final int countdownSeconds = remainderSeconds == 0
        ? _defaultIntervalSeconds
        : _defaultIntervalSeconds - remainderSeconds;

    return (
      state: CounterState.success(
        count: newCount,
        lastChanged: resolvedLastChanged,
        countdownSeconds: countdownSeconds,
      ),
      shouldPersist: shouldPersist,
      holdCountdown: holdCountdown,
    );
  }

  Future<void> _persistState(CounterState snapshotState) async {
    try {
      await _repository.save(
        CounterSnapshot(
          count: snapshotState.count,
          lastChanged: snapshotState.lastChanged,
        ),
      );
    } catch (e, s) {
      AppLogger.error('CounterCubit._persistState failed', e, s);
      emit(
        state.copyWith(
          error: CounterError.save(originalError: e),
          status: CounterStatus.error,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _countdownTicker?.dispose();
    _repositorySubscription?.cancel();
    return super.close();
  }

  Future<void> increment() async {
    final CounterState next = _emitCountUpdate(count: state.count + 1);
    await _persistState(next);
    _ensureCountdownTickerStarted();
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
    _ensureCountdownTickerStarted();
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
    _countdownTicker?.dispose();
    _countdownTicker = null;
  }

  void resumeAutoDecrement() {
    _isLifecyclePaused = false;
    _ensureCountdownTickerStarted();
  }

  void _subscribeToRepository() {
    _repositorySubscription?.cancel();
    _repositorySubscription = _repository.watch().listen(
      (CounterSnapshot snapshot) {
        if (_shouldIgnoreRemoteSnapshot(snapshot)) {
          return;
        }
        final _RestorationResult restoration = _restoreStateFromSnapshot(
          snapshot,
          now: _now(),
        );
        _holdCountdownAtFullCycle = restoration.holdCountdown;
        emit(restoration.state);
      },
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error('CounterCubit.watch failed', error, stackTrace);
      },
    );
  }

  bool _shouldIgnoreRemoteSnapshot(CounterSnapshot snapshot) {
    final CounterState current = state;
    final bool countsEqual = snapshot.count == current.count;
    final bool timestampsEqual = () {
      final DateTime? a = snapshot.lastChanged;
      final DateTime? b = current.lastChanged;
      if (a == null && b == null) return true;
      if (a == null || b == null) return false;
      return a.millisecondsSinceEpoch == b.millisecondsSinceEpoch;
    }();
    return countsEqual && timestampsEqual;
  }
}
