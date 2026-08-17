import 'package:flutter_bloc_app/features/iot/data/ble_gatt_snapshot.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_radio_exceptions.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

/// Test seam over [FlutterReactiveBle].
abstract class BleRadioClient {
  Stream<BleStatus> get statusStream;

  BleStatus get status;

  Stream<DiscoveredDevice> scanForDevices({
    required List<Uuid> withServices,
    ScanMode scanMode = ScanMode.balanced,
  });

  Stream<ConnectionStateUpdate> connectToDevice({
    required String deviceId,
    Duration? connectionTimeout,
  });

  Future<List<BleGattServiceSnapshot>> discoverGattServices(
    String deviceId,
  );

  Future<List<int>> readCharacteristic(BleCharacteristicRef ref);

  Future<void> writeCharacteristic(
    BleCharacteristicRef ref,
    List<int> value, {
    bool withoutResponse = false,
  });

  Stream<List<int>> subscribeToCharacteristic(BleCharacteristicRef ref);

  void clearDeviceCache(String deviceId);
}

/// Production [BleRadioClient] backed by [FlutterReactiveBle].
class FlutterReactiveBleRadioClient implements BleRadioClient {
  FlutterReactiveBleRadioClient({FlutterReactiveBle? ble})
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
    required List<Uuid> withServices,
    ScanMode scanMode = ScanMode.balanced,
  }) => _ble.scanForDevices(withServices: withServices, scanMode: scanMode);

  @override
  Stream<ConnectionStateUpdate> connectToDevice({
    required String deviceId,
    Duration? connectionTimeout,
  }) => _ble.connectToDevice(
    id: deviceId,
    connectionTimeout: connectionTimeout,
  );

  @override
  Future<List<BleGattServiceSnapshot>> discoverGattServices(
    String deviceId,
  ) async {
    await _ble.discoverAllServices(deviceId);
    final List<Service> services = await _ble.getDiscoveredServices(deviceId);
    final Map<String, Characteristic> cache = <String, Characteristic>{};
    final List<BleGattServiceSnapshot> snapshots = services
        .map(
          (service) => BleGattServiceSnapshot(
            uuid: service.id.toString(),
            characteristics: service.characteristics
                .map(
                  (characteristic) {
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
  Future<List<int>> readCharacteristic(BleCharacteristicRef ref) async {
    final Characteristic characteristic = _requireCharacteristic(ref);
    return characteristic.read();
  }

  @override
  Future<void> writeCharacteristic(
    BleCharacteristicRef ref,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    final Characteristic characteristic = _requireCharacteristic(ref);
    await characteristic.write(value, withResponse: !withoutResponse);
  }

  @override
  Stream<List<int>> subscribeToCharacteristic(
    BleCharacteristicRef ref,
  ) {
    final Characteristic characteristic = _requireCharacteristic(ref);
    return characteristic.subscribe();
  }

  @override
  void clearDeviceCache(String deviceId) {
    _characteristicCache.remove(deviceId);
  }

  Characteristic _requireCharacteristic(BleCharacteristicRef ref) {
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
    Uuid serviceId,
    Uuid characteristicId,
  ) => '${serviceId.expanded}|${characteristicId.expanded}';
}
