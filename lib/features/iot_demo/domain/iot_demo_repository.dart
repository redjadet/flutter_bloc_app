import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';

/// Repository contract for the IoT demo: list devices, connect, disconnect, send commands.
abstract class IotDemoRepository {
  /// Stream of the current device list; emits whenever devices change.
  Stream<List<IotDevice>> watchDevices();

  /// Connects to the device with [deviceId].
  Future<void> connect(final String deviceId);

  /// Disconnects from the device with [deviceId].
  Future<void> disconnect(final String deviceId);

  /// Sends [command] to the device with [deviceId].
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  );

  /// Adds a new device. Writes to local storage and remote (Supabase) when
  /// available.
  Future<void> addDevice(final IotDevice device);
}
