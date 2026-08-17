/// GATT characteristic metadata.
class const BleCharacteristic({
  required final String uuid,
  final bool canRead = false,
  final bool canWrite = false,
  final bool canWriteWithoutResponse = false,
  final bool canNotify = false,
  final bool canIndicate = false,
});

/// GATT service with characteristics.
class const BleService({
  required final String uuid,
  final List<BleCharacteristic> characteristics = const <BleCharacteristic>[],
});

/// Stable reference to a characteristic on a connected device.
class const BleCharacteristicRef({
  required final String deviceId,
  required final String serviceUuid,
  required final String characteristicUuid,
});
