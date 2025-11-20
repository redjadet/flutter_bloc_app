import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_state.dart';

typedef RestorationResult = ({
  CounterState state,
  bool shouldPersist,
  bool holdCountdown,
});

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
    holdCountdown: holdCountdown,
  );
}

bool shouldIgnoreRemoteSnapshot(
  final CounterState current,
  final CounterSnapshot snapshot,
) {
  final bool countsEqual = snapshot.count == current.count;
  final bool timestampsEqual = () {
    final DateTime? a = snapshot.lastChanged;
    final DateTime? b = current.lastChanged;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.millisecondsSinceEpoch == b.millisecondsSinceEpoch;
  }();
  return countsEqual && timestampsEqual;
}
