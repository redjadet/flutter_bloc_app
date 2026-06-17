import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository_helpers.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstCounterRepository
    implements CounterRepository, SyncableRepository {
  OfflineFirstCounterRepository({
    required this._localRepository,
    required this._pendingSyncRepository,
    required this._registry,
    this._remoteRepository,
  }) {
    _registry.register(this);
  }

  static const String counterEntity = 'counter';

  final CounterRepository _localRepository;
  final CounterRepository? _remoteRepository;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;

  @visibleForTesting
  bool get hasRemoteRepository => _remoteRepository != null;

  @override
  String get entityType => counterEntity;

  @override
  Future<CounterSnapshot> load() => _localRepository.load();

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
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
      payload: normalized.toJson(),
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
          (final remote) async {
            await _applyRemoteSnapshotIfCurrent(remote);
          },
          onError: (final Object e, final StackTrace st) {
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
  Future<void> processOperation(final SyncOperation operation) async {
    final CounterSnapshot snapshot = CounterSnapshot.fromJson(
      operation.payload,
    );
    if (_remoteRepository == null) {
      await _localRepository.save(
        snapshot.copyWith(
          synchronized: true,
          lastSyncedAt: DateTime.now().toUtc(),
        ),
      );
      return;
    }
    final CounterSnapshot remoteSnapshot = await _remoteRepository.load();
    if (!OfflineFirstCounterRepositoryHelpers.shouldPushPendingToRemote(
      snapshot,
      remoteSnapshot,
    )) {
      final CounterSnapshot localSnapshot = await _localRepository.load();
      if (OfflineFirstCounterRepositoryHelpers.shouldApplyRemote(
        localSnapshot,
        remoteSnapshot,
      )) {
        await _localRepository.save(
          remoteSnapshot.copyWith(
            changeId:
                remoteSnapshot.changeId ??
                OfflineFirstCounterRepositoryHelpers.generateChangeId(),
            lastSyncedAt: DateTime.now().toUtc(),
            synchronized: true,
          ),
        );
      }
      return;
    }

    await _remoteRepository.save(
      CounterSnapshot(
        count: snapshot.count,
        lastChanged: snapshot.lastChanged,
        userId: snapshot.userId,
      ),
    );
    await _localRepository.save(
      snapshot.copyWith(
        synchronized: true,
        lastSyncedAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<void> pullRemote() async {
    if (_remoteRepository == null) {
      return;
    }
    try {
      final CounterSnapshot remoteSnapshot = await _remoteRepository.load();
      await _applyRemoteSnapshotIfCurrent(remoteSnapshot);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstCounterRepository.pullRemote failed',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _applyRemoteSnapshotIfCurrent(
    final CounterSnapshot remoteSnapshot,
  ) async {
    final CounterSnapshot localSnapshot = await _localRepository.load();
    if (!OfflineFirstCounterRepositoryHelpers.shouldApplyRemote(
      localSnapshot,
      remoteSnapshot,
    )) {
      return;
    }

    // Re-read before save so a local write during the first load cannot be
    // overwritten by a stale remote decision (TOCTOU).
    final CounterSnapshot freshLocal = await _localRepository.load();
    if (!OfflineFirstCounterRepositoryHelpers.shouldApplyRemote(
      freshLocal,
      remoteSnapshot,
    )) {
      return;
    }

    await _localRepository.save(
      remoteSnapshot.copyWith(
        changeId:
            remoteSnapshot.changeId ??
            OfflineFirstCounterRepositoryHelpers.generateChangeId(),
        lastSyncedAt: DateTime.now().toUtc(),
        synchronized: true,
      ),
    );
  }

  Future<List<SyncOperation>> _counterPendingOperations({DateTime? now}) async {
    final List<SyncOperation> operations = await _pendingSyncRepository
        .getPendingOperations(now: now ?? DateTime.now().toUtc());
    return operations
        .where((final op) => op.entityType == counterEntity)
        .toList(growable: false);
  }

  @override
  Future<int> pendingSyncOperationCount({DateTime? now}) async =>
      (await _counterPendingOperations(now: now)).length;

  @override
  Future<List<CounterSyncQueueEntry>> pendingSyncQueueEntries({
    DateTime? now,
  }) async =>
      (await _counterPendingOperations(now: now))
          .map(
            (final operation) => CounterSyncQueueEntry(
              id: operation.id,
              entityType: operation.entityType,
              retryCount: operation.retryCount,
            ),
          )
          .toList(growable: false);
}
