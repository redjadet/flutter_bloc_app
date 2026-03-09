import 'package:flutter_bloc_app/features/iot_demo/data/offline_first_iot_demo_repository.dart'
    show OfflineFirstIotDemoRepository;
import 'package:flutter_bloc_app/features/iot_demo/data/supabase_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

/// Applies a single IoT demo sync operation payload to the remote repository.
///
/// Called by [OfflineFirstIotDemoRepository.processOperation] after
/// validating user and payload. [payload] must contain at least
/// `deviceId` and `action`; action-specific fields are validated here.
Future<void> applyIotDemoSyncOperation(
  final SupabaseIotDemoRepository remote,
  final Map<String, dynamic> payload,
) async {
  final String? deviceId = stringFromDynamicTrimmed(payload['deviceId']);
  final String? action = stringFromDynamicTrimmed(payload['action']);
  if (deviceId == null || deviceId.isEmpty || action == null) {
    AppLogger.warning(
      'applyIotDemoSyncOperation: missing deviceId or action',
    );
    return;
  }
  try {
    switch (action) {
      case 'add':
        final String? name = stringFromDynamicTrimmed(payload['name']);
        final String? typeStr = stringFromDynamicTrimmed(payload['type']);
        if (name == null || name.isEmpty || typeStr == null) {
          AppLogger.warning(
            'applyIotDemoSyncOperation add: missing name or type',
          );
          return;
        }
        if (name.length > iotDemoDeviceNameMaxLength) {
          AppLogger.warning(
            'applyIotDemoSyncOperation add: '
            'name exceeds $iotDemoDeviceNameMaxLength characters',
          );
          return;
        }
        final IotDeviceType? type = _parseDeviceTypeFromName(typeStr);
        if (type == null) {
          AppLogger.warning(
            'applyIotDemoSyncOperation add: invalid type $typeStr',
          );
          return;
        }
        final bool toggledOn = boolFromDynamic(
          payload['toggledOn'],
          fallback: false,
        );
        final double value = doubleFromDynamic(
          payload['value'],
          iotDemoValueMin,
        );
        final IotDevice toAdd = IotDevice(
          id: deviceId,
          name: name,
          type: type,
          toggledOn: toggledOn,
          value: iotDemoClampAndRound(
            value,
            iotDemoValueMin,
            iotDemoValueMax,
          ),
        );
        await remote.addDevice(toAdd);
        break;
      case 'connect':
        await remote.connect(deviceId);
        break;
      case 'disconnect':
        await remote.disconnect(deviceId);
        break;
      case 'command':
        final IotDeviceCommand? cmd = _payloadToCommand(payload);
        if (cmd != null) {
          await remote.sendCommand(deviceId, cmd);
        }
        break;
      default:
        AppLogger.warning(
          'applyIotDemoSyncOperation: unknown action $action',
        );
    }
  } on Object catch (error, stackTrace) {
    AppLogger.error(
      'applyIotDemoSyncOperation',
      error,
      stackTrace,
    );
    rethrow;
  }
}

IotDeviceType? _parseDeviceTypeFromName(final String value) {
  switch (value) {
    case 'light':
      return IotDeviceType.light;
    case 'thermostat':
      return IotDeviceType.thermostat;
    case 'plug':
      return IotDeviceType.plug;
    case 'sensor':
      return IotDeviceType.sensor;
    case 'switch_':
      return IotDeviceType.switch_;
    default:
      return null;
  }
}

IotDeviceCommand? _payloadToCommand(final Map<String, dynamic> payload) {
  final String? kind = stringFromDynamicTrimmed(payload['kind']);
  if (kind == 'toggle') {
    return const IotDeviceCommand.toggle();
  }
  if (kind == 'setValue') {
    final double v = doubleFromDynamic(
      payload['value'],
      iotDemoValueMin,
    );
    return IotDeviceCommand.setValue(
      iotDemoClampAndRound(v, iotDemoValueMin, iotDemoValueMax),
    );
  }
  return null;
}
