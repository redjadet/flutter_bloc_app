import 'dart:async';

import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Default device list used when storage is empty or invalid.
List<IotDevice> _defaultDevices() => List<IotDevice>.unmodifiable(<IotDevice>[
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
]);

/// Hive-backed implementation of [IotDemoRepository].
/// Persists device list (connection state, toggledOn, value) so values
/// survive app restarts.
class PersistentIotDemoRepository extends HiveRepositoryBase
    implements IotDemoRepository {
  PersistentIotDemoRepository({required super.hiveService});

  static const String _boxName = 'iot_demo_devices';
  static const String _keyDevices = 'devices';
  static const Duration _connectDelay = Duration(milliseconds: 400);

  @override
  String get boxName => _boxName;

  @override
  Stream<List<IotDevice>> watchDevices() => _watchDevicesStream();

  Stream<List<IotDevice>> _watchDevicesStream() async* {
    final Box<dynamic> box = await getBox();
    List<IotDevice> devices = await _loadDevices(box);
    yield List<IotDevice>.unmodifiable(devices);
    await for (final BoxEvent event in box.watch()) {
      if (event.key == _keyDevices) {
        devices = await _loadDevices(box);
        yield devices;
      }
    }
  }

  Future<List<IotDevice>> _loadDevices(final Box<dynamic> box) async =>
      StorageGuard.run<List<IotDevice>>(
        logContext: 'PersistentIotDemoRepository._loadDevices',
        action: () async {
          final dynamic raw = box.get(_keyDevices);
          final List<dynamic>? list = listFromDynamic(raw);
          if (list == null || list.isEmpty) {
            final List<IotDevice> defaultList = _defaultDevices();
            await _saveDevices(box, defaultList);
            return defaultList;
          }
          try {
            final List<IotDevice> result = <IotDevice>[];
            for (final dynamic item in list) {
              final Map<String, dynamic>? map = mapFromDynamic(item);
              if (map != null) {
                result.add(IotDevice.fromJson(map));
              }
            }
            if (result.isEmpty) {
              final List<IotDevice> defaultList = _defaultDevices();
              await _saveDevices(box, defaultList);
              return defaultList;
            }
            return List<IotDevice>.unmodifiable(result);
          } on Object catch (error, stackTrace) {
            AppLogger.error(
              'PersistentIotDemoRepository parse devices',
              error,
              stackTrace,
            );
            final List<IotDevice> defaultList = _defaultDevices();
            await _saveDevices(box, defaultList);
            return defaultList;
          }
        },
        fallback: () => _defaultDevices(),
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
