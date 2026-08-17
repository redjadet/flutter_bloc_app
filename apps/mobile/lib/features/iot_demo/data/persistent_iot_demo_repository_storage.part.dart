part of 'persistent_iot_demo_repository.dart';

extension _PersistentIotDemoRepositoryStorage on PersistentIotDemoRepository {
  Stream<List<IotDevice>> watchDevicesStream(
    IotDemoDeviceFilter filter,
  ) async* {
    final Box<dynamic> box = await getBox();
    List<IotDevice> devices = await _loadDevices(box);
    yield List<IotDevice>.unmodifiable(_applyFilter(devices, filter));
    await for (final BoxEvent event in box.watch()) {
      if (event.key == PersistentIotDemoRepository._keyDevices) {
        devices = await _loadDevices(box);
        yield List<IotDevice>.unmodifiable(_applyFilter(devices, filter));
      }
    }
  }

  List<IotDevice> _applyFilter(
    List<IotDevice> devices,
    IotDemoDeviceFilter filter,
  ) {
    if (filter == IotDemoDeviceFilter.toggledOnOnly) {
      return devices.where((d) => d.toggledOn).toList();
    }
    if (filter == IotDemoDeviceFilter.toggledOffOnly) {
      return devices.where((d) => !d.toggledOn).toList();
    }
    return devices;
  }

  Future<List<IotDevice>> _loadDevices(Box<dynamic> box) async =>
      StorageGuard.run<List<IotDevice>>(
        logContext: 'PersistentIotDemoRepository._loadDevices',
        action: () async {
          final dynamic raw = box.get(PersistentIotDemoRepository._keyDevices);
          final List<dynamic>? list = listFromDynamic(raw);
          if (list == null || list.isEmpty) {
            return List<IotDevice>.unmodifiable(<IotDevice>[]);
          }
          try {
            final List<IotDevice> result = <IotDevice>[];
            for (final dynamic item in list) {
              final Map<String, dynamic>? map = mapFromDynamic(item);
              if (map != null) {
                result.add(IotDeviceDto.fromJson(map).toDomain());
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
    Box<dynamic> box,
    List<IotDevice> devices,
  ) async => StorageGuard.run<void>(
    logContext: 'PersistentIotDemoRepository._saveDevices',
    action: () async {
      final List<Map<String, dynamic>> serialized = devices
          .map((d) => IotDeviceDto.fromDomain(d).toJson())
          .toList(growable: false);
      await box.put(PersistentIotDemoRepository._keyDevices, serialized);
    },
  );

  /// Appends [device] to the stored list and saves.
  Future<void> addDeviceImpl(IotDevice device) async {
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
        if (devices.any((d) => d.id == device.id)) return;
        final List<IotDevice> updated = List<IotDevice>.from(devices)
          ..add(device);
        await _saveDevices(box, updated);
      },
    );
  }

  /// Replaces the stored device list with [devices].
  /// Used by offline-first pullRemote to write merged data from Supabase.
  Future<void> replaceDevicesImpl(List<IotDevice> devices) async {
    await StorageGuard.run<void>(
      logContext: 'PersistentIotDemoRepository.replaceDevices',
      action: () async {
        final Box<dynamic> box = await getBox();
        await _saveDevices(box, List<IotDevice>.unmodifiable(devices));
      },
    );
  }

  int _indexOf(List<IotDevice> devices, String deviceId) =>
      devices.indexWhere((d) => d.id == deviceId);

  Future<void> connectImpl(String deviceId) async {
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
        await _delay(PersistentIotDemoRepository._connectDelay);
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
    );
  }

  Future<void> disconnectImpl(String deviceId) async {
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
    );
  }

  Future<void> sendCommandImpl(
    String deviceId,
    IotDeviceCommand command,
  ) async {
    await StorageGuard.run<void>(
      logContext: 'PersistentIotDemoRepository.sendCommand',
      action: () async {
        final Box<dynamic> box = await getBox();
        final List<IotDevice> devices = await _loadDevices(box);
        final int i = _indexOf(devices, deviceId);
        if (i < 0) return;
        final IotDevice d = devices[i];
        if (command case IotDeviceCommandSetValue(:final value)) {
          final double nextValue = iotDemoClampAndRound(
            value.toDouble(),
            iotDemoValueMin,
            iotDemoValueMax,
          );
          // Avoid unnecessary storage writes (e.g. slider jitter sending same value).
          if (nextValue == d.value) {
            return;
          }
        }
        final IotDevice updated = switch (command) {
          IotDeviceCommandToggle() => d.copyWith(toggledOn: !d.toggledOn),
          IotDeviceCommandSetValue(:final value) => d.copyWith(
            value: iotDemoClampAndRound(
              value.toDouble(),
              iotDemoValueMin,
              iotDemoValueMax,
            ),
          ),
        };
        final List<IotDevice> list = List<IotDevice>.from(devices);
        list[i] = updated.copyWith(lastSeen: DateTime.now());
        await _saveDevices(box, list);
      },
    );
  }
}
