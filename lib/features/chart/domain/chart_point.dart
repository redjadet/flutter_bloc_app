class ChartPoint {
  const ChartPoint({required this.date, required this.value});

  factory ChartPoint.fromMapEntry(MapEntry<String, dynamic> entry) {
    return ChartPoint(
      date: DateTime.parse(entry.key),
      value: (entry.value as num).toDouble(),
    );
  }

  final DateTime date;
  final double value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartPoint && other.date == date && other.value == value;
  }

  @override
  int get hashCode => Object.hash(date, value);
}
