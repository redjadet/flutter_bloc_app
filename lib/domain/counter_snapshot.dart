/// Domain snapshot for the counter's persisted data.
/// Keeps persistence concerns decoupled from presentation state.
class CounterSnapshot {
  const CounterSnapshot({
    required this.count,
    this.lastChanged,
  });

  final int count;
  final DateTime? lastChanged;
}

