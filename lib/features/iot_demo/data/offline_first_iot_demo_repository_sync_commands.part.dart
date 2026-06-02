part of 'offline_first_iot_demo_repository.dart';

Future<void> addDeviceImpl(
  final OfflineFirstIotDemoRepository r,
  final IotDevice device,
) async {
  if (device.id.trim().isEmpty || device.name.trim().isEmpty) {
    throw ArgumentError('device id and name must not be empty');
  }
  if (device.name.length > iotDemoDeviceNameMaxLength) {
    throw ArgumentError(
      'device name must not exceed $iotDemoDeviceNameMaxLength characters',
    );
  }
  final PersistentIotDemoRepository? local = r._getLocalRepository();
  if (local == null) return;
  final String? userId = r._currentSupabaseUserId();
  if (userId == null) return;
  await local.addDevice(device);
  if (r._remoteRepository == null) return;
  final String idempotencyKey =
      '${OfflineFirstIotDemoRepository.iotDemoEntity}_add_${device.id}_${DateTime.now().microsecondsSinceEpoch}';
  await r._pendingSyncRepository.enqueue(
    SyncOperation.create(
      entityType: r.entityType,
      payload: <String, dynamic>{
        'deviceId': device.id,
        'action': 'add',
        'name': device.name,
        'type': device.type.name,
        'toggledOn': device.toggledOn,
        'value': device.value,
        iotDemoSyncPayloadKeySupabaseUserId: userId,
      },
      idempotencyKey: idempotencyKey,
    ),
  );
}

Future<void> connectImpl(
  final OfflineFirstIotDemoRepository r,
  final String deviceId,
) async {
  final PersistentIotDemoRepository? local = r._getLocalRepository();
  if (local == null) return;
  await local.connect(deviceId);
  if (r._remoteRepository == null) return;
  final String idempotencyKey =
      '${OfflineFirstIotDemoRepository.iotDemoEntity}_connect_${deviceId}_${DateTime.now().microsecondsSinceEpoch}';
  await r._pendingSyncRepository.enqueue(
    SyncOperation.create(
      entityType: r.entityType,
      payload: r._basePayload(deviceId, 'connect'),
      idempotencyKey: idempotencyKey,
    ),
  );
}

Future<void> disconnectImpl(
  final OfflineFirstIotDemoRepository r,
  final String deviceId,
) async {
  final PersistentIotDemoRepository? local = r._getLocalRepository();
  if (local == null) return;
  await local.disconnect(deviceId);
  if (r._remoteRepository == null) return;
  final String idempotencyKey =
      '${OfflineFirstIotDemoRepository.iotDemoEntity}_disconnect_${deviceId}_${DateTime.now().microsecondsSinceEpoch}';
  await r._pendingSyncRepository.enqueue(
    SyncOperation.create(
      entityType: r.entityType,
      payload: r._basePayload(deviceId, 'disconnect'),
      idempotencyKey: idempotencyKey,
    ),
  );
}

Future<void> sendCommandImpl(
  final OfflineFirstIotDemoRepository r,
  final String deviceId,
  final IotDeviceCommand command,
) async {
  final PersistentIotDemoRepository? local = r._getLocalRepository();
  if (local == null) return;
  final String? userId = r._currentSupabaseUserId();
  if (userId == null) return;
  await local.sendCommand(deviceId, command);
  if (r._remoteRepository == null) return;
  if (command is IotDeviceCommandSetValue) {
    _scheduleSetValueSyncImpl(
      r,
      userId: userId,
      deviceId: deviceId,
      value: command.value.toDouble(),
    );
    return;
  }
  await _enqueueCommandImpl(r, deviceId, iotDemoCommandToPayload(command));
}

void _scheduleSetValueSyncImpl(
  final OfflineFirstIotDemoRepository r, {
  required final String userId,
  required final String deviceId,
  required final double value,
}) {
  final String pendingKey = r._pendingSetValueKey(
    userId: userId,
    deviceId: deviceId,
  );
  final IotDemoPendingSetValue? existing =
      r._pendingSetValueByDevice[pendingKey];
  existing?.timer.dispose();
  r._timerHandles.unregister(existing?.timer);
  late final TimerDisposable timer;
  timer = r._timerService.runOnce(
    OfflineFirstIotDemoRepository.setValueSyncDebounce,
    () {
      r._pendingSetValueByDevice.remove(pendingKey);
      r._timerHandles.unregister(timer);
      unawaited(
        _enqueueSetValueCommandImpl(r, deviceId, value, supabaseUserId: userId),
      );
    },
  );
  r._timerHandles.register(timer);
  r._pendingSetValueByDevice[pendingKey] = IotDemoPendingSetValue(
    timer: timer,
  );
}

Future<void> _enqueueSetValueCommandImpl(
  final OfflineFirstIotDemoRepository r,
  final String deviceId,
  final double value, {
  required final String supabaseUserId,
}) {
  return _enqueueCommandImpl(
    r,
    deviceId,
    <String, dynamic>{
      'kind': 'setValue',
      'value': value,
    },
    supabaseUserId: supabaseUserId,
  );
}

Future<void> _enqueueCommandImpl(
  final OfflineFirstIotDemoRepository r,
  final String deviceId,
  final Map<String, dynamic> commandPayload, {
  final String? supabaseUserId,
}) async {
  final String idempotencyKey =
      '${OfflineFirstIotDemoRepository.iotDemoEntity}_command_${deviceId}_${DateTime.now().microsecondsSinceEpoch}';
  final String? effectiveUserId = supabaseUserId ?? r._currentSupabaseUserId();
  await r._pendingSyncRepository.enqueue(
    SyncOperation.create(
      entityType: r.entityType,
      payload: <String, dynamic>{
        ...iotDemoBasePayloadForUser(
          deviceId,
          'command',
          supabaseUserId: effectiveUserId,
        ),
        ...commandPayload,
      },
      idempotencyKey: idempotencyKey,
    ),
  );
}
