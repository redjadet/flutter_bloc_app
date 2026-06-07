import 'dart:math';

import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';

/// Snapshot merge and normalization helpers for [OfflineFirstCounterRepository].
class OfflineFirstCounterRepositoryHelpers {
  OfflineFirstCounterRepositoryHelpers._();

  static CounterSnapshot normalizeSnapshot(
    final CounterSnapshot snapshot, {
    required final bool hasRemoteRepository,
  }) {
    final DateTime now = DateTime.now().toUtc();
    final String changeId = snapshot.changeId ?? generateChangeId();
    return snapshot.copyWith(
      lastChanged: snapshot.lastChanged ?? now,
      changeId: changeId,
      synchronized: !hasRemoteRepository,
      lastSyncedAt: hasRemoteRepository ? snapshot.lastSyncedAt : now,
    );
  }

  static bool shouldApplyRemote(
    final CounterSnapshot localSnapshot,
    final CounterSnapshot remoteSnapshot,
  ) {
    if (!localSnapshot.synchronized) {
      final DateTime? remote = remoteSnapshot.lastChanged;
      final DateTime? local = localSnapshot.lastChanged;
      if (local == null) return true;
      if (remote == null) return false;
      return remote.isAfter(local);
    }

    if (remoteSnapshot.count != localSnapshot.count) return true;
    final DateTime? remote = remoteSnapshot.lastChanged;
    final DateTime? local = localSnapshot.lastChanged;
    if (remote == null) return true;
    if (local == null) return true;
    return remote.isAfter(local);
  }

  static String generateChangeId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
      Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
}
