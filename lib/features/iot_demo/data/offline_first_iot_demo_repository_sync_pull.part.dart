part of 'offline_first_iot_demo_repository.dart';

Future<void> processOperationImpl(
  final OfflineFirstIotDemoRepository r,
  final SyncOperation operation,
) async {
  final Map<String, dynamic> payload = operation.payload;
  final String? opUserId = stringFromDynamicTrimmed(
    payload[iotDemoSyncPayloadKeySupabaseUserId],
  );
  if (opUserId == null) {
    return;
  }
  final String? currentUserId = r._currentSupabaseUserId();
  if (currentUserId == null || opUserId != currentUserId) {
    throw const SyncOperationDeferredException('iot_demo user scope mismatch');
  }
  final SupabaseIotDemoRepository? remote = r._remoteRepository;
  if (remote == null) return;
  await applyIotDemoSyncOperation(remote, payload);
}

Future<void> pullRemoteImpl(final OfflineFirstIotDemoRepository r) async {
  final SupabaseIotDemoRepository? remote = r._remoteRepository;
  final PersistentIotDemoRepository? local = r._getLocalRepository();
  final String? userId = r._currentSupabaseUserId();
  if (remote == null || local == null || userId == null) return;
  final Future<void>? inFlight = r._pullRemoteInFlightByUser[userId];
  if (inFlight != null) {
    return inFlight;
  }
  final Future<void> future = _doPullRemoteImpl(
    r: r,
    remote: remote,
    local: local,
    userIdBefore: userId,
  );
  r._pullRemoteInFlightByUser[userId] = future;
  unawaited(
    future.whenComplete(() {
      final Future<void>? current = r._pullRemoteInFlightByUser[userId];
      if (identical(current, future)) {
        final Future<void>? removed = r._pullRemoteInFlightByUser.remove(
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

Future<void> _doPullRemoteImpl({
  required final OfflineFirstIotDemoRepository r,
  required final SupabaseIotDemoRepository remote,
  required final PersistentIotDemoRepository local,
  required final String userIdBefore,
}) async {
  try {
    final List<SyncOperation> pending = await r._pendingSyncRepository
        .getPendingOperations(
          supabaseUserIdFilter: userIdBefore,
        );
    final bool hasPendingIotOps = pending.any(
      (final op) =>
          op.entityType == OfflineFirstIotDemoRepository.iotDemoEntity,
    );
    final bool hasDebouncedSetValue = r._pendingSetValueByDevice.keys.any(
      (final key) => key.startsWith('$userIdBefore::'),
    );
    if (hasPendingIotOps || hasDebouncedSetValue) {
      final List<IotDevice> localDevices = await local.watchDevices().first;
      if (localDevices.isNotEmpty) {
        return;
      }
    }
    final List<IotDevice> remoteDevices = await remote.fetchDevices();
    final String? userIdAfter = r._currentSupabaseUserId();
    if (userIdAfter != userIdBefore) return;
    final PersistentIotDemoRepository? localNow = r._getLocalRepository();
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
