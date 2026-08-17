import 'package:flutter_bloc_app/features/iot/data/ble_gatt_snapshot.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';

List<BleService> mapGattSnapshotsToBleServices(
  List<BleGattServiceSnapshot> services,
) => services
    .map(
      (service) => BleService(
        uuid: service.uuid,
        characteristics: service.characteristics
            .map(
              (characteristic) => BleCharacteristic(
                uuid: characteristic.uuid,
                canRead: characteristic.canRead,
                canWrite: characteristic.canWrite,
                canWriteWithoutResponse: characteristic.canWriteWithoutResponse,
                canNotify: characteristic.canNotify,
                canIndicate: characteristic.canIndicate,
              ),
            )
            .toList(growable: false),
      ),
    )
    .toList(growable: false);
