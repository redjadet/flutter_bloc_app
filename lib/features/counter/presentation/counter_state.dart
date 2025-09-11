import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';

enum CounterStatus { idle, loading, success, error }

class CounterState {
  const CounterState({
    required this.count,
    this.lastChanged,
    this.countdownSeconds = 5,
    this.isAutoDecrementActive = true,
    this.error,
    this.status = CounterStatus.idle,
  });

  final int count;
  final DateTime? lastChanged;
  final int countdownSeconds;
  final bool isAutoDecrementActive;
  final CounterError? error;
  final CounterStatus status;

  /// Deprecated: Use [error] instead. Kept for backward compatibility.
  @Deprecated('Use error instead')
  String? get errorMessage => error?.type.name;

  CounterState copyWith({
    int? count,
    DateTime? lastChanged,
    int? countdownSeconds,
    bool? isAutoDecrementActive,
    CounterError? error,
    CounterStatus? status,
  }) {
    return CounterState(
      count: count ?? this.count,
      lastChanged: lastChanged ?? this.lastChanged,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isAutoDecrementActive:
          isAutoDecrementActive ?? this.isAutoDecrementActive,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}
