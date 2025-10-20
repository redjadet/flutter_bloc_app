import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_state.freezed.dart';

enum CounterStatus { idle, loading, success, error }

@freezed
abstract class CounterState with _$CounterState {
  const CounterState._();

  const factory CounterState({
    required final int count,
    final DateTime? lastChanged,
    @Default(CounterState.defaultCountdownSeconds) final int countdownSeconds,
    final CounterError? error,
    @Default(CounterStatus.idle) final CounterStatus status,
  }) = _CounterState;

  factory CounterState.success({
    required final int count,
    final DateTime? lastChanged,
    final int countdownSeconds = CounterState.defaultCountdownSeconds,
  }) => CounterState(
    count: count,
    lastChanged: lastChanged,
    countdownSeconds: countdownSeconds,
    status: CounterStatus.success,
  );

  static const int defaultCountdownSeconds = 5;

  /// Auto decrement stays active while the counter is above zero.
  bool get isAutoDecrementActive => count > 0;

  /// Deprecated: Use [error] instead. Kept for backward compatibility.
  @Deprecated('Use error instead')
  String? get errorMessage => error?.type.name;
}
