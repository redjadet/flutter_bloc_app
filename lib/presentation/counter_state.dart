class CounterState {
  const CounterState({
    required this.count,
    this.lastChanged,
    this.countdownSeconds = 5,
  });

  final int count;
  final DateTime? lastChanged;
  final int countdownSeconds;

  CounterState copyWith({
    int? count,
    DateTime? lastChanged,
    int? countdownSeconds,
  }) {
    return CounterState(
      count: count ?? this.count,
      lastChanged: lastChanged ?? this.lastChanged,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
    );
  }
}

