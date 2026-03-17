part of 'background_sync_coordinator.dart';

Future<void> _triggerSyncImpl(
  final BackgroundSyncCoordinator c, {
  required final bool immediate,
}) {
  final Future<void>? inFlight = c._currentSync;
  if (inFlight != null) {
    if (immediate) {
      c._syncRequestedAfterCurrent = true;
    }
    return inFlight;
  }

  if (!immediate && !c._isRunning) {
    return Future<void>.value();
  }

  final Completer<void> completer = Completer<void>();
  final Future<void> future = completer.future;
  c._currentSync = future;

  unawaited(
    Future<void>(() async {
      try {
        await _runCoalescedSyncImpl(c, immediate: immediate);
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          'BackgroundSyncCoordinator._triggerSync unexpected failure',
          error,
          stackTrace,
        );
        c._emit(SyncStatus.degraded);
      } finally {
        if (!completer.isCompleted) {
          completer.complete();
        }
        if (identical(c._currentSync, future)) {
          c._currentSync = null;
        }
      }
    }),
  );

  return future;
}

Future<void> _runCoalescedSyncImpl(
  final BackgroundSyncCoordinator c, {
  required final bool immediate,
}) async {
  // Coalesce multiple immediate triggers that happen while a sync is running
  // into a single follow-up sync. If another immediate trigger arrives during
  // this sync, the loop will run one more time.
  while (true) {
    if (!immediate && !c._isRunning) {
      return;
    }

    final bool startedTemporarily = !c._isRunning && immediate;
    c._syncRequestedAfterCurrent = false;

    NetworkStatus networkStatus;
    try {
      networkStatus = await c._networkStatusService.getCurrentStatus();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'BackgroundSyncCoordinator._triggerSync network status failed',
        error,
        stackTrace,
      );
      c._emit(SyncStatus.degraded);
      if (startedTemporarily) {
        c._isRunning = false;
      }
      return;
    }
    if (!c._syncSchedulePolicy.shouldRunCycle(
      networkStatus,
      immediate: immediate,
      isRunning: c._isRunning,
    )) {
      AppLogger.debug(
        'BackgroundSyncCoordinator._triggerSync skipped: network offline',
      );
      if (startedTemporarily) {
        c._isRunning = false;
      }
      return;
    }

    if (startedTemporarily) {
      c._isRunning = true;
    }
    try {
      await c._processPendingOperations();
      if (!immediate) {
        c._emit(SyncStatus.idle);
      } else if (startedTemporarily) {
        c._emit(SyncStatus.idle);
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'BackgroundSyncCoordinator._triggerSync failed',
        error,
        stackTrace,
      );
      c._emit(SyncStatus.degraded);
    } finally {
      if (startedTemporarily) {
        c._isRunning = false;
      }
    }

    if (!immediate ||
        !c._syncRequestedAfterCurrent ||
        (!c._isRunning && !startedTemporarily)) {
      return;
    }
  }
}
