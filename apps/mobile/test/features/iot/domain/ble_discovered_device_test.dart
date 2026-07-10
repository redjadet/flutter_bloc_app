import 'package:flutter_bloc_app/features/iot/domain/ble_discovered_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith overrides selected fields', () {
    const BleDiscoveredDevice device = BleDiscoveredDevice(
      id: 'd1',
      name: 'Sensor',
      rssi: -60,
    );

    final BleDiscoveredDevice updated = device.copyWith(
      name: 'Sensor 2',
      rssi: -40,
      connectable: false,
    );

    expect(updated.id, 'd1');
    expect(updated.name, 'Sensor 2');
    expect(updated.rssi, -40);
    expect(updated.connectable, isFalse);
  });
}
