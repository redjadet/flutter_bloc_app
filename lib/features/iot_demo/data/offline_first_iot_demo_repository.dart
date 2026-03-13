import 'dart:async';

import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_pending_set_value.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_sync_operation_applier.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_sync_payloads.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/persistent_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/supabase_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_device_filter.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_value_range.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_device_command.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

/// Offline-first implementation of [IotDemoRepository].
///
/// Serves device list from per-user Hive; connect/disconnect/sendCommand write
/// locally then enqueue sync ops with supabaseUserId in payload. pullRemote
/// fetches from Supabase and merges into local; processOperation applies only
/// ops for the current user (legacy ops without payload supabaseUserId are skipped).
class OfflineFirstIotDemoRepository
    implements IotDemoRepository, SyncableRepository {
  OfflineFirstIotDemoRepository({
    required final String? Function() getCurrentSupabaseUserId,
    required final PersistentIotDemoRepository Function(String)
    getPersistentRepository,
    required final PendingSyncRepository pendingSyncRepository,
    required final SyncableRepositoryRegistry registry,
    required final TimerService timerService,
    final SupabaseIotDemoRepository? remoteRepository,
  }) : _getCurrentSupabaseUserId = getCurrentSupabaseUserId,
       _getPersistentRepository = getPersistentRepository,
       _remoteRepository = remoteRepository,
       _pendingSyncRepository = pendingSyncRepository,
       _registry = registry,
       _timerService = timerService {
    _registry.register(this);
  }

  /// Delay after last slider/setValue change before enqueueing a sync op.
  static const Duration setValueSyncDebounce = Duration(milliseconds: 400);

  static const String iotDemoEntity = 'iot_demo';

  final String? Function() _getCurrentSupabaseUserId;
  final PersistentIotDemoRepository Function(String) _getPersistentRepository;
  final SupabaseIotDemoRepository? _remoteRepository;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;
  final TimerService _timerService;

  final Map<String, PersistentIotDemoRepository> _localCache =
      <String, PersistentIotDemoRepository>{};
  String? _cachedUserId;

  final Map<String, Future<void>> _pullRemoteInFlightByUser =
      <String, Future<void>>{};

  final Map<String, IotDemoPendingSetValue> _pendingSetValueByDevice =
      <String, IotDemoPendingSetValue>{};

  PersistentIotDemoRepository? _getLocalRepository() {
    final String? userId = _getCurrentSupabaseUserId();
    if (userId == null || userId.isEmpty) return null;
    if (_cachedUserId != null && _cachedUserId != userId) {
      _localCache.clear();
    }
    _cachedUserId = userId;
    return _localCache.putIfAbsent(
      userId,
      () => _getPersistentRepository(userId),
    );
  }

  @override
  String get entityType => iotDemoEntity;

  @override
  Stream<List<IotDevice>> watchDevices([
    final IotDemoDeviceFilter filter = IotDemoDeviceFilter.all,
  ]) {
    final PersistentIotDemoRepository? local = _getLocalRepository();
    if (local == null) {
      return Stream<List<IotDevice>>.value(const <IotDevice>[]);
    }
    return local.watchDevices(filter);
  }

  Map<String, dynamic> _basePayload(
    final String deviceId,
    final String action,
  ) => iotDemoBasePayloadForUser(
    deviceId,
    action,
    supabaseUserId: _currentSupabaseUserId(),
  );

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
    final PersistentIotDemoRepository? local = _getLocalRepository();
    if (local == null) return;
    final String? userId = _currentSupabaseUserId();
    if (userId == null) return;
    await local.addDevice(device);
    if (_remoteRepository == null) return;
    final String idempotencyKey =
        '${iotDemoEntity}_add_${device.id}_${DateTime.now().microsecondsSinceEpoch}';
    await _pendingSyncRepository.enqueue(
      SyncOperation.create(
        entityType: entityType,
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

  @override
  Future<void> connect(final String deviceId) async {
    final PersistentIotDemoRepository? local = _getLocalRepository();
    if (local == null) return;
    await local.connect(deviceId);
    if (_remoteRepository == null) return;
    final String idempotencyKey =
        '${iotDemoEntity}_connect_${deviceId}_${DateTime.now().microsecondsSinceEpoch}';
    await _pendingSyncRepository.enqueue(
      SyncOperation.create(
        entityType: entityType,
        payload: _basePayload(deviceId, 'connect'),
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  @override
  Future<void> disconnect(final String deviceId) async {
    final PersistentIotDemoRepository? local = _getLocalRepository();
    if (local == null) return;
    await local.disconnect(deviceId);
    if (_remoteRepository == null) return;
    final String idempotencyKey =
        '${iotDemoEntity}_disconnect_${deviceId}_${DateTime.now().microsecondsSinceEpoch}';
    await _pendingSyncRepository.enqueue(
      SyncOperation.create(
        entityType: entityType,
        payload: _basePayload(deviceId, 'disconnect'),
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async {
    final PersistentIotDemoRepository? local = _getLocalRepository();
    if (local == null) return;
    final String? userId = _currentSupabaseUserId();
    if (userId == null) return;
    await local.sendCommand(deviceId, command);
    if (_remoteRepository == null) return;
    if (command is IotDeviceCommandSetValue) {
      _scheduleSetValueSync(
        userId: userId,
        deviceId: deviceId,
        value: command.value.toDouble(),
      );
      return;
    }
    await _enqueueCommand(deviceId, iotDemoCommandToPayload(command));
  }

  String? _currentSupabaseUserId() {
    final String? userId = _getCurrentSupabaseUserId();
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  String _pendingSetValueKey({
    required final String userId,
    required final String deviceId,
  }) => '$userId::$deviceId';

  void _scheduleSetValueSync({
    required final String userId,
    required final String deviceId,
    required final double value,
  }) {
    final String pendingKey = _pendingSetValueKey(
      userId: userId,
      deviceId: deviceId,
    );
    final IotDemoPendingSetValue? existing =
        _pendingSetValueByDevice[pendingKey];
    existing?.timer.dispose();
    final TimerDisposable timer = _timerService.runOnce(
      setValueSyncDebounce,
      () {
        _pendingSetValueByDevice.remove(pendingKey);
        unawaited(
          _enqueueSetValueCommand(
            deviceId,
            value,
            supabaseUserId: userId,
          ),
        );
      },
    );
    _pendingSetValueByDevice[pendingKey] = IotDemoPendingSetValue(
      timer: timer,
    );
  }

  Future<void> _enqueueSetValueCommand(
    final String deviceId,
    final double value, {
    required final String supabaseUserId,
  }) {
    return _enqueueCommand(
      deviceId,
      <String, dynamic>{
        'kind': 'setValue',
        'value': value,
      },
      supabaseUserId: supabaseUserId,
    );
  }

  Future<void> _enqueueCommand(
    final String deviceId,
    final Map<String, dynamic> commandPayload, {
    final String? supabaseUserId,
  }) async {
    final String idempotencyKey =
        '${iotDemoEntity}_command_${deviceId}_${DateTime.now().microsecondsSinceEpoch}';
    final String? effectiveUserId = supabaseUserId ?? _currentSupabaseUserId();
    await _pendingSyncRepository.enqueue(
      SyncOperation.create(
        entityType: entityType,
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

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    final Map<String, dynamic> payload = operation.payload;
    final String? opUserId = stringFromDynamicTrimmed(
      payload[iotDemoSyncPayloadKeySupabaseUserId],
    );
    final String? currentUserId = _getCurrentSupabaseUserId();
    if (opUserId == null ||
        currentUserId == null ||
        opUserId != currentUserId) {
      return;
    }
    final SupabaseIotDemoRepository? remote = _remoteRepository;
    if (remote == null) return;
    await applyIotDemoSyncOperation(remote, payload);
  }

  @override
  Future<void> pullRemote() async {
    final SupabaseIotDemoRepository? remote = _remoteRepository;
    final PersistentIotDemoRepository? local = _getLocalRepository();
    final String? userId = _currentSupabaseUserId();
    if (remote == null || local == null || userId == null) return;
    final Future<void>? inFlight = _pullRemoteInFlightByUser[userId];
    if (inFlight != null) {
      return inFlight;
    }
    final Future<void> future = _doPullRemote(
      remote: remote,
      local: local,
      userIdBefore: userId,
    );
    _pullRemoteInFlightByUser[userId] = future;
    unawaited(
      future.whenComplete(() {
        final Future<void>? current = _pullRemoteInFlightByUser[userId];
        if (identical(current, future)) {
          final Future<void>? removed = _pullRemoteInFlightByUser.remove(
            userId,
          );
          if (removed != null) {
            // Removal is the side effect; the removed future is intentionally ignored.
          }
        }
      }),
    );
    return future;
  }

  Future<void> _doPullRemote({
    required final SupabaseIotDemoRepository remote,
    required final PersistentIotDemoRepository local,
    required final String userIdBefore,
  }) async {
    try {
      // Don't overwrite local with remote when there are unsynced IoT ops
      // (same rule as Counter/Todo: stale remote must not overwrite newer local).
      final List<SyncOperation> pending = await _pendingSyncRepository
          .getPendingOperations(
            supabaseUserIdFilter: userIdBefore,
          );
      if (pending.any((final op) => op.entityType == iotDemoEntity)) {
        return;
      }
      final List<IotDevice> remoteDevices = await remote.fetchDevices();
      final String? userIdAfter = _currentSupabaseUserId();
      if (userIdAfter != userIdBefore) return;
      final PersistentIotDemoRepository? localNow = _getLocalRepository();
      if (localNow == null || localNow != local) return;
      await local.replaceDevices(
        List<IotDevice>.unmodifiable(remoteDevices),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstIotDemoRepository.pullRemote failed',
        error,
        stackTrace,
      );
    }
  }
}
