import 'dart:math';

import 'package:flutter_bloc_app/features/counter/data/hive_counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstCounterRepository
    implements CounterRepository, SyncableRepository {
  OfflineFirstCounterRepository({
    required final HiveCounterRepository localRepository,
    required final PendingSyncRepository pendingSyncRepository,
    required final SyncableRepositoryRegistry registry,
    final CounterRepository? remoteRepository,
  }) : _localRepository = localRepository,
       _remoteRepository = remoteRepository,
       _pendingSyncRepository = pendingSyncRepository,
       _registry = registry {
    _registry.register(this);
  }

  static const String counterEntity = 'counter';

  final HiveCounterRepository _localRepository;
  final CounterRepository? _remoteRepository;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;

  @override
  String get entityType => counterEntity;

  @override
  Future<CounterSnapshot> load() => _localRepository.load();

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    final CounterSnapshot normalized = _normalizeSnapshot(snapshot);
    await _localRepository.save(normalized);
    if (_remoteRepository == null) {
      return;
    }
    final String changeId = normalized.changeId ?? _generateChangeId();
    final SyncOperation operation = SyncOperation.create(
      entityType: entityType,
      payload: normalized.toJson(),
      idempotencyKey: changeId,
    );
    await _pendingSyncRepository.enqueue(operation);
  }

  @override
  Stream<CounterSnapshot> watch() => _localRepository.watch();

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
      final CounterSnapshot localSnapshot = await _localRepository.load();
      if (_shouldApplyRemote(localSnapshot, remoteSnapshot)) {
        await _localRepository.save(
          remoteSnapshot.copyWith(
            changeId: remoteSnapshot.changeId ?? _generateChangeId(),
            lastSyncedAt: DateTime.now().toUtc(),
            synchronized: true,
          ),
        );
      }
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstCounterRepository.pullRemote failed',
        error,
        stackTrace,
      );
    }
  }

  CounterSnapshot _normalizeSnapshot(final CounterSnapshot snapshot) {
    final DateTime now = DateTime.now().toUtc();
    final String changeId = snapshot.changeId ?? _generateChangeId();
    return snapshot.copyWith(
      lastChanged: snapshot.lastChanged ?? now,
      changeId: changeId,
      synchronized: _remoteRepository == null,
      lastSyncedAt: _remoteRepository == null ? now : snapshot.lastSyncedAt,
    );
  }

  bool _shouldApplyRemote(
    final CounterSnapshot localSnapshot,
    final CounterSnapshot remoteSnapshot,
  ) {
    final DateTime? remote = remoteSnapshot.lastChanged;
    final DateTime? local = localSnapshot.lastChanged;
    if (remote == null) return false;
    if (local == null) return true;
    return remote.isAfter(local);
  }

  static String _generateChangeId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
      Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
}
