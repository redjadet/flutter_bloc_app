enum CounterStatus { idle, loading, success, error }

class CounterState {
  const CounterState({
    required this.count,
    this.lastChanged,
    this.countdownSeconds = 5,
    this.errorMessage,
    this.status = CounterStatus.idle,
  });

  final int count;
  final DateTime? lastChanged;
  final int countdownSeconds;
  final String? errorMessage;
  final CounterStatus status;

  CounterState copyWith({
    int? count,
    DateTime? lastChanged,
    int? countdownSeconds,
    String? errorMessage,
    CounterStatus? status,
  }) {
    return CounterState(
      count: count ?? this.count,
      lastChanged: lastChanged ?? this.lastChanged,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
    );
  }
}
