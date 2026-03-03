// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iot_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IotDevice _$IotDeviceFromJson(Map<String, dynamic> json) => _IotDevice(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$IotDeviceTypeEnumMap, json['type']),
  lastSeen: json['lastSeen'] == null
      ? null
      : DateTime.parse(json['lastSeen'] as String),
  connectionState:
      $enumDecodeNullable(
        _$IotConnectionStateEnumMap,
        json['connectionState'],
      ) ??
      IotConnectionState.disconnected,
  toggledOn: json['toggledOn'] as bool? ?? false,
  value: (json['value'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$IotDeviceToJson(_IotDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$IotDeviceTypeEnumMap[instance.type]!,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'connectionState': _$IotConnectionStateEnumMap[instance.connectionState]!,
      'toggledOn': instance.toggledOn,
      'value': instance.value,
    };

const _$IotDeviceTypeEnumMap = {
  IotDeviceType.light: 'light',
  IotDeviceType.sensor: 'sensor',
  IotDeviceType.switch_: 'switch_',
  IotDeviceType.thermostat: 'thermostat',
  IotDeviceType.plug: 'plug',
};

const _$IotConnectionStateEnumMap = {
  IotConnectionState.disconnected: 'disconnected',
  IotConnectionState.connecting: 'connecting',
  IotConnectionState.connected: 'connected',
};
