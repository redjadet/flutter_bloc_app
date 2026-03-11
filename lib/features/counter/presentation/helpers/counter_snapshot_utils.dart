import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';
import 'package:flutter_bloc_app/shared/utils/state_restoration_mixin.dart';

typedef RestorationResult = StateRestorationOutcome<CounterState>;

RestorationResult restoreStateFromSnapshot(final CounterSnapshot snapshot) {
  final int safeCount = snapshot.count < 0 ? 0 : snapshot.count;
  final bool shouldPersist = safeCount != snapshot.count;
  final bool holdCountdown = safeCount == 0;

  return (
    state: CounterState.success(
      count: safeCount,
      lastChanged: snapshot.lastChanged,
      lastSyncedAt: snapshot.lastSyncedAt,
      changeId: snapshot.changeId,
    ),
    shouldPersist: shouldPersist,
    holdSideEffects: holdCountdown,
  );
}

bool shouldIgnoreRemoteSnapshot(
  final CounterState current,
  final CounterSnapshot snapshot,
) {
  if (_isOlderThanCurrentState(current, snapshot)) {
    return true;
  }

  final bool countsEqual = snapshot.count == current.count;
  final bool timestampsEqual = () {
    final DateTime? a = snapshot.lastChanged;
    final DateTime? b = current.lastChanged;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.millisecondsSinceEpoch == b.millisecondsSinceEpoch;
  }();
  final bool syncMetadataEqual =
      snapshot.lastSyncedAt == current.lastSyncedAt &&
      snapshot.changeId == current.changeId;
  return countsEqual && timestampsEqual && syncMetadataEqual;
}

bool _isOlderThanCurrentState(
  final CounterState current,
  final CounterSnapshot snapshot,
) {
  final DateTime? currentChanged = current.lastChanged;
  if (currentChanged == null) {
    return false;
  }

  final DateTime? snapshotChanged = snapshot.lastChanged;
  if (snapshotChanged == null) {
    return true;
  }

  return snapshotChanged.isBefore(currentChanged);
}
