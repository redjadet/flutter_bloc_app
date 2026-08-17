import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_snapshot.freezed.dart';

/// Immutable snapshot of counter state for persistence.
@freezed
abstract class CounterSnapshot with _$CounterSnapshot {
  const factory CounterSnapshot({
    required int count,
    String? userId,
    DateTime? lastChanged,
    String? changeId,
    DateTime? lastSyncedAt,
    @Default(false) bool synchronized,
  }) = _CounterSnapshot;
}
