/// GATT characteristic metadata.
class BleCharacteristic {
  const BleCharacteristic({
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

/// GATT service with characteristics.
class BleService {
  const BleService({
    required this.uuid,
    this.characteristics = const <BleCharacteristic>[],
  });

  final String uuid;
  final List<BleCharacteristic> characteristics;
}

/// Stable reference to a characteristic on a connected device.
class BleCharacteristicRef {
  const BleCharacteristicRef({
    required this.deviceId,
    required this.serviceUuid,
    required this.characteristicUuid,
  });

  final String deviceId;
  final String serviceUuid;
  final String characteristicUuid;
}
