part of 'offline_first_counter_repository.dart';

extension _OfflineFirstCounterRepositorySync on OfflineFirstCounterRepository {
  Future<void> processOperationBody(final SyncOperation operation) async {
    final CounterSnapshot snapshot = CounterSnapshotDto.fromJson(
      operation.payload,
    ).toDomain();
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

  Future<void> pullRemoteBody() async {
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
}
