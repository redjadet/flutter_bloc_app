import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/counter/data/counter_snapshot_dto.dart';
import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository_helpers.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_constants.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

part 'offline_first_counter_repository_sync.part.dart';

class OfflineFirstCounterRepository
    implements
        CounterRepository,
        CounterSyncDiagnosticsPort,
        SyncableRepository {
  OfflineFirstCounterRepository({
    required this._localRepository,
    required this._pendingSyncRepository,
    required this._registry,
    this._remoteRepository,
  }) {
    _registry.register(this);
  }

  final CounterDataSource _localRepository;
  final CounterDataSource? _remoteRepository;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;
  bool _remoteMergePausedForSessionCleanup = false;
  final Set<Future<void>> _inFlightRemoteWatchMerges = <Future<void>>{};

  @visibleForTesting
  bool get hasRemoteRepository => _remoteRepository != null;

  @override
  String get entityType => counterSyncEntityType;

  @override
  Future<CounterSnapshot> load() => _localRepository.load();

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    final CounterSnapshot normalized =
        OfflineFirstCounterRepositoryHelpers.normalizeSnapshot(
          snapshot,
          hasRemoteRepository: _remoteRepository != null,
        );
    await _localRepository.save(normalized);
    if (_remoteRepository == null) {
      return;
    }
    final String changeId =
        normalized.changeId ??
        OfflineFirstCounterRepositoryHelpers.generateChangeId();
    final SyncOperation operation = SyncOperation.create(
      entityType: entityType,
      payload: CounterSnapshotDto.fromDomain(normalized).toJson(),
      idempotencyKey: changeId,
    );
    await _pendingSyncRepository.enqueue(operation);
  }

  @override
  Stream<CounterSnapshot> watch() {
    if (_remoteRepository == null) {
      return _localRepository.watch();
    }
    late StreamSubscription<CounterSnapshot> localSub;
    late StreamSubscription<CounterSnapshot> remoteSub;
    late StreamController<CounterSnapshot> controller;
    controller = StreamController<CounterSnapshot>.broadcast(
      onListen: () {
        localSub = _localRepository.watch().listen(
          controller.add,
          onError: controller.addError,
          onDone: () => controller.close(),
        );
        remoteSub = _remoteRepository.watch().listen(
          (remote) async {
            if (_remoteMergePausedForSessionCleanup) {
              return;
            }
            final Future<void> merge = _applyRemoteSnapshotIfCurrent(remote);
            _trackRemoteWatchMerge(merge);
            await merge;
          },
          onError: (Object e, StackTrace st) {
            AppLogger.error(
              'OfflineFirstCounterRepository remote watch failed',
              e,
              st,
            );
          },
        );
      },
      onCancel: () async {
        await localSub.cancel();
        await remoteSub.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> processOperation(SyncOperation operation) =>
      processOperationBody(operation);

  @override
  Future<void> pullRemote() => pullRemoteBody();

  Future<List<SyncOperation>> _counterPendingOperations({DateTime? now}) async {
    final List<SyncOperation> operations = await _pendingSyncRepository
        .getPendingOperations(now: now ?? DateTime.now().toUtc());
    return operations
        .where((op) => op.entityType == counterSyncEntityType)
        .toList(growable: false);
  }

  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) async =>
      (await _counterPendingOperations(now: now)).length;

  @override
  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({
    DateTime? now,
  }) async => (await _counterPendingOperations(now: now))
      .map(
        (operation) => CounterSyncQueueEntry(
          id: operation.id,
          entityType: operation.entityType,
          retryCount: operation.retryCount,
        ),
      )
      .toList(growable: false);

  /// Clears local counter state without enqueueing a remote sync op.
  Future<void> clearAllLocalData() async {
    await _waitForRemoteWatchMerges();
    final CounterDataSource local = _localRepository;
    if (local is HiveCounterRepository) {
      await local.clearAllLocalData();
      return;
    }
    await local.save(
      const CounterSnapshot(userId: 'local', count: 0, synchronized: true),
    );
  }

  /// Stops remote merge/watch during Firebase session cleanup.
  void pauseRemoteWatchForSessionCleanup() {
    _remoteMergePausedForSessionCleanup = true;
  }

  /// Resumes remote merge/watch after session cleanup completes.
  void resumeRemoteWatchForSessionCleanup() {
    _remoteMergePausedForSessionCleanup = false;
  }

  void _trackRemoteWatchMerge(Future<void> merge) {
    _inFlightRemoteWatchMerges.add(merge);
    unawaited(
      merge.then<void>(
        (_) {
          _inFlightRemoteWatchMerges.remove(merge);
        },
        onError: (Object _, StackTrace _) {
          _inFlightRemoteWatchMerges.remove(merge);
        },
      ),
    );
  }

  Future<void> _waitForRemoteWatchMerges() async {
    while (_inFlightRemoteWatchMerges.isNotEmpty) {
      await Future.wait<void>(
        _inFlightRemoteWatchMerges.toList(growable: false),
      );
    }
  }
}
