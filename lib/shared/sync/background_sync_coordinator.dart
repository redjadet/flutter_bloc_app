import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class BackgroundSyncCoordinator {
  BackgroundSyncCoordinator({
    required PendingSyncRepository repository,
    required NetworkStatusService networkStatusService,
    required TimerService timerService,
    required SyncableRepositoryRegistry registry,
    Duration syncInterval = const Duration(seconds: 60),
  }) : _repository = repository,
       _networkStatusService = networkStatusService,
       _timerService = timerService,
       _registry = registry,
       _syncInterval = syncInterval;

  final PendingSyncRepository _repository;
  final NetworkStatusService _networkStatusService;
  final TimerService _timerService;
  final SyncableRepositoryRegistry _registry;
  final Duration _syncInterval;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  StreamSubscription<NetworkStatus>? _networkSubscription;
  TimerDisposable? _periodicTimer;
  bool _isRunning = false;
  SyncStatus _currentStatus = SyncStatus.idle;

  Stream<SyncStatus> get statusStream => _statusController.stream.distinct();
  SyncStatus get currentStatus => _currentStatus;

  Future<void> start() async {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    await _networkSubscription?.cancel();
    _networkSubscription = _networkStatusService.statusStream.listen(
      (final NetworkStatus status) {
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
    await _triggerSync(immediate: true);
  }

  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }
    _isRunning = false;
    _periodicTimer?.dispose();
    _periodicTimer = null;
    await _networkSubscription?.cancel();
    _networkSubscription = null;
    _emit(SyncStatus.idle);
  }

  Future<void> dispose() async {
    await stop();
    await _statusController.close();
  }

  Future<void> flush() => _triggerSync(immediate: true);

  Future<void> _triggerSync({required final bool immediate}) async {
    final bool startedTemporarily = !_isRunning && immediate;
    if (!immediate && !_isRunning) {
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
    } on Exception catch (error, stackTrace) {
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
  }

  Future<void> _processPendingOperations() async {
    final List<SyncableRepository> syncables = _registry.repositories;
    if (syncables.isNotEmpty) {
      for (final SyncableRepository repo in syncables) {
        try {
          await repo.pullRemote();
        } on Exception catch (error, stackTrace) {
          AppLogger.error(
            'BackgroundSyncCoordinator.pullRemote failed for ${repo.entityType}',
            error,
            stackTrace,
          );
          _emit(SyncStatus.degraded);
        }
      }
    }

    final List<SyncOperation> pending = await _repository.getPendingOperations(
      now: DateTime.now().toUtc(),
    );
    if (pending.isEmpty) {
      _emit(SyncStatus.idle);
      return;
    }
    _emit(SyncStatus.syncing);
    for (final SyncOperation operation in pending) {
      final SyncableRepository? repository = _registry.resolve(
        operation.entityType,
      );
      if (repository == null) {
        AppLogger.warning(
          'No SyncableRepository registered for ${operation.entityType}, '
          'discarding operation ${operation.id}',
        );
        await _repository.markCompleted(operation.id);
        continue;
      }
      AppLogger.debug(
        'BackgroundSyncCoordinator processing ${operation.entityType} '
        '(id=${operation.id}, retry=${operation.retryCount})',
      );
      try {
        await repository.processOperation(operation);
        await _repository.markCompleted(operation.id);
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'BackgroundSyncCoordinator.processOperation failed for '
          '${operation.entityType}',
          error,
          stackTrace,
        );
        final int backoffMinutes = pow(
          2,
          operation.retryCount.clamp(0, 5),
        ).toInt();
        await _repository.markFailed(
          operationId: operation.id,
          nextRetryAt: DateTime.now().toUtc().add(
            Duration(minutes: backoffMinutes),
          ),
          retryCount: operation.retryCount + 1,
        );
        _emit(SyncStatus.degraded);
      }
    }
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
}
