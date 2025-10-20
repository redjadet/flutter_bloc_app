import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_snapshot.freezed.dart';
part 'counter_snapshot.g.dart';

/// Immutable snapshot of counter state for persistence.
@freezed
abstract class CounterSnapshot with _$CounterSnapshot {
  const factory CounterSnapshot({
    required final int count,
    final String? userId,
    final DateTime? lastChanged,
  }) = _CounterSnapshot;

  factory CounterSnapshot.fromJson(final Map<String, dynamic> json) =>
      _$CounterSnapshotFromJson(json);
}
