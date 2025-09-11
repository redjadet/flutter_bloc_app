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

  // Use a sentinel to allow explicit nulling of [error]
  static const Object _noChange = Object();

  CounterState copyWith({
    int? count,
    DateTime? lastChanged,
    int? countdownSeconds,
    bool? isAutoDecrementActive,
    Object? error = _noChange,
    CounterStatus? status,
  }) {
    final CounterError? newError =
        identical(error, _noChange) ? this.error : error as CounterError?;
    return CounterState(
      count: count ?? this.count,
      lastChanged: lastChanged ?? this.lastChanged,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      isAutoDecrementActive:
          isAutoDecrementActive ?? this.isAutoDecrementActive,
      error: newError,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'CounterState(count: $count, lastChanged: $lastChanged, '
        'countdownSeconds: $countdownSeconds, '
        'isAutoDecrementActive: $isAutoDecrementActive, '
        'error: $error, status: $status)';
  }
}
