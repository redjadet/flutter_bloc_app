import 'dart:async';

import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';

/// Mock implementation: in-memory simulated devices, no real hardware.
class MockIotDemoRepository implements IotDemoRepository {
  MockIotDemoRepository() {
    _controller = StreamController<List<IotDevice>>.broadcast();
  }

  final List<IotDevice> _devices = [
    const IotDevice(
      id: 'light-1',
      name: 'Living Room Light',
      type: IotDeviceType.light,
    ),
    const IotDevice(
      id: 'thermostat-1',
      name: 'Thermostat',
      type: IotDeviceType.thermostat,
      value: 21,
    ),
    const IotDevice(
      id: 'plug-1',
      name: 'Smart Plug',
      type: IotDeviceType.plug,
    ),
    const IotDevice(
      id: 'sensor-1',
      name: 'Temperature Sensor',
      type: IotDeviceType.sensor,
      value: 22.5,
    ),
    const IotDevice(
      id: 'switch-1',
      name: 'Hall Switch',
      type: IotDeviceType.switch_,
    ),
  ];

  StreamController<List<IotDevice>>? _controller;

  static const Duration _connectDelay = Duration(milliseconds: 400);

  void _emitDevices() {
    final c = _controller;
    if (c != null && !c.isClosed) {
      c.add(List<IotDevice>.from(_devices));
    }
  }

  int _indexOf(final String deviceId) {
    return _devices.indexWhere((final d) => d.id == deviceId);
  }

  @override
  Stream<List<IotDevice>> watchDevices() {
    final StreamController<List<IotDevice>>? controller = _controller;
    if (controller == null || controller.isClosed) {
      return Stream<List<IotDevice>>.value(
        List<IotDevice>.unmodifiable(_devices),
      );
    }
    return Stream<List<IotDevice>>.multi((final multi) {
      multi.add(List<IotDevice>.unmodifiable(_devices));
      final StreamSubscription<List<IotDevice>> subscription = controller.stream
          .listen(
            multi.add,
            onError: multi.addError,
            onDone: multi.close,
          );
      multi
        ..onPause = subscription.pause
        ..onResume = subscription.resume
        ..onCancel = subscription.cancel;
    }, isBroadcast: true);
  }

  @override
  Future<void> connect(final String deviceId) async {
    final i = _indexOf(deviceId);
    if (i < 0) return;
    _devices[i] = _devices[i].copyWith(
      connectionState: IotConnectionState.connecting,
      lastSeen: DateTime.now(),
    );
    _emitDevices();
    await Future<void>.delayed(_connectDelay);
    if (_controller == null || _controller!.isClosed) return;
    final idx = _indexOf(deviceId);
    if (idx >= 0) {
      _devices[idx] = _devices[idx].copyWith(
        connectionState: IotConnectionState.connected,
        lastSeen: DateTime.now(),
      );
      _emitDevices();
    }
  }

  @override
  Future<void> disconnect(final String deviceId) async {
    final i = _indexOf(deviceId);
    if (i < 0) return;
    _devices[i] = _devices[i].copyWith(
      connectionState: IotConnectionState.disconnected,
    );
    _emitDevices();
  }

  @override
  Future<void> addDevice(final IotDevice device) async {
    if (device.id.trim().isEmpty || device.name.trim().isEmpty) {
      throw ArgumentError('device id and name must not be empty');
    }
    if (_indexOf(device.id) >= 0) return;
    _devices.add(device);
    _emitDevices();
  }

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {
    final i = _indexOf(deviceId);
    if (i < 0) return;
    final d = _devices[i];
    final IotDevice updated;
    if (command is IotDeviceCommandToggle) {
      updated = d.copyWith(toggledOn: !d.toggledOn);
    } else if (command is IotDeviceCommandSetValue) {
      updated = d.copyWith(value: command.value.toDouble());
    } else {
      updated = d;
    }
    _devices[i] = updated.copyWith(lastSeen: DateTime.now());
    _emitDevices();
  }

  /// Call from DI dispose if needed to avoid leaking the stream.
  Future<void> dispose() async {
    await _controller?.close();
    _controller = null;
  }
}
