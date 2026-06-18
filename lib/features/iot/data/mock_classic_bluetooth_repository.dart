import 'dart:async';

import 'package:flutter_bloc_app/core/domain/failure.dart';
import 'package:flutter_bloc_app/core/domain/result.dart';
import 'package:flutter_bloc_app/features/iot/domain/classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/classic_bt_device.dart';

/// Mock RFCOMM-style chat for the Classic Bluetooth section.
class MockClassicBluetoothRepository implements ClassicBluetoothRepository {
  MockClassicBluetoothRepository() {
    _pairedController.add(List<ClassicBtDevice>.unmodifiable(_paired));
  }
  final StreamController<List<ClassicBtDevice>> _pairedController =
      StreamController<List<ClassicBtDevice>>.broadcast();
  final Map<String, StreamController<ClassicBtMessage>> _incomingControllers =
      <String, StreamController<ClassicBtMessage>>{};

  static const List<ClassicBtDevice> _paired = <ClassicBtDevice>[
    ClassicBtDevice(id: 'classic-speaker', name: 'BT Speaker'),
    ClassicBtDevice(id: 'classic-headset', name: 'BT Headset'),
  ];

  String? _connectedId;

  @override
  Stream<List<ClassicBtDevice>> watchPairedDevices() =>
      _pairedController.stream;

  @override
  Future<Result<void>> connect(final String deviceId) async {
    if (!_paired.any((final d) => d.id == deviceId)) {
      return const FailureResult<void>(
        ValidationFailure('device_not_found'),
      );
    }
    _connectedId = deviceId;
    _emitPaired();
    return const Success<void>(null);
  }

  @override
  Future<void> disconnect() async {
    _connectedId = null;
    _emitPaired();
  }

  @override
  Future<Result<void>> send(
    final String deviceId,
    final String message,
  ) async {
    if (_connectedId != deviceId) {
      return const FailureResult<void>(ValidationFailure('not_connected'));
    }
    _incomingController(deviceId).add(
      ClassicBtMessage(
        direction: ClassicBtMessageDirection.incoming,
        text: 'Echo: $message',
        timestamp: DateTime.now(),
      ),
    );
    return const Success<void>(null);
  }

  @override
  Stream<ClassicBtMessage> watchIncoming(final String deviceId) =>
      _incomingController(deviceId).stream;

  void dispose() {
    unawaited(_pairedController.close());
    for (final StreamController<ClassicBtMessage> c
        in _incomingControllers.values) {
      unawaited(c.close());
    }
  }

  void _emitPaired() {
    final List<ClassicBtDevice> devices = _paired
        .map(
          (final device) => device.copyWith(
            isConnected: device.id == _connectedId,
          ),
        )
        .toList(growable: false);
    _pairedController.add(devices);
  }

  StreamController<ClassicBtMessage> _incomingController(
    final String deviceId,
  ) => _incomingControllers.putIfAbsent(
    deviceId,
    StreamController<ClassicBtMessage>.broadcast,
  );
}
