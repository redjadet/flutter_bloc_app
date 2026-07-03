import 'package:flutter_bloc_app/features/iot/data/mock_ble_device_catalog.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('MockBleRepository', () {
    late MockBleRepository repository;

    setUp(() {
      repository = MockBleRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    test('startScan emits catalog devices', () async {
      final List<List<dynamic>> emissions = <List<dynamic>>[];
      final sub = repository.watchScanResults().listen(emissions.add);
      final Result<void> result = await repository.startScan(
        timeout: const Duration(milliseconds: 50),
      );
      expect(result.isSuccess, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      expect(emissions, isNotEmpty);
      expect(emissions.last.length, MockBleDeviceCatalog.profiles.length);
      await repository.stopScan();
      await sub.cancel();
    });

    test('connect and discover returns GATT services', () async {
      final Result<void> connect = await repository.connect(
        MockBleDeviceCatalog.esp32Id,
      );
      expect(connect.isSuccess, isTrue);
      final Result<List<BleService>> services = await repository
          .discoverServices();
      expect(services.isSuccess, isTrue);
      expect(services.getOrNull(), isNotEmpty);
    });

    test('all catalog profiles connect and discover', () async {
      for (final String deviceId in <String>[
        MockBleDeviceCatalog.esp32Id,
        MockBleDeviceCatalog.hrmId,
        MockBleDeviceCatalog.thermometerId,
        MockBleDeviceCatalog.smartLockId,
      ]) {
        final Result<void> connect = await repository.connect(deviceId);
        expect(connect.isSuccess, isTrue, reason: deviceId);
        final Result<List<BleService>> services = await repository
            .discoverServices();
        expect(services.isSuccess, isTrue, reason: deviceId);
        expect(services.getOrNull(), isNotEmpty, reason: deviceId);
        await repository.disconnect();
      }
    });

    test('second startScan while scanning is idempotent', () async {
      final Result<void> first = await repository.startScan();
      final Result<void> second = await repository.startScan();
      expect(first.isSuccess, isTrue);
      expect(second.isSuccess, isTrue);
      await repository.stopScan();
    });

    test('subscribeCharacteristic emits notify payloads', () async {
      await repository.connect(MockBleDeviceCatalog.hrmId);
      final BleCharacteristicRef ref = BleCharacteristicRef(
        deviceId: MockBleDeviceCatalog.hrmId,
        serviceUuid: MockBleDeviceCatalog.hrmService,
        characteristicUuid: MockBleDeviceCatalog.hrmChar,
      );
      final List<List<int>> emissions = <List<int>>[];
      final sub = repository.subscribeCharacteristic(ref).listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      expect(emissions, isNotEmpty);
      await sub.cancel();
      await repository.disconnect();
    });
  });
}
