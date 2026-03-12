import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';

/// Payload key for Supabase user ID in IoT demo sync operation payloads.
const String iotDemoSyncPayloadKeySupabaseUserId = 'supabaseUserId';

/// Builds the base payload map for a sync operation (deviceId, action, optional userId).
Map<String, dynamic> iotDemoBasePayloadForUser(
  final String deviceId,
  final String action, {
  required final String? supabaseUserId,
}) {
  final Map<String, dynamic> payload = <String, dynamic>{
    'deviceId': deviceId,
    'action': action,
  };
  if (supabaseUserId case final String userId) {
    payload[iotDemoSyncPayloadKeySupabaseUserId] = userId;
  }
  return payload;
}

/// Converts [command] to the sync payload map for the 'command' action.
Map<String, dynamic> iotDemoCommandToPayload(final IotDeviceCommand command) {
  if (command is IotDeviceCommandToggle) {
    return <String, dynamic>{'kind': 'toggle'};
  }
  if (command is IotDeviceCommandSetValue) {
    return <String, dynamic>{
      'kind': 'setValue',
      'value': command.value.toDouble(),
    };
  }
  return <String, dynamic>{};
}
