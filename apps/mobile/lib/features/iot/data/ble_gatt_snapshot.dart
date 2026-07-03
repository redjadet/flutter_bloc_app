/// GATT discovery snapshot from the BLE radio client (FRB Service API).
class BleGattServiceSnapshot {
  const BleGattServiceSnapshot({
    required this.uuid,
    required this.characteristics,
  });

  final String uuid;
  final List<BleGattCharacteristicSnapshot> characteristics;
}

class BleGattCharacteristicSnapshot {
  const BleGattCharacteristicSnapshot({
    required this.uuid,
    this.canRead = false,
    this.canWrite = false,
    this.canWriteWithoutResponse = false,
    this.canNotify = false,
    this.canIndicate = false,
  });

  final String uuid;
  final bool canRead;
  final bool canWrite;
  final bool canWriteWithoutResponse;
  final bool canNotify;
  final bool canIndicate;
}
