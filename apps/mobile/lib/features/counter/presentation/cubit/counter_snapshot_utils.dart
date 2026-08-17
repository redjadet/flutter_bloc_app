import 'package:flutter_bloc_app/app/utils/bloc/state_restoration_mixin.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_state.dart';

typedef RestorationResult = StateRestorationOutcome<CounterState>;

RestorationResult restoreStateFromSnapshot(CounterSnapshot snapshot) {
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
  CounterState current,
  CounterSnapshot snapshot,
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
  CounterState current,
  CounterSnapshot snapshot,
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
