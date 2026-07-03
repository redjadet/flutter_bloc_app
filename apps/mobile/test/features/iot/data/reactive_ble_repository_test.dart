import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' hide Result;
import 'package:flutter_bloc_app/core/domain/failure.dart';
import 'package:flutter_bloc_app/core/domain/result.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_gatt_snapshot.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_radio_client.dart';
import 'package:flutter_bloc_app/features/iot/data/reactive_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_permission_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_connection_phase.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/ble_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBlePermissionGateway implements BlePermissionGateway {
  const _FakeBlePermissionGateway({required this.granted});

  final bool granted;

  @override
  Future<bool> requestRuntimePermissions() async => granted;
}

class _FakeBleRadioClient implements BleRadioClient {
  _FakeBleRadioClient({
    required BleStatus status,
    this.connectionUpdates = const <ConnectionStateUpdate>[],
  }) : _status = status {
    _statusController.add(status);
  }

  final BleStatus _status;
  final List<ConnectionStateUpdate> connectionUpdates;
  final StreamController<BleStatus> _statusController =
      StreamController<BleStatus>.broadcast();
  int connectCalls = 0;

  @override
  BleStatus get status => _status;

  @override
  Stream<BleStatus> get statusStream => _statusController.stream;

  @override
  Stream<DiscoveredDevice> scanForDevices({
    required final List<Uuid> withServices,
    final ScanMode scanMode = ScanMode.balanced,
  }) => const Stream<DiscoveredDevice>.empty();

  @override
  Stream<ConnectionStateUpdate> connectToDevice({
    required final String deviceId,
    final Duration? connectionTimeout,
  }) {
    connectCalls += 1;
    return Stream<ConnectionStateUpdate>.fromIterable(connectionUpdates);
  }

  @override
  Future<List<BleGattServiceSnapshot>> discoverGattServices(
    final String deviceId,
  ) async => <BleGattServiceSnapshot>[];

  @override
  Future<List<int>> readCharacteristic(final BleCharacteristicRef ref) async =>
      <int>[];

  @override
  Future<void> writeCharacteristic(
    final BleCharacteristicRef ref,
    final List<int> value, {
    final bool withoutResponse = false,
  }) async {}

  @override
  Stream<List<int>> subscribeToCharacteristic(final BleCharacteristicRef ref) =>
      const Stream<List<int>>.empty();

  @override
  void clearDeviceCache(final String deviceId) {}
}

void main() {
  group('ReactiveBleRepository', () {
    test('ensureReady succeeds when radio is ready', () async {
      final ReactiveBleRepository repository = ReactiveBleRepository(
        client: _FakeBleRadioClient(status: BleStatus.ready),
        timerService: DefaultTimerService(),
      );
      addTearDown(repository.dispose);

      final Result<void> result = await repository.ensureReady();
      expect(result.isSuccess, isTrue);
    });

    test('ensureReady maps unauthorized to permission failure', () async {
      final ReactiveBleRepository repository = ReactiveBleRepository(
        client: _FakeBleRadioClient(status: BleStatus.unauthorized),
        timerService: DefaultTimerService(),
      );
      addTearDown(repository.dispose);

      final Result<void> result = await repository.ensureReady();
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<PermissionFailure>());
    });

    test('ensureReady retries after permission gateway grants', () async {
      final ReactiveBleRepository repository = ReactiveBleRepository(
        client: _FakeBleRadioClient(status: BleStatus.unauthorized),
        timerService: DefaultTimerService(),
        permissionGateway: const _FakeBlePermissionGateway(granted: true),
      );
      addTearDown(repository.dispose);

      final Result<void> result = await repository.ensureReady();
      expect(result.isFailure, isTrue);
    });

    test('ensureReady maps poweredOff to bluetooth disabled', () async {
      final ReactiveBleRepository repository = ReactiveBleRepository(
        client: _FakeBleRadioClient(status: BleStatus.poweredOff),
        timerService: DefaultTimerService(),
      );
      addTearDown(repository.dispose);

      final Result<void> result = await repository.ensureReady();
      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        const ValidationFailure('bluetooth_disabled'),
      );
    });

    test('ensureReady maps unsupported radio to platform failure', () async {
      final ReactiveBleRepository repository = ReactiveBleRepository(
        client: _FakeBleRadioClient(status: BleStatus.unsupported),
        timerService: DefaultTimerService(),
      );
      addTearDown(repository.dispose);

      final Result<void> result = await repository.ensureReady();
      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull,
        const PlatformFailure(PlatformFailureReason.unavailable),
      );
    });

    test('connect waits for connected state and publishes phases', () async {
      final _FakeBleRadioClient client = _FakeBleRadioClient(
        status: BleStatus.ready,
        connectionUpdates: const <ConnectionStateUpdate>[
          ConnectionStateUpdate(
            deviceId: 'device-1',
            connectionState: DeviceConnectionState.connecting,
            failure: null,
          ),
          ConnectionStateUpdate(
            deviceId: 'device-1',
            connectionState: DeviceConnectionState.connected,
            failure: null,
          ),
        ],
      );
      final ReactiveBleRepository repository = ReactiveBleRepository(
        client: client,
        timerService: DefaultTimerService(),
      );
      addTearDown(repository.dispose);
      final List<BleConnectionPhaseKind> phases = <BleConnectionPhaseKind>[];
      final StreamSubscription<void> subscription = repository
          .watchConnection('device-1')
          .listen((final phase) {
            phases.add(phase.phase);
          });
      addTearDown(subscription.cancel);

      final Result<void> result = await repository.connect('device-1');

      expect(result.isSuccess, isTrue);
      expect(client.connectCalls, 1);
      expect(phases, <BleConnectionPhaseKind>[
        BleConnectionPhaseKind.connecting,
        BleConnectionPhaseKind.connected,
      ]);
    });
  });
}
