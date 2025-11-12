import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_state.freezed.dart';

@freezed
abstract class CounterState with _$CounterState {
  const factory CounterState({
    required final int count,
    final DateTime? lastChanged,
    @Default(CounterState.defaultCountdownSeconds) final int countdownSeconds,
    final CounterError? error,
    @Default(ViewStatus.initial) final ViewStatus status,
  }) = _CounterState;
  const CounterState._();

  factory CounterState.success({
    required final int count,
    final DateTime? lastChanged,
    final int countdownSeconds = CounterState.defaultCountdownSeconds,
  }) => CounterState(
    count: count,
    lastChanged: lastChanged,
    countdownSeconds: countdownSeconds,
    status: ViewStatus.success,
  );

  static const int defaultCountdownSeconds = 5;

  /// Auto decrement stays active while the counter is above zero.
  bool get isAutoDecrementActive => count > 0;
}
