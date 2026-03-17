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

part 'offline_first_iot_demo_repository_sync.dart';

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
  Future<void> addDevice(final IotDevice device) async =>
      addDeviceImpl(this, device);

  @override
  Future<void> connect(final String deviceId) async =>
      connectImpl(this, deviceId);

  @override
  Future<void> disconnect(final String deviceId) async =>
      disconnectImpl(this, deviceId);

  @override
  Future<void> sendCommand(
    final String deviceId,
    final IotDeviceCommand command,
  ) async => sendCommandImpl(this, deviceId, command);

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

  @override
  Future<void> processOperation(final SyncOperation operation) async =>
      processOperationImpl(this, operation);

  @override
  Future<void> pullRemote() async => pullRemoteImpl(this);
}
