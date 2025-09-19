import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_state.freezed.dart';

enum CounterStatus { idle, loading, success, error }

@freezed
abstract class CounterState with _$CounterState {
  const CounterState._();

  const factory CounterState({
    required int count,
    DateTime? lastChanged,
    @Default(defaultCountdownSeconds) int countdownSeconds,
    @Default(false) bool isAutoDecrementActive,
    CounterError? error,
    @Default(CounterStatus.idle) CounterStatus status,
  }) = _CounterState;

  factory CounterState.success({
    required int count,
    DateTime? lastChanged,
    int countdownSeconds = defaultCountdownSeconds,
  }) {
    return CounterState(
      count: count,
      lastChanged: lastChanged,
      countdownSeconds: countdownSeconds,
      isAutoDecrementActive: count > 0,
      status: CounterStatus.success,
    );
  }

  static const int defaultCountdownSeconds = 5;

  /// Deprecated: Use [error] instead. Kept for backward compatibility.
  @Deprecated('Use error instead')
  String? get errorMessage => error?.type.name;
}
