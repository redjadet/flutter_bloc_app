/// Device seen during an active scan.
class const BleDiscoveredDevice({
  required final String id,
  required final String name,
  required final int rssi,
  final bool connectable = true,
}) {
  BleDiscoveredDevice copyWith({
    String? id,
    String? name,
    int? rssi,
    bool? connectable,
  }) => BleDiscoveredDevice(
    id: id ?? this.id,
    name: name ?? this.name,
    rssi: rssi ?? this.rssi,
    connectable: connectable ?? this.connectable,
  );
}
