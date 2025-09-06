class CounterState {
  const CounterState({
    required this.count,
    this.lastChanged,
    this.countdownSeconds = 5,
    this.errorMessage,
  });

  final int count;
  final DateTime? lastChanged;
  final int countdownSeconds;
  final String? errorMessage;

  CounterState copyWith({
    int? count,
    DateTime? lastChanged,
    int? countdownSeconds,
    String? errorMessage,
  }) {
    return CounterState(
      count: count ?? this.count,
      lastChanged: lastChanged ?? this.lastChanged,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
