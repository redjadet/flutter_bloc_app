import 'dart:async';

import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Sanitizes [supabaseUserId] for use in a Hive box name (alphanumeric, underscore, hyphen).
String _sanitizeBoxSuffix(final String supabaseUserId) {
  return supabaseUserId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
}

/// Hive-backed implementation of [IotDemoRepository].
/// Persists device list per Supabase user; each user has a separate box.
/// Empty storage returns an empty list (no shared defaults).
class PersistentIotDemoRepository extends HiveRepositoryBase
    implements IotDemoRepository {
  PersistentIotDemoRepository({
    required super.hiveService,
    required final String supabaseUserId,
  }) : _boxNameSuffix = _sanitizeBoxSuffix(
         PersistentIotDemoRepository._validateUserId(supabaseUserId),
       );

  static String _validateUserId(final String supabaseUserId) {
    final String trimmed = supabaseUserId.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('supabaseUserId must not be empty or whitespace');
    }
    return trimmed;
  }

  final String _boxNameSuffix;
  static const String _keyDevices = 'devices';
  static const Duration _connectDelay = Duration(milliseconds: 400);

  @override
  String get boxName => 'iot_demo_devices_$_boxNameSuffix';

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) => _watchDevicesStream(filter);

  Stream<List<IotDevice>> _watchDevicesStream(
    final IotDemoDeviceFilter filter,
  ) async* {
    final Box<dynamic> box = await getBox();
    List<IotDevice> devices = await _loadDevices(box);
    yield List<IotDevice>.unmodifiable(_applyFilter(devices, filter));
    await for (final BoxEvent event in box.watch()) {
      if (event.key == _keyDevices) {
        devices = await _loadDevices(box);
        yield List<IotDevice>.unmodifiable(_applyFilter(devices, filter));
      }
    }
  }

  List<IotDevice> _applyFilter(
    final List<IotDevice> devices,
    final IotDemoDeviceFilter filter,
  ) {
    if (filter == IotDemoDeviceFilter.toggledOnOnly) {
      return devices.where((final d) => d.toggledOn).toList();
    }
    if (filter == IotDemoDeviceFilter.toggledOffOnly) {
      return devices.where((final d) => !d.toggledOn).toList();
    }
    return devices;
  }

  Future<List<IotDevice>> _loadDevices(final Box<dynamic> box) async =>
      StorageGuard.run<List<IotDevice>>(
        logContext: 'PersistentIotDemoRepository._loadDevices',
        action: () async {
          final dynamic raw = box.get(_keyDevices);
          final List<dynamic>? list = listFromDynamic(raw);
          if (list == null || list.isEmpty) {
            return List<IotDevice>.unmodifiable(<IotDevice>[]);
          }
          try {
            final List<IotDevice> result = <IotDevice>[];
            for (final dynamic item in list) {
              final Map<String, dynamic>? map = mapFromDynamic(item);
              if (map != null) {
                result.add(IotDevice.fromJson(map));
              }
            }
            return List<IotDevice>.unmodifiable(result);
          } on Object catch (error, stackTrace) {
            AppLogger.error(
              'PersistentIotDemoRepository parse devices',
              error,
              stackTrace,
            );
            return List<IotDevice>.unmodifiable(<IotDevice>[]);
          }
        },
        fallback: () => List<IotDevice>.unmodifiable(<IotDevice>[]),
      );

  Future<void> _saveDevices(
    final Box<dynamic> box,
    final List<IotDevice> devices,
  ) async => StorageGuard.run<void>(
    logContext: 'PersistentIotDemoRepository._saveDevices',
    action: () async {
      final List<Map<String, dynamic>> serialized = devices
          .map((final d) => d.toJson())
          .toList(growable: false);
      await box.put(_keyDevices, serialized);
    },
    fallback: () {},
  );

  /// Appends [device] to the stored list and saves.
  @override
  Future<void> addDevice(final IotDevice device) async {
    if (device.id.trim().isEmpty || device.name.trim().isEmpty) {
      throw ArgumentError('device id and name must not be empty');
    }
    if (device.name.length > iotDemoDeviceNameMaxLength) {
      throw ArgumentError(
        'device name must not exceed $iotDemoDeviceNameMaxLength characters',
      );
    }
    await StorageGuard.run<void>(
      logContext: 'PersistentIotDemoRepository.addDevice',
      action: () async {
        final Box<dynamic> box = await getBox();
        final List<IotDevice> devices = await _loadDevices(box);
        if (devices.any((final d) => d.id == device.id)) return;
        final List<IotDevice> updated = List<IotDevice>.from(devices)
          ..add(device);
        await _saveDevices(box, updated);
      },
      fallback: () {},
    );
  }

  /// Replaces the stored device list with [devices].
  /// Used by offline-first pullRemote to write merged data from Supabase.
  Future<void> replaceDevices(final List<IotDevice> devices) async {
    await StorageGuard.run<void>(
      logContext: 'PersistentIotDemoRepository.replaceDevices',
      action: () async {
        final Box<dynamic> box = await getBox();
        await _saveDevices(
          box,
          List<IotDevice>.unmodifiable(devices),
        );
      },
      fallback: () {},
    );
  }

  int _indexOf(final List<IotDevice> devices, final String deviceId) =>
      devices.indexWhere((final d) => d.id == deviceId);

  @override
  Future<void> connect(final String deviceId) async {
    await StorageGuard.run<void>(
      logContext: 'PersistentIotDemoRepository.connect',
      action: () async {
        final Box<dynamic> box = await getBox();
        List<IotDevice> devices = await _loadDevices(box);
        final int i = _indexOf(devices, deviceId);
        if (i < 0) return;
        devices = List<IotDevice>.from(devices);
        devices[i] = devices[i].copyWith(
          connectionState: IotConnectionState.connecting,
          lastSeen: DateTime.now(),
        );
        await _saveDevices(box, devices);
        await Future<void>.delayed(_connectDelay);
        devices = await _loadDevices(box);
        final int idx = _indexOf(devices, deviceId);
        if (idx >= 0) {
          if (devices[idx].connectionState != IotConnectionState.connecting) {
            return;
          }
          devices = List<IotDevice>.from(devices);
          devices[idx] = devices[idx].copyWith(
            connectionState: IotConnectionState.connected,
            lastSeen: DateTime.now(),
          );
          await _saveDevices(box, devices);
        }
      },
      fallback: () {},
    );
  }

  @override
  Future<void> disconnect(final String deviceId) async {
    await StorageGuard.run<void>(
      logContext: 'PersistentIotDemoRepository.disconnect',
      action: () async {
        final Box<dynamic> box = await getBox();
        final List<IotDevice> devices = await _loadDevices(box);
        final int i = _indexOf(devices, deviceId);
        if (i < 0) return;
        final List<IotDevice> updated = List<IotDevice>.from(devices);
        updated[i] = updated[i].copyWith(
          connectionState: IotConnectionState.disconnected,
        );
        await _saveDevices(box, updated);
      },
      fallback: () {},
    );
  }

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {
    await StorageGuard.run<void>(
      logContext: 'PersistentIotDemoRepository.sendCommand',
      action: () async {
        final Box<dynamic> box = await getBox();
        final List<IotDevice> devices = await _loadDevices(box);
        final int i = _indexOf(devices, deviceId);
        if (i < 0) return;
        final IotDevice d = devices[i];
        final IotDevice updated;
        if (command is IotDeviceCommandToggle) {
          updated = d.copyWith(toggledOn: !d.toggledOn);
        } else if (command is IotDeviceCommandSetValue) {
          final double nextValue = iotDemoClampAndRound(
            command.value.toDouble(),
            iotDemoValueMin,
            iotDemoValueMax,
          );
          // Avoid unnecessary storage writes (e.g. slider jitter sending same value).
          if (nextValue == d.value) {
            return;
          }
          updated = d.copyWith(value: nextValue);
        } else {
          updated = d;
        }
        final List<IotDevice> list = List<IotDevice>.from(devices);
        list[i] = updated.copyWith(lastSeen: DateTime.now());
        await _saveDevices(box, list);
      },
      fallback: () {},
    );
  }
}
