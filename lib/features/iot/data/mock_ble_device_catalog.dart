import 'package:flutter_bloc_app/features/iot/domain/entities/ble_discovered_device.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_service.dart';

/// Static GATT profiles for the mock BLE simulator.
class MockBleDeviceProfile {
  const MockBleDeviceProfile({
    required this.device,
    required this.services,
    this.notifyInterval = const Duration(seconds: 2),
  });

  final BleDiscoveredDevice device;
  final List<BleService> services;
  final Duration notifyInterval;
}

/// Catalog of four interview demo peripherals.
class MockBleDeviceCatalog {
  MockBleDeviceCatalog._();

  static const String esp32Id = 'mock-esp32-001';
  static const String hrmId = 'mock-hrm-002';
  static const String thermometerId = 'mock-thermo-003';
  static const String smartLockId = 'mock-lock-004';

  static const String esp32Service = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String esp32Char = '0000ffe1-0000-1000-8000-00805f9b34fb';
  static const String hrmService = '0000180d-0000-1000-8000-00805f9b34fb';
  static const String hrmChar = '00002a37-0000-1000-8000-00805f9b34fb';
  static const String thermometerService =
      '00001809-0000-1000-8000-00805f9b34fb';
  static const String thermometerChar = '00002a1c-0000-1000-8000-00805f9b34fb';
  static const String lockService = '0000ff10-0000-1000-8000-00805f9b34fb';
  static const String lockPinChar = '0000ff11-0000-1000-8000-00805f9b34fb';
  static const String lockStatusChar = '0000ff12-0000-1000-8000-00805f9b34fb';

  static final List<MockBleDeviceProfile> profiles = <MockBleDeviceProfile>[
    const MockBleDeviceProfile(
      device: BleDiscoveredDevice(
        id: esp32Id,
        name: 'ESP32 Sensor',
        rssi: -58,
      ),
      services: <BleService>[
        BleService(
          uuid: esp32Service,
          characteristics: <BleCharacteristic>[
            BleCharacteristic(
              uuid: esp32Char,
              canRead: true,
              canWrite: true,
              canNotify: true,
            ),
          ],
        ),
      ],
    ),
    const MockBleDeviceProfile(
      device: BleDiscoveredDevice(
        id: hrmId,
        name: 'Heart Rate Monitor',
        rssi: -64,
      ),
      services: <BleService>[
        BleService(
          uuid: hrmService,
          characteristics: <BleCharacteristic>[
            BleCharacteristic(
              uuid: hrmChar,
              canRead: true,
              canNotify: true,
            ),
          ],
        ),
      ],
    ),
    const MockBleDeviceProfile(
      device: BleDiscoveredDevice(
        id: thermometerId,
        name: 'Smart Thermometer',
        rssi: -70,
      ),
      services: <BleService>[
        BleService(
          uuid: thermometerService,
          characteristics: <BleCharacteristic>[
            BleCharacteristic(
              uuid: thermometerChar,
              canRead: true,
              canIndicate: true,
            ),
          ],
        ),
      ],
    ),
    const MockBleDeviceProfile(
      device: BleDiscoveredDevice(
        id: smartLockId,
        name: 'Smart Lock',
        rssi: -72,
      ),
      services: <BleService>[
        BleService(
          uuid: lockService,
          characteristics: <BleCharacteristic>[
            BleCharacteristic(
              uuid: lockPinChar,
              canWrite: true,
              canWriteWithoutResponse: true,
            ),
            BleCharacteristic(
              uuid: lockStatusChar,
              canRead: true,
              canNotify: true,
            ),
          ],
        ),
      ],
    ),
  ];

  static MockBleDeviceProfile? profileForId(final String deviceId) {
    for (final MockBleDeviceProfile profile in profiles) {
      if (profile.device.id == deviceId) {
        return profile;
      }
    }
    return null;
  }
}
