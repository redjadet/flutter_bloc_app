import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';

/// Wire DTO for [IotDevice] Hive persistence.
class const IotDeviceDto({
  required final String id,
  required final String name,
  required final IotDeviceType type,
  final DateTime? lastSeen,
  final IotConnectionState connectionState = .disconnected,
  final bool toggledOn = false,
  final double value = 0,
}) {
  IotDeviceDto.fromDomain(IotDevice device)
    : this(
        id: device.id,
        name: device.name,
        type: device.type,
        lastSeen: device.lastSeen,
        connectionState: device.connectionState,
        toggledOn: device.toggledOn,
        value: device.value,
      );

  factory IotDeviceDto.fromJson(Map<String, dynamic> json) => IotDeviceDto(
    id: json['id'] as String,
    name: json['name'] as String,
    type: _deviceTypeFromWire(json['type'] as String?),
    lastSeen: json['lastSeen'] == null
        ? null
        : DateTime.parse(json['lastSeen'] as String),
    connectionState: _connectionStateFromWire(
      json['connectionState'] as String?,
    ),
    toggledOn: json['toggledOn'] as bool? ?? false,
    value: (json['value'] as num?)?.toDouble() ?? 0,
  );

  IotDevice toDomain() => IotDevice(
    id: id,
    name: name,
    type: type,
    lastSeen: lastSeen,
    connectionState: connectionState,
    toggledOn: toggledOn,
    value: value,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'type': _deviceTypeToWire(type),
    'lastSeen': lastSeen?.toIso8601String(),
    'connectionState': _connectionStateToWire(connectionState),
    'toggledOn': toggledOn,
    'value': value,
  };

  static IotDeviceType _deviceTypeFromWire(String? raw) {
    return switch (raw) {
      'light' => IotDeviceType.light,
      'sensor' => IotDeviceType.sensor,
      'switch_' => IotDeviceType.switch_,
      'thermostat' => IotDeviceType.thermostat,
      'plug' => IotDeviceType.plug,
      _ => throw FormatException('Unknown IotDeviceType: $raw'),
    };
  }

  static String _deviceTypeToWire(IotDeviceType type) {
    return switch (type) {
      IotDeviceType.light => 'light',
      IotDeviceType.sensor => 'sensor',
      IotDeviceType.switch_ => 'switch_',
      IotDeviceType.thermostat => 'thermostat',
      IotDeviceType.plug => 'plug',
    };
  }

  static IotConnectionState _connectionStateFromWire(String? raw) {
    return switch (raw) {
      'connecting' => IotConnectionState.connecting,
      'connected' => IotConnectionState.connected,
      'disconnected' || null => IotConnectionState.disconnected,
      _ => throw FormatException('Unknown IotConnectionState: $raw'),
    };
  }

  static String _connectionStateToWire(IotConnectionState state) {
    return switch (state) {
      IotConnectionState.disconnected => 'disconnected',
      IotConnectionState.connecting => 'connecting',
      IotConnectionState.connected => 'connected',
    };
  }
}
