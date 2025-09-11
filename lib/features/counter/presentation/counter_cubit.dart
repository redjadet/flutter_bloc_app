import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/data/counter_data.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

export 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';

/// Presenter (Cubit) orchestrating counter state, persistence and timers.
class CounterCubit extends Cubit<CounterState> {
  CounterCubit({CounterRepository? repository, bool startTicker = true})
    : _repository = repository ?? SharedPreferencesCounterRepository(),
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
  static const int _defaultIntervalSeconds = 5;
  // Randomized interval constraints: must be > 1 and <= 5.
  static const int _randomMinSeconds = 2; // inclusive
  static const int _randomMaxSeconds = 5; // inclusive

  // Timer intervals
  static const Duration _countdownTickInterval = Duration(seconds: 1);

  final CounterRepository _repository;

  Timer? _countdownTicker;
  bool _holdAfterReset = false;
  final Random _random = Random();
  int _currentIntervalSeconds = _defaultIntervalSeconds;

  /// Returns the next randomized interval in [_randomMinSeconds, _randomMaxSeconds].
  int _nextRandomIntervalSeconds() {
    return _randomMinSeconds +
        _random.nextInt(_randomMaxSeconds - _randomMinSeconds + 1);
  }

  /// Starts the 1s countdown ticker if not already running.
  void _ensureCountdownTickerStarted() {
    _countdownTicker ??= Timer.periodic(_countdownTickInterval, (_) {
      if (_holdAfterReset) {
        _holdAfterReset = false;
        _emitCountdown(state.countdownSeconds);
        return;
      }

      final int remaining = state.countdownSeconds;
      if (remaining > 1) {
        _emitCountdown(remaining - 1);
        return;
      }

      // Reaches zero now.
      if (state.count > 0) {
        _handleAutoDecrement();
      } else {
        _resetToDefaultIntervalAndHold();
      }
    });
  }

  /// Emits state with the provided countdown, preserving other fields.
  void _emitCountdown(int seconds) {
    emit(state.copyWith(countdownSeconds: seconds));
  }

  /// Handles the auto-decrement cycle and schedules next randomized interval.
  void _handleAutoDecrement() {
    final int decremented = state.count - 1;
    _currentIntervalSeconds = _nextRandomIntervalSeconds();
    emit(
      CounterState(
        count: decremented,
        lastChanged: DateTime.now(),
        countdownSeconds: _currentIntervalSeconds,
        isAutoDecrementActive: decremented > 0,
        status: CounterStatus.success,
      ),
    );
    _persistCurrent();
  }

  /// Resets to the default interval and holds one tick at that value when inactive.
  void _resetToDefaultIntervalAndHold() {
    _currentIntervalSeconds = _defaultIntervalSeconds;
    _holdAfterReset = true;
    emit(
      state.copyWith(
        countdownSeconds: _currentIntervalSeconds,
        isAutoDecrementActive: false,
      ),
    );
  }

  Future<void> loadInitial() async {
    try {
      emit(state.copyWith(status: CounterStatus.loading));
      final CounterSnapshot snapshot = await _repository.load();
      _currentIntervalSeconds = _defaultIntervalSeconds;
      emit(
        CounterState(
          count: snapshot.count,
          lastChanged: snapshot.lastChanged,
          countdownSeconds: _currentIntervalSeconds,
          isAutoDecrementActive: snapshot.count > 0,
          status: CounterStatus.success,
        ),
      );
      _ensureCountdownTickerStarted();
    } catch (e, s) {
      AppLogger.error('CounterCubit.loadInitial failed', e, s);
      emit(
        state.copyWith(
          error: CounterError.loadError(e),
          status: CounterStatus.error,
        ),
      );
    }
  }

  Future<void> _persistCurrent() async {
    try {
      await _repository.save(
        CounterSnapshot(count: state.count, lastChanged: state.lastChanged),
      );
    } catch (e, s) {
      AppLogger.error('CounterCubit._persistCurrent failed', e, s);
    }
  }

  @override
  Future<void> close() {
    _countdownTicker?.cancel();
    return super.close();
  }

  Future<void> increment() async {
    _currentIntervalSeconds = _defaultIntervalSeconds;
    emit(
      CounterState(
        count: state.count + 1,
        lastChanged: DateTime.now(),
        countdownSeconds: _currentIntervalSeconds,
        status: CounterStatus.success,
      ),
    );
    await _persistCurrent();
    _ensureCountdownTickerStarted();
  }

  Future<void> decrement() async {
    if (state.count == 0) {
      emit(state.copyWith(error: CounterError.cannotGoBelowZero()));
      return;
    }
    final int newCount = state.count - 1;
    _currentIntervalSeconds = _defaultIntervalSeconds;
    emit(
      CounterState(
        count: newCount,
        lastChanged: DateTime.now(),
        countdownSeconds: _currentIntervalSeconds,
        isAutoDecrementActive: newCount > 0,
        status: CounterStatus.success,
      ),
    );
    await _persistCurrent();
    _ensureCountdownTickerStarted();
  }

  void clearError() {
    if (state.error != null) {
      // We intentionally reset status to idle along with clearing the error.
      // ignore: avoid_redundant_argument_values
      emit(state.copyWith(error: null, status: CounterStatus.idle));
    }
  }
}
