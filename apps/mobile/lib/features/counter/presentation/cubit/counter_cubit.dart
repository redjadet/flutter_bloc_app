import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/app/utils/bloc/state_restoration_mixin.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_snapshot_utils.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_state.dart';

export 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_state.dart';

part 'counter_cubit_base.dart';
part 'counter_cubit_load.part.dart';
part 'counter_cubit_sync.part.dart';

/// Cubit that orchestrates counter state, persistence, and timers.
class CounterCubit extends _CounterCubitBase
    with _CounterCubitSyncMixin, _CounterCubitLoadMixin {
  CounterCubit({
    required super.repository,
    required super.timerService,
    final bool startTicker = true,
    final Duration loadDelay = Duration.zero,
    final DateTime Function()? now,
    final Duration? manualThrottle,
  }) : _manualThrottleDuration = manualThrottle ?? _manualThrottle,
       super(
         now: now ?? DateTime.now,
         initialLoadDelay: loadDelay,
       ) {
    if (startTicker) {
      _ensureCountdownTickerStarted();
    }
  }

  /// Throttle for manual +/− button taps only (not auto-decrement or restore).
  static const Duration _manualThrottle = Duration(milliseconds: 500);
  final Duration _manualThrottleDuration;
  DateTime? _lastManualChangeAt;

  @override
  Future<void> close() async {
    _initialLoadHandle?.dispose();
    unregisterTimer(_initialLoadHandle);
    _initialLoadHandle = null;
    _stopCountdownTicker();
    _repositorySubscription = null;
    await super.close();
  }

  Future<void> increment() async {
    if (!_beginManualChange()) {
      return;
    }
    _markLocalMutation();
    final CounterState next = _emitCountUpdate(count: state.count + 1);
    await _persistState(next);
  }

  Future<void> decrement() async {
    final CounterState current = state;
    if (current.count == 0) {
      _markLocalMutation();
      if (isClosed) return;
      // Clear error first when already set so listener sees a transition and
      // shows the snackbar again on every decrement attempt at zero.
      if (current.error?.type == CounterErrorType.cannotGoBelowZero) {
        emit(current.copyWith(error: null));
        if (isClosed) return;
      }
      emit(state.copyWith(error: const CounterError.cannotGoBelowZero()));
      return;
    }
    if (!_beginManualChange()) {
      return;
    }
    _markLocalMutation();
    final int newCount = current.count - 1;
    final CounterState next = _emitCountUpdate(count: newCount);
    await _persistState(next);
  }

  bool _beginManualChange() {
    final DateTime now = _now();
    final DateTime? lastChange = _lastManualChangeAt;
    if (_manualThrottleDuration > Duration.zero &&
        lastChange != null &&
        now.difference(lastChange) < _manualThrottleDuration) {
      return false;
    }
    _lastManualChangeAt = now;
    return true;
  }

  void _markLocalMutation() {
    _localMutationRevision++;
  }

  void clearError() {
    if (state.error == null) {
      return;
    }
    if (isClosed) return;

    // Reset status only when we previously exposed the error state.
    final CounterState next = state.status.isInitial
        ? state.copyWith(error: null)
        : state.copyWith(error: null, status: ViewStatus.initial);
    emit(next);
    _syncTickerForState(next);
  }

  void pauseAutoDecrement() {
    _isLifecyclePaused = true;
    _stopCountdownTicker();
  }

  void resumeAutoDecrement() {
    _isLifecyclePaused = false;
    _syncTickerForState(state);
  }

  @override
  Future<void> _persistState(final CounterState snapshotState) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.save(
        CounterSnapshot(
          count: snapshotState.count,
          lastChanged: snapshotState.lastChanged,
        ),
      ),
      isAlive: () => !isClosed,
      onError: (_) {},
      logContext: 'CounterCubit._persistState',
      onErrorWithDetails: (final error, final stackTrace) {
        _handleError(
          error,
          stackTrace ?? StackTrace.current,
          CounterError.save,
          'CounterCubit._persistState failed',
        );
      },
    );
    await refreshPendingSyncCount();
  }
}
