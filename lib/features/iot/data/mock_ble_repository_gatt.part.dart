part of 'mock_ble_repository.dart';

mixin _MockBleRepositoryGatt on _MockBleRepositoryBase {
  Future<Result<List<BleService>>> discoverServices() async {
    final String? deviceId = _connectedDeviceId;
    if (deviceId == null) {
      return const FailureResult<List<BleService>>(
        ValidationFailure('not_connected'),
      );
    }
    final MockBleDeviceProfile? profile = MockBleDeviceCatalog.profileForId(
      deviceId,
    );
    if (profile == null) {
      return const FailureResult<List<BleService>>(
        UnknownFailure(message: 'discover_failed'),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Success<List<BleService>>(profile.services);
  }

  Future<Result<List<int>>> readCharacteristic(
    final BleCharacteristicRef ref,
  ) async {
    final BleCharacteristic? characteristic = _findCharacteristic(ref);
    if (characteristic == null || !characteristic.canRead) {
      return FailureResult<List<int>>(characteristicNotFoundFailure());
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return Success<List<int>>(_readValue(ref));
  }

  Future<Result<void>> writeCharacteristic(
    final BleCharacteristicRef ref,
    final List<int> value, {
    final bool withoutResponse = false,
  }) async {
    final BleCharacteristic? characteristic = _findCharacteristic(ref);
    if (characteristic == null ||
        (!characteristic.canWrite && !characteristic.canWriteWithoutResponse)) {
      return FailureResult<void>(characteristicNotFoundFailure());
    }
    await Future<void>.delayed(
      Duration(milliseconds: withoutResponse ? 40 : 120),
    );
    if (ref.deviceId == MockBleDeviceCatalog.smartLockId &&
        ref.characteristicUuid == MockBleDeviceCatalog.lockPinChar) {
      final String pin = String.fromCharCodes(value);
      final List<int> status = pin == '1234' ? <int>[0x01] : <int>[0x00];
      _notifyControllers[_notifyKey(
            const BleCharacteristicRef(
              deviceId: MockBleDeviceCatalog.smartLockId,
              serviceUuid: MockBleDeviceCatalog.lockService,
              characteristicUuid: MockBleDeviceCatalog.lockStatusChar,
            ),
          )]
          ?.add(status);
    }
    return const Success<void>(null);
  }

  Stream<List<int>> subscribeCharacteristic(final BleCharacteristicRef ref) {
    final BleCharacteristic? characteristic = _findCharacteristic(ref);
    if (characteristic == null ||
        (!characteristic.canNotify && !characteristic.canIndicate)) {
      return Stream<List<int>>.error(characteristicNotFoundFailure());
    }
    _startNotifyTimerIfNeeded(ref);
    return _notifyChannelFor(ref).stream;
  }

  BleCharacteristic? _findCharacteristic(final BleCharacteristicRef ref) {
    final MockBleDeviceProfile? profile = MockBleDeviceCatalog.profileForId(
      ref.deviceId,
    );
    if (profile == null) {
      return null;
    }
    for (final BleService service in profile.services) {
      if (service.uuid != ref.serviceUuid) {
        continue;
      }
      for (final BleCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == ref.characteristicUuid) {
          return characteristic;
        }
      }
    }
    return null;
  }
}
