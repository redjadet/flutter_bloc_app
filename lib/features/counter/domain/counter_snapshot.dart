import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_snapshot.freezed.dart';
part 'counter_snapshot.g.dart';

/// Immutable snapshot of counter state for persistence.
@freezed
class CounterSnapshot with _$CounterSnapshot {
  const factory CounterSnapshot({
    required int count,
    DateTime? lastChanged,
  }) = _CounterSnapshot;

  factory CounterSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CounterSnapshotFromJson(json);
}
