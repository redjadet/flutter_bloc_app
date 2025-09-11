/// Immutable snapshot of counter state for persistence.
class CounterSnapshot {
  const CounterSnapshot({required this.count, this.lastChanged});

  final int count;
  final DateTime? lastChanged;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterSnapshot &&
        other.count == count &&
        other.lastChanged == lastChanged;
  }

  @override
  int get hashCode => Object.hash(count, lastChanged);

  @override
  String toString() =>
      'CounterSnapshot(count: $count, lastChanged: $lastChanged)';
}
