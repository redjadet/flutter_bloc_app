import 'package:flutter_bloc_app/features/iot/data/ble_gatt_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constructs service and characteristic snapshots', () {
    const BleGattCharacteristicSnapshot characteristic =
        BleGattCharacteristicSnapshot(
          uuid: 'char-1',
          canRead: true,
          canWrite: true,
          canNotify: true,
        );
    const BleGattServiceSnapshot service = BleGattServiceSnapshot(
      uuid: 'svc-1',
      characteristics: <BleGattCharacteristicSnapshot>[characteristic],
    );

    expect(service.uuid, 'svc-1');
    expect(service.characteristics.single.canRead, isTrue);
    expect(characteristic.canWriteWithoutResponse, isFalse);
    expect(characteristic.canIndicate, isFalse);
  });
}
