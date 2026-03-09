import 'dart:io';

import 'package:flutter_bloc_app/features/iot_demo/data/persistent_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('PersistentIotDemoRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late PersistentIotDemoRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('iot_demo_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = PersistentIotDemoRepository(
        hiveService: hiveService,
        supabaseUserId: 'test-user-id',
      );
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('constructor throws for empty or whitespace supabaseUserId', () {
      expect(
        () => PersistentIotDemoRepository(
          hiveService: hiveService,
          supabaseUserId: '',
        ),
        throwsArgumentError,
      );
      expect(
        () => PersistentIotDemoRepository(
          hiveService: hiveService,
          supabaseUserId: '   ',
        ),
        throwsArgumentError,
      );
    });

    test('watchDevices emits empty list when storage is empty', () async {
      final List<IotDevice> devices = await repository.watchDevices().first;
      expect(devices, isEmpty);
    });

    test(
      'sendCommand setValue persists and is visible on next watch',
      () async {
        await repository.replaceDevices(<IotDevice>[
          const IotDevice(
            id: 'thermostat-1',
            name: 'Thermostat',
            type: IotDeviceType.thermostat,
            value: 21,
          ),
        ]);
        await repository.connect('thermostat-1');
        await repository.sendCommand(
          'thermostat-1',
          IotDeviceCommand.setValue(23.5),
        );

        final List<IotDevice> devices = await repository.watchDevices().first;
        final IotDevice thermostat = devices.firstWhere(
          (final d) => d.id == 'thermostat-1',
        );
        expect(thermostat.value, 23.5);
      },
    );

    test('sendCommand setValue clamps out-of-range values', () async {
      await repository.replaceDevices(<IotDevice>[
        const IotDevice(
          id: 'thermostat-1',
          name: 'Thermostat',
          type: IotDeviceType.thermostat,
          value: 21,
        ),
      ]);
      await repository.connect('thermostat-1');
      await repository.sendCommand(
        'thermostat-1',
        IotDeviceCommand.setValue(iotDemoValueMax + 100),
      );

      final List<IotDevice> devices = await repository.watchDevices().first;
      final IotDevice thermostat = devices.firstWhere(
        (final d) => d.id == 'thermostat-1',
      );
      expect(thermostat.value, iotDemoValueMax);
    });

    test('sendCommand toggle persists and is visible on next watch', () async {
      await repository.replaceDevices(<IotDevice>[
        const IotDevice(
          id: 'light-1',
          name: 'Living Room Light',
          type: IotDeviceType.light,
        ),
      ]);
      await repository.connect('light-1');
      await repository.sendCommand('light-1', const IotDeviceCommand.toggle());

      final List<IotDevice> devices = await repository.watchDevices().first;
      final IotDevice light = devices.firstWhere(
        (final d) => d.id == 'light-1',
      );
      expect(light.toggledOn, isTrue);
    });

    test('values persist across repository instances (app restart)', () async {
      const String userId = 'test-user-id';
      await repository.replaceDevices(<IotDevice>[
        const IotDevice(
          id: 'sensor-1',
          name: 'Temperature Sensor',
          type: IotDeviceType.sensor,
          value: 22.5,
        ),
        const IotDevice(
          id: 'plug-1',
          name: 'Smart Plug',
          type: IotDeviceType.plug,
        ),
      ]);
      await repository.connect('sensor-1');
      await repository.sendCommand('sensor-1', IotDeviceCommand.setValue(19.0));
      await repository.connect('plug-1');
      await repository.sendCommand('plug-1', const IotDeviceCommand.toggle());

      final PersistentIotDemoRepository repo2 = PersistentIotDemoRepository(
        hiveService: hiveService,
        supabaseUserId: userId,
      );
      final List<IotDevice> devices = await repo2.watchDevices().first;

      final IotDevice sensor = devices.firstWhere(
        (final d) => d.id == 'sensor-1',
      );
      expect(sensor.value, 19.0);

      final IotDevice plug = devices.firstWhere((final d) => d.id == 'plug-1');
      expect(plug.toggledOn, isTrue);
      expect(plug.connectionState, IotConnectionState.connected);
    });

    test(
      'disconnect during pending connect keeps device disconnected',
      () async {
        await repository.replaceDevices(<IotDevice>[
          const IotDevice(
            id: 'light-1',
            name: 'Living Room Light',
            type: IotDeviceType.light,
          ),
        ]);
        final Future<void> connectFuture = repository.connect('light-1');
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await repository.disconnect('light-1');
        await connectFuture;

        final List<IotDevice> devices = await repository.watchDevices().first;
        final IotDevice light = devices.firstWhere(
          (final d) => d.id == 'light-1',
        );

        expect(light.connectionState, IotConnectionState.disconnected);
      },
    );
  });
}
