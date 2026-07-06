/// Device seen during an active scan.
class BleDiscoveredDevice {
  const BleDiscoveredDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.connectable = true,
  });

  final String id;
  final String name;
  final int rssi;
  final bool connectable;

  BleDiscoveredDevice copyWith({
    final String? id,
    final String? name,
    final int? rssi,
    final bool? connectable,
  }) => BleDiscoveredDevice(
    id: id ?? this.id,
    name: name ?? this.name,
    rssi: rssi ?? this.rssi,
    connectable: connectable ?? this.connectable,
  );
}
