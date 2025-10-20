import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';
import 'package:flutter_bloc_app/features/counter/presentation/helpers/counter_snapshot_utils.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

export 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';

part 'counter_cubit_base.dart';

/// Presenter (Cubit) orchestrating counter state, persistence and timers.
class CounterCubit extends _CounterCubitBase {
  CounterCubit({
    required super.repository,
    final TimerService? timerService,
    final bool startTicker = true,
    final Duration loadDelay = Duration.zero,
    final DateTime Function()? now,
  }) : super(
         timerService: timerService ?? DefaultTimerService(),
         now: now ?? DateTime.now,
         initialLoadDelay: loadDelay,
       ) {
    if (startTicker) {
      _ensureCountdownTickerStarted();
    }
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
}
