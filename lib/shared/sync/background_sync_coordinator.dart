import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_cycle_summary.dart';
import 'package:flutter_bloc_app/shared/sync/sync_job_runner.dart';
import 'package:flutter_bloc_app/shared/sync/sync_schedule_policy.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/stream_controller_lifecycle.dart';
import 'package:flutter_bloc_app/shared/utils/timer_handle_manager.dart';

export 'sync_cycle_summary.dart';

part 'background_sync_coordinator_lifecycle.dart';
part 'background_sync_coordinator_loop.dart';

enum BackgroundSyncTriggerSource {
  /// Explicit push notification request (FCM).
  fcm,
}

class BackgroundSyncTrigger {
  const BackgroundSyncTrigger({
    required this.source,
    this.hint,
  });

  final BackgroundSyncTriggerSource source;

  /// Optional hint for future feature/resource targeting.
  final String? hint;
}

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
    final SyncJobRunner? syncJobRunner,
    final SyncSchedulePolicy? syncSchedulePolicy,
  }) : _repository = repository,
       _networkStatusService = networkStatusService,
       _timerService = timerService,
       _getSyncSupabaseUserId = getSyncSupabaseUserId,
       _syncInterval = syncInterval,
       _telemetry = telemetry ?? _defaultTelemetry,
       _maxHistory = maxHistory,
       _maxRetryCount = maxRetryCount,
       _maxOperationAge = maxOperationAge,
       _startIotDemoRealtimeSubscription = startIotDemoRealtimeSubscription,
       _stopIotDemoRealtimeSubscription = stopIotDemoRealtimeSubscription,
       _syncJobRunner =
           syncJobRunner ??
           SyncJobRunner(
             registry: registry,
             pendingRepository: repository,
           ),
       _syncSchedulePolicy = syncSchedulePolicy ?? const SyncSchedulePolicy();

  final PendingSyncRepository _repository;
  final SyncJobRunner _syncJobRunner;
  final SyncSchedulePolicy _syncSchedulePolicy;
  final String? Function()? _getSyncSupabaseUserId;
  final NetworkStatusService _networkStatusService;
  final TimerService _timerService;
  final Duration _syncInterval;
  final void Function(String event, Map<String, Object?> payload) _telemetry;
  final int _maxHistory;
  final int _maxRetryCount;
  final Duration _maxOperationAge;
  final void Function(void Function() onSyncRequested)?
  _startIotDemoRealtimeSubscription;
  final void Function()? _stopIotDemoRealtimeSubscription;
  final TimerHandleManager _timerHandles = TimerHandleManager();

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  final StreamController<SyncCycleSummary> _summaryController =
      StreamController<SyncCycleSummary>.broadcast();
  SyncCycleSummary? _latestSummary;
  final List<SyncCycleSummary> _history = <SyncCycleSummary>[];
  // ignore: cancel_subscriptions - Managed explicitly via stop()/dispose() lifecycle helpers.
  StreamSubscription<NetworkStatus>? _networkSubscription;
  // ignore: cancel_subscriptions - Managed explicitly via stop()/dispose() lifecycle helpers.
  StreamSubscription<void>? _enqueueSubscription;
  TimerDisposable? _syncIntervalHandle;
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
    await _bindSyncListeners();
    await _triggerSync(immediate: true);
  }

  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }
    _isRunning = false;
    _syncRequestedAfterCurrent = false;
    final Future<void>? inFlight = _currentSync;
    await _unbindSyncListeners();
    await _awaitInFlightSync(inFlight);
    _emit(SyncStatus.idle);
  }

  Future<void> dispose() async {
    await stop();
    await _timerHandles.dispose();
    await _statusController.close();
    await _summaryController.close();
  }

  Future<void> flush() => _triggerSync(immediate: true);

  /// Trigger a sync run explicitly from an FCM event.
  ///
  /// This is intentionally generic for the first slice: it requests "sync now"
  /// without assuming feature-level payload hints. Callers may provide an
  /// optional [hint] (e.g. feature name or resource key) for telemetry and
  /// future routing.
  Future<void> triggerFromFcm({final String? hint}) {
    _telemetry('sync_trigger_fcm', <String, Object?>{
      'hint': hint,
    });
    return _triggerSync(immediate: true);
  }

  Future<void> _triggerSync({required final bool immediate}) =>
      _triggerSyncImpl(this, immediate: immediate);

  Future<void> _processPendingOperations() async {
    final SyncCycleSummary summary = await _syncJobRunner.run(
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
    StreamControllerSafeEmit.safeAdd(_statusController, status);
  }

  static void _defaultTelemetry(
    final String event,
    final Map<String, Object?> payload,
  ) {
    if (!shouldLogTelemetry(event, payload)) {
      return;
    }
    AppLogger.debug('SyncTelemetry[$event] $payload');
  }

  @visibleForTesting
  static bool shouldLogTelemetry(
    final String event,
    final Map<String, Object?> payload,
  ) {
    if (event == 'sync_prune_completed') {
      return payload['pruned'] != 0;
    }
    if (event != 'sync_cycle_completed') {
      return true;
    }

    return payload['pullRemoteFailures'] != 0 ||
        payload['pendingAtStart'] != 0 ||
        payload['operationsProcessed'] != 0 ||
        payload['operationsFailed'] != 0 ||
        payload['prunedCount'] != 0 ||
        (payload['pendingByEntity'] as Map?)?.isNotEmpty == true ||
        (payload['retryAttemptsByEntity'] as Map?)?.isNotEmpty == true ||
        (payload['lastErrorByEntity'] as Map?)?.isNotEmpty == true;
  }

  void _publishSummary(final SyncCycleSummary summary) {
    _latestSummary = summary;
    _history.add(summary);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
    StreamControllerSafeEmit.safeAdd(_summaryController, summary);
  }
}
