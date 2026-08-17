import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';

/// Repository contract for the IoT demo: list devices, connect, disconnect, send commands.
abstract class IotDemoRepository {
  /// Stream of the current device list; emits whenever devices change.
  /// [filter] controls whether all devices or only toggled-on devices are returned.
  Stream<List<IotDevice>> watchDevices([
    IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]);

  /// Connects to the device with [deviceId].
  Future<void> connect(String deviceId);

  /// Disconnects from the device with [deviceId].
  Future<void> disconnect(String deviceId);

  /// Sends [command] to the device with [deviceId].
  Future<void> sendCommand(
    String deviceId,
    IotDeviceCommand command,
  );

  /// Adds a new device. Writes to local storage and remote (Supabase) when
  /// available.
  Future<void> addDevice(IotDevice device);
}
