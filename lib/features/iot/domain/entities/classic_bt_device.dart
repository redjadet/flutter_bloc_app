/// Mock classic Bluetooth paired device.
class ClassicBtDevice {
  const ClassicBtDevice({
    required this.id,
    required this.name,
    this.isConnected = false,
  });

  final String id;
  final String name;
  final bool isConnected;

  ClassicBtDevice copyWith({
    final String? id,
    final String? name,
    final bool? isConnected,
  }) => ClassicBtDevice(
    id: id ?? this.id,
    name: name ?? this.name,
    isConnected: isConnected ?? this.isConnected,
  );
}

enum ClassicBtMessageDirection { incoming, outgoing }

class ClassicBtMessage {
  const ClassicBtMessage({
    required this.direction,
    required this.text,
    required this.timestamp,
  });

  final ClassicBtMessageDirection direction;
  final String text;
  final DateTime timestamp;
}
