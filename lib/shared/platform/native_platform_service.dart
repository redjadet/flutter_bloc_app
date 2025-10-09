import 'package:flutter/services.dart';

const String _channelName = 'com.example.flutter_bloc_app/native';
const String _methodGetPlatformInfo = 'getPlatformInfo';
const String _keyBatteryLevel = 'batteryLevel';

class NativePlatformService {
  NativePlatformService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  final MethodChannel _channel;

  Future<NativePlatformInfo> getPlatformInfo() async {
    final Map<String, dynamic>? result = await _channel
        .invokeMapMethod<String, dynamic>(_methodGetPlatformInfo);
    return NativePlatformInfo.fromMap(result);
  }
}

class NativePlatformInfo {
  const NativePlatformInfo({
    required this.platform,
    required this.version,
    this.manufacturer,
    this.model,
    this.batteryLevel,
  });

  factory NativePlatformInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const NativePlatformInfo(platform: 'unknown', version: 'unknown');
    }
    return NativePlatformInfo(
      platform: (map['platform'] as String?)?.trim().isNotEmpty == true
          ? (map['platform'] as String)
          : 'unknown',
      version: (map['version'] as String?)?.trim().isNotEmpty == true
          ? (map['version'] as String)
          : 'unknown',
      manufacturer: (map['manufacturer'] as String?)?.trim().isNotEmpty == true
          ? (map['manufacturer'] as String)
          : null,
      model: (map['model'] as String?)?.trim().isNotEmpty == true
          ? (map['model'] as String)
          : null,
      batteryLevel: (map[_keyBatteryLevel] as num?)?.toInt(),
    );
  }

  final String platform;
  final String version;
  final String? manufacturer;
  final String? model;
  final int? batteryLevel;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('$platform $version');
    if (manufacturer != null || model != null) {
      buffer.write(' [');
      if (manufacturer != null) {
        buffer.write(manufacturer);
      }
      if (manufacturer != null && model != null) {
        buffer.write(' ');
      }
      if (model != null) {
        buffer.write(model);
      }
      buffer.write(']');
    }
    if (batteryLevel != null) {
      buffer.write(' (battery: $batteryLevel%)');
    }
    return buffer.toString();
  }
}
