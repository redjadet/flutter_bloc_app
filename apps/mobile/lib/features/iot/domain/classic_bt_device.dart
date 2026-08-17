/// Mock classic Bluetooth paired device.
class const ClassicBtDevice({
  required final String id,
  required final String name,
  final bool isConnected = false,
}) {
  ClassicBtDevice copyWith({
    String? id,
    String? name,
    bool? isConnected,
  }) => ClassicBtDevice(
    id: id ?? this.id,
    name: name ?? this.name,
    isConnected: isConnected ?? this.isConnected,
  );
}

enum ClassicBtMessageDirection { incoming, outgoing }

class const ClassicBtMessage({
  required final ClassicBtMessageDirection direction,
  required final String text,
  required final DateTime timestamp,
});
