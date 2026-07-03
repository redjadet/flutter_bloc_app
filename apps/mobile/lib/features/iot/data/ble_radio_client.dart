import 'package:flutter_bloc_app/features/iot/data/ble_gatt_snapshot.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_radio_exceptions.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Test seam over [FlutterReactiveBle].
abstract class BleRadioClient {
  Stream<BleStatus> get statusStream;

  BleStatus get status;

  Stream<DiscoveredDevice> scanForDevices({
    required final List<Uuid> withServices,
    final ScanMode scanMode = ScanMode.balanced,
  });

  Stream<ConnectionStateUpdate> connectToDevice({
    required final String deviceId,
    final Duration? connectionTimeout,
  });

  Future<List<BleGattServiceSnapshot>> discoverGattServices(
    final String deviceId,
  );

  Future<List<int>> readCharacteristic(final BleCharacteristicRef ref);

  Future<void> writeCharacteristic(
    final BleCharacteristicRef ref,
    final List<int> value, {
    final bool withoutResponse = false,
  });

  Stream<List<int>> subscribeToCharacteristic(final BleCharacteristicRef ref);

  void clearDeviceCache(final String deviceId);
}

/// Production [BleRadioClient] backed by [FlutterReactiveBle].
class FlutterReactiveBleRadioClient implements BleRadioClient {
  FlutterReactiveBleRadioClient({final FlutterReactiveBle? ble})
    : _ble = ble ?? FlutterReactiveBle();

  final FlutterReactiveBle _ble;
  final Map<String, Map<String, Characteristic>> _characteristicCache =
      <String, Map<String, Characteristic>>{};

  @override
  Stream<BleStatus> get statusStream => _ble.statusStream;

  @override
  BleStatus get status => _ble.status;

  @override
  Stream<DiscoveredDevice> scanForDevices({
    required final List<Uuid> withServices,
    final ScanMode scanMode = ScanMode.balanced,
  }) => _ble.scanForDevices(withServices: withServices, scanMode: scanMode);

  @override
  Stream<ConnectionStateUpdate> connectToDevice({
    required final String deviceId,
    final Duration? connectionTimeout,
  }) => _ble.connectToDevice(
    id: deviceId,
    connectionTimeout: connectionTimeout,
  );

  @override
  Future<List<BleGattServiceSnapshot>> discoverGattServices(
    final String deviceId,
  ) async {
    await _ble.discoverAllServices(deviceId);
    final List<Service> services = await _ble.getDiscoveredServices(deviceId);
    final Map<String, Characteristic> cache = <String, Characteristic>{};
    final List<BleGattServiceSnapshot> snapshots = services
        .map(
          (final service) => BleGattServiceSnapshot(
            uuid: service.id.toString(),
            characteristics: service.characteristics
                .map(
                  (final characteristic) {
                    cache[_characteristicKey(
                          service.id,
                          characteristic.id,
                        )] =
                        characteristic;
                    return BleGattCharacteristicSnapshot(
                      uuid: characteristic.id.toString(),
                      canRead: characteristic.isReadable,
                      canWrite: characteristic.isWritableWithResponse,
                      canWriteWithoutResponse:
                          characteristic.isWritableWithoutResponse,
                      canNotify: characteristic.isNotifiable,
                      canIndicate: characteristic.isIndicatable,
                    );
                  },
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
    _characteristicCache[deviceId] = cache;
    return snapshots;
  }

  @override
  Future<List<int>> readCharacteristic(final BleCharacteristicRef ref) async {
    final Characteristic characteristic = _requireCharacteristic(ref);
    return characteristic.read();
  }

  @override
  Future<void> writeCharacteristic(
    final BleCharacteristicRef ref,
    final List<int> value, {
    final bool withoutResponse = false,
  }) async {
    final Characteristic characteristic = _requireCharacteristic(ref);
    await characteristic.write(value, withResponse: !withoutResponse);
  }

  @override
  Stream<List<int>> subscribeToCharacteristic(
    final BleCharacteristicRef ref,
  ) {
    final Characteristic characteristic = _requireCharacteristic(ref);
    return characteristic.subscribe();
  }

  @override
  void clearDeviceCache(final String deviceId) {
    _characteristicCache.remove(deviceId);
  }

  Characteristic _requireCharacteristic(final BleCharacteristicRef ref) {
    final Characteristic? characteristic =
        _characteristicCache[ref.deviceId]?[_characteristicKey(
          Uuid.parse(ref.serviceUuid),
          Uuid.parse(ref.characteristicUuid),
        )];
    if (characteristic == null) {
      throw const BleCharacteristicNotFoundException();
    }
    return characteristic;
  }

  String _characteristicKey(
    final Uuid serviceId,
    final Uuid characteristicId,
  ) => '${serviceId.expanded}|${characteristicId.expanded}';
}
