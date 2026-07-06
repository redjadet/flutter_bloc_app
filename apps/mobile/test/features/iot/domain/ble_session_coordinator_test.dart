import 'package:flutter_bloc_app/features/iot/data/ble_platform_gateway_impl.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_device_catalog.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_session_coordinator.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';

void main() {
  group('BleSessionCoordinator', () {
    late MockBleRepository repository;
    late BleSessionCoordinator coordinator;

    setUp(() {
      repository = MockBleRepository();
      coordinator = BleSessionCoordinator(
        repository: repository,
        platformGateway: const BlePlatformGatewayImpl(),
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('connectAndDiscover stops scan and returns services', () async {
      await repository.startScan();
      final Result<List<BleService>> result = await coordinator
          .connectAndDiscover(MockBleDeviceCatalog.hrmId);
      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), isNotEmpty);
    });

    test('reconnect re-establishes session', () async {
      final Result<List<BleService>> first = await coordinator
          .connectAndDiscover(MockBleDeviceCatalog.esp32Id);
      expect(first.isSuccess, isTrue);

      final Result<void> reconnect = await coordinator.reconnect();
      expect(reconnect.isSuccess, isTrue);
      expect(coordinator.connectedDeviceId, MockBleDeviceCatalog.esp32Id);
    });
  });
}
