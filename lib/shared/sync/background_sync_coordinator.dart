import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_runner.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_cycle_summary.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

export 'sync_cycle_summary.dart';

class BackgroundSyncCoordinator {
  BackgroundSyncCoordinator({
    required final PendingSyncRepository repository,
    required final NetworkStatusService networkStatusService,
    required final TimerService timerService,
    required final SyncableRepositoryRegistry registry,
    final String? Function()? getSyncSupabaseUserId,
    final Duration syncInterval = const Duration(seconds: 60),
    final void Function(String event, Map<String, Object?> payload)? telemetry,
    final int maxHistory = 5,
    final int maxRetryCount = 10,
    final Duration maxOperationAge = const Duration(days: 30),
    final void Function(void Function() onSyncRequested)?
    startIotDemoRealtimeSubscription,
    final void Function()? stopIotDemoRealtimeSubscription,
  }) : _repository = repository,
       _networkStatusService = networkStatusService,
       _timerService = timerService,
       _registry = registry,
       _getSyncSupabaseUserId = getSyncSupabaseUserId,
       _syncInterval = syncInterval,
       _telemetry = telemetry ?? _defaultTelemetry,
       _maxHistory = maxHistory,
       _maxRetryCount = maxRetryCount,
       _maxOperationAge = maxOperationAge,
       _startIotDemoRealtimeSubscription = startIotDemoRealtimeSubscription,
       _stopIotDemoRealtimeSubscription = stopIotDemoRealtimeSubscription;

  final PendingSyncRepository _repository;
  final String? Function()? _getSyncSupabaseUserId;
  final NetworkStatusService _networkStatusService;
  final TimerService _timerService;
  final SyncableRepositoryRegistry _registry;
  final Duration _syncInterval;
  final void Function(String event, Map<String, Object?> payload) _telemetry;
  final int _maxHistory;
  final int _maxRetryCount;
  final Duration _maxOperationAge;
  final void Function(void Function() onSyncRequested)?
  _startIotDemoRealtimeSubscription;
  final void Function()? _stopIotDemoRealtimeSubscription;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  final StreamController<SyncCycleSummary> _summaryController =
      StreamController<SyncCycleSummary>.broadcast();
  SyncCycleSummary? _latestSummary;
  final List<SyncCycleSummary> _history = <SyncCycleSummary>[];
  StreamSubscription<NetworkStatus>? _networkSubscription;
  StreamSubscription<void>? _enqueueSubscription;
  TimerDisposable? _periodicTimer;
  Future<void>? _currentSync;
  bool _syncRequestedAfterCurrent = false;
  bool _isRunning = false;
  SyncStatus _currentStatus = SyncStatus.idle;

  Stream<SyncStatus> get statusStream => _statusController.stream.distinct();
  SyncStatus get currentStatus => _currentStatus;
  Stream<SyncCycleSummary> get summaryStream =>
      _summaryController.stream.distinct();
  SyncCycleSummary? get latestSummary => _latestSummary;
  List<SyncCycleSummary> get history =>
      List<SyncCycleSummary>.unmodifiable(_history);

  Future<void> ensureStarted() async {
    if (_isRunning) {
      return;
    }
    await start();
  }

  Future<void> start() async {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    _telemetry('sync_start', <String, Object?>{
      'intervalSeconds': _syncInterval.inSeconds,
    });
    await _networkSubscription?.cancel();
    _networkSubscription = _networkStatusService.statusStream.listen(
      (final status) {
        if (status == NetworkStatus.online) {
          unawaited(_triggerSync(immediate: true));
        }
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'BackgroundSyncCoordinator.networkSubscription failed',
          error,
          stackTrace,
        );
        _emit(SyncStatus.degraded);
      },
    );
    _periodicTimer = _timerService.periodic(
      _syncInterval,
      () => unawaited(_triggerSync(immediate: false)),
    );
    await _enqueueSubscription?.cancel();
    _enqueueSubscription = _repository.onOperationEnqueued.listen(
      (_) => unawaited(_triggerSync(immediate: true)),
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'BackgroundSyncCoordinator.enqueueSubscription failed',
          error,
          stackTrace,
        );
        _emit(SyncStatus.degraded);
      },
      cancelOnError: false,
    );
    _startIotDemoRealtimeSubscription?.call(
      () => unawaited(_triggerSync(immediate: true)),
    );
    await _triggerSync(immediate: true);
  }

  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }
    _isRunning = false;
    _syncRequestedAfterCurrent = false;
    final Future<void>? inFlight = _currentSync;
    _periodicTimer?.dispose();
    _periodicTimer = null;
    await _enqueueSubscription?.cancel();
    _enqueueSubscription = null;
    _stopIotDemoRealtimeSubscription?.call();
    await _networkSubscription?.cancel();
    _networkSubscription = null;
    if (inFlight != null) {
      try {
        await inFlight;
      } on Exception {
        // Ignore errors from in-flight sync during shutdown
      }
    }
    _emit(SyncStatus.idle);
  }

  Future<void> dispose() async {
    await stop();
    await _statusController.close();
    await _summaryController.close();
  }

  Future<void> flush() => _triggerSync(immediate: true);

  Future<void> _triggerSync({required final bool immediate}) {
    final Future<void>? inFlight = _currentSync;
    if (inFlight != null) {
      if (immediate) {
        _syncRequestedAfterCurrent = true;
      }
      return inFlight;
    }

    if (!immediate && !_isRunning) {
      return Future<void>.value();
    }

    final Completer<void> completer = Completer<void>();
    final Future<void> future = completer.future;
    _currentSync = future;

    unawaited(
      Future<void>(() async {
        try {
          await _runCoalescedSync(immediate: immediate);
        } on Object catch (error, stackTrace) {
          AppLogger.error(
            'BackgroundSyncCoordinator._triggerSync unexpected failure',
            error,
            stackTrace,
          );
          _emit(SyncStatus.degraded);
        } finally {
          if (!completer.isCompleted) {
            completer.complete();
          }
          if (identical(_currentSync, future)) {
            _currentSync = null;
          }
        }
      }),
    );

    return future;
  }

  Future<void> _runCoalescedSync({required final bool immediate}) async {
    // Coalesce multiple immediate triggers that happen while a sync is running
    // into a single follow-up sync. If another immediate trigger arrives during
    // this sync, the loop will run one more time.
    while (true) {
      if (!immediate && !_isRunning) {
        return;
      }

      final bool startedTemporarily = !_isRunning && immediate;
      _syncRequestedAfterCurrent = false;

      // Check network status before attempting sync (per Flutter's guidance)
      NetworkStatus networkStatus;
      try {
        networkStatus = await _networkStatusService.getCurrentStatus();
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          'BackgroundSyncCoordinator._triggerSync network status failed',
          error,
          stackTrace,
        );
        _emit(SyncStatus.degraded);
        if (startedTemporarily) {
          _isRunning = false;
        }
        return;
      }
      if (networkStatus != NetworkStatus.online) {
        AppLogger.debug(
          'BackgroundSyncCoordinator._triggerSync skipped: network offline',
        );
        if (startedTemporarily) {
          _isRunning = false;
        }
        return;
      }

      if (startedTemporarily) {
        _isRunning = true;
      }
      try {
        await _processPendingOperations();
        if (!immediate) {
          _emit(SyncStatus.idle);
        } else if (startedTemporarily) {
          _emit(SyncStatus.idle);
        }
      } on Object catch (error, stackTrace) {
        AppLogger.error(
          'BackgroundSyncCoordinator._triggerSync failed',
          error,
          stackTrace,
        );
        _emit(SyncStatus.degraded);
      } finally {
        if (startedTemporarily) {
          _isRunning = false;
        }
      }

      if (!immediate ||
          !_syncRequestedAfterCurrent ||
          (!_isRunning && !startedTemporarily)) {
        return;
      }
    }
  }

  Future<void> _processPendingOperations() async {
    final SyncCycleSummary summary = await runSyncCycle(
      registry: _registry,
      pendingRepository: _repository,
      emitStatus: _emit,
      telemetry: _telemetry,
      supabaseUserIdForUserScopedSync: _getSyncSupabaseUserId?.call(),
    );
    final int pruned = await _repository.prune(
      maxRetryCount: _maxRetryCount,
      maxAge: _maxOperationAge,
    );
    final SyncCycleSummary enriched = summary.copyWith(prunedCount: pruned);
    _telemetry(
      'sync_prune_completed',
      <String, Object?>{
        'pruned': pruned,
        'maxRetryCount': _maxRetryCount,
        'maxAgeDays': _maxOperationAge.inDays,
      },
    );
    _publishSummary(enriched);
  }

  void _emit(final SyncStatus status) {
    if (_currentStatus == status) {
      return;
    }
    _currentStatus = status;
    if (_statusController.isClosed) {
      return;
    }
    _statusController.add(status);
  }

  static void _defaultTelemetry(
    final String event,
    final Map<String, Object?> payload,
  ) {
    AppLogger.debug('SyncTelemetry[$event] $payload');
  }

  void _publishSummary(final SyncCycleSummary summary) {
    _latestSummary = summary;
    _history.add(summary);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
    if (_summaryController.isClosed) {
      return;
    }
    _summaryController.add(summary);
  }
}
