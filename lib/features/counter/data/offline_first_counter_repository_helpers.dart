import 'dart:math';

import 'package:flutter_bloc_app/features/counter/data/offline_first_counter_repository.dart'
    show OfflineFirstCounterRepository;
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

  /// Whether a queued pending snapshot should be pushed to remote.
  ///
  /// Symmetric to [shouldApplyRemote]: never push an older pending write over a
  /// newer remote (multi-device stale queue replay).
  static bool shouldPushPendingToRemote(
    final CounterSnapshot pendingSnapshot,
    final CounterSnapshot remoteSnapshot,
  ) {
    final DateTime? pending = pendingSnapshot.lastChanged;
    final DateTime? remote = remoteSnapshot.lastChanged;

    if (pending != null && remote != null && remote.isAfter(pending)) {
      return false;
    }
    return true;
  }

  static bool shouldApplyRemote(
    final CounterSnapshot localSnapshot,
    final CounterSnapshot remoteSnapshot,
  ) {
    final DateTime? remote = remoteSnapshot.lastChanged;
    final DateTime? local = localSnapshot.lastChanged;

    // Never apply an older remote over a newer local (see TodoMergePolicy).
    if (local != null && remote != null && local.isAfter(remote)) {
      return false;
    }

    if (!localSnapshot.synchronized) {
      if (local == null) return true;
      if (remote == null) return false;
      return remote.isAfter(local);
    }

    if (remoteSnapshot.count != localSnapshot.count) return true;
    if (remote == null) return true;
    if (local == null) return true;
    return remote.isAfter(local);
  }

  static String generateChangeId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
      Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
}
