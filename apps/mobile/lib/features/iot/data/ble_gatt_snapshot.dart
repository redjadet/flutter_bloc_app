/// GATT discovery snapshot from the BLE radio client (FRB Service API).
class const BleGattServiceSnapshot({
  required final String uuid,
  required final List<BleGattCharacteristicSnapshot> characteristics,
});

class const BleGattCharacteristicSnapshot({
  required final String uuid,
  final bool canRead = false,
  final bool canWrite = false,
  final bool canWriteWithoutResponse = false,
  final bool canNotify = false,
  final bool canIndicate = false,
});
