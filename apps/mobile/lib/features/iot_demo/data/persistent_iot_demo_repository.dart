import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/iot_device_dto.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';
import 'package:storage/storage.dart';

part 'persistent_iot_demo_repository_storage.part.dart';

/// Sanitizes [supabaseUserId] for use in a Hive box name (alphanumeric, underscore, hyphen).
String _sanitizeBoxSuffix(String supabaseUserId) {
  return supabaseUserId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
}

/// Hive-backed implementation of [IotDemoRepository].
/// Persists device list per Supabase user; each user has a separate box.
/// Empty storage returns an empty list (no shared defaults).
class PersistentIotDemoRepository extends HiveRepositoryBase
    implements IotDemoRepository {
  PersistentIotDemoRepository({
    required super.hiveService,
    required String supabaseUserId,
    required this._timerService,
  }) : _boxNameSuffix = _sanitizeBoxSuffix(
         PersistentIotDemoRepository._validateUserId(supabaseUserId),
       );

  static String _validateUserId(String supabaseUserId) {
    final String trimmed = supabaseUserId.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('supabaseUserId must not be empty or whitespace');
    }
    return trimmed;
  }

  final String _boxNameSuffix;
  final TimerService _timerService;
  static const String _keyDevices = 'devices';
  static const Duration _connectDelay = Duration(milliseconds: 400);

  Future<void> _delay(Duration duration) {
    if (duration <= Duration.zero) {
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    _timerService.runOnce(duration, completer.complete);
    return completer.future;
  }

  @override
  String get boxName => 'iot_demo_devices_$_boxNameSuffix';

  @override
  Stream<List<IotDevice>> watchDevices([
    IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) => watchDevicesStream(filter);

  @override
  Future<void> addDevice(IotDevice device) => addDeviceImpl(device);

  Future<void> replaceDevices(List<IotDevice> devices) =>
      replaceDevicesImpl(devices);

  @override
  Future<void> connect(String deviceId) => connectImpl(deviceId);

  @override
  Future<void> disconnect(String deviceId) => disconnectImpl(deviceId);

  @override
  Future<void> sendCommand(
    String deviceId,
    IotDeviceCommand command,
  ) => sendCommandImpl(deviceId, command);
}
