import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_state.freezed.dart';

/// Shared counter fields carried across lifecycle variants.
@freezed
abstract class CounterViewData with _$CounterViewData {
  const factory CounterViewData({
    @Default(0) final int count,
    final DateTime? lastChanged,
    final DateTime? lastSyncedAt,
    final String? changeId,
    @Default(CounterState.defaultCountdownSeconds) final int countdownSeconds,
    @Default(0) final int pendingSyncCount,
  }) = _CounterViewData;
}

@freezed
sealed class CounterState with _$CounterState {
  const CounterState._();

  const factory CounterState.initial({
    @Default(CounterViewData()) final CounterViewData data,
  }) = CounterInitial;

  const factory CounterState.loading({
    required final CounterViewData data,
  }) = CounterLoading;

  const factory CounterState.ready({
    required final CounterViewData data,
  }) = CounterReady;

  const factory CounterState.failure({
    required final CounterViewData data,
    required final CounterError error,
  }) = CounterFailure;

  /// Ready snapshot used by restoration / remote watch.
  factory CounterState.success({
    required final int count,
    final DateTime? lastChanged,
    final DateTime? lastSyncedAt,
    final String? changeId,
    final int countdownSeconds = CounterState.defaultCountdownSeconds,
    final int pendingSyncCount = 0,
  }) => CounterState.ready(
    data: CounterViewData(
      count: count,
      lastChanged: lastChanged,
      lastSyncedAt: lastSyncedAt,
      changeId: changeId,
      countdownSeconds: countdownSeconds,
      pendingSyncCount: pendingSyncCount,
    ),
  );

  static const int defaultCountdownSeconds = 5;

  int get count => data.count;
  DateTime? get lastChanged => data.lastChanged;
  DateTime? get lastSyncedAt => data.lastSyncedAt;
  String? get changeId => data.changeId;
  int get countdownSeconds => data.countdownSeconds;
  int get pendingSyncCount => data.pendingSyncCount;

  CounterError? get error => switch (this) {
    CounterFailure(:final error) => error,
    _ => null,
  };

  bool get isLoading => this is CounterLoading;
  bool get isError => this is CounterFailure;
  bool get isInitial => this is CounterInitial;
  bool get isReady => this is CounterReady;

  /// Auto decrement stays active while the counter is above zero.
  bool get isAutoDecrementActive => count > 0;

  CounterState withData(final CounterViewData data) => switch (this) {
    CounterInitial() => CounterState.initial(data: data),
    CounterLoading() => CounterState.loading(data: data),
    CounterReady() => CounterState.ready(data: data),
    CounterFailure(:final error) =>
      CounterState.failure(data: data, error: error),
  };

  CounterState asInitial() => CounterState.initial(data: data);
  CounterState asLoading() => CounterState.loading(data: data);
  CounterState asReady() => CounterState.ready(data: data);
  CounterState asFailure(final CounterError error) =>
      CounterState.failure(data: data, error: error);

  CounterState copyData({
    final int? count,
    final DateTime? lastChanged,
    final DateTime? lastSyncedAt,
    final String? changeId,
    final int? countdownSeconds,
    final int? pendingSyncCount,
  }) => withData(
    data.copyWith(
      count: count ?? data.count,
      lastChanged: lastChanged ?? data.lastChanged,
      lastSyncedAt: lastSyncedAt ?? data.lastSyncedAt,
      changeId: changeId ?? data.changeId,
      countdownSeconds: countdownSeconds ?? data.countdownSeconds,
      pendingSyncCount: pendingSyncCount ?? data.pendingSyncCount,
    ),
  );
}
