import 'package:flutter_bloc_app/features/iot_demo/data/mock_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockIotDemoRepository', () {
    late MockIotDemoRepository repository;

    setUp(() {
      repository = MockIotDemoRepository();
    });

    tearDown(() async {
      await repository.dispose();
    });

    test('watchDevices emits initial devices immediately', () async {
      final List<IotDevice> devices = await repository.watchDevices().first;

      expect(devices, isNotEmpty);
      expect(devices.first.id, isNotEmpty);
    });

    test('connect emits connecting then connected', () async {
      final Future<List<IotConnectionState>> statesFuture = repository
          .watchDevices()
          .map(
            (final devices) => devices
                .firstWhere((final d) => d.id == 'light-1')
                .connectionState,
          )
          .take(3)
          .toList();

      await repository.connect('light-1');
      final List<IotConnectionState> states = await statesFuture;

      expect(states, <IotConnectionState>[
        IotConnectionState.disconnected,
        IotConnectionState.connecting,
        IotConnectionState.connected,
      ]);
    });
  });
}
