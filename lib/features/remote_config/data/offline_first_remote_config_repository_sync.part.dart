part of 'offline_first_remote_config_repository.dart';

extension _OfflineFirstRemoteConfigRepositorySync
    on OfflineFirstRemoteConfigRepository {
  Future<void> _refreshFromRemote({
    required final String reason,
    final bool skipNetworkCheck = false,
  }) async {
    if (!skipNetworkCheck) {
      final NetworkStatus status = await _networkStatusService
          .getCurrentStatus();
      if (status != NetworkStatus.online) {
        AppLogger.debug(
          'OfflineFirstRemoteConfigRepository.$reason skipped (offline)',
        );
        _telemetry(
          'remote_config_fetch_skipped',
          <String, Object?>{
            'reason': 'offline',
            'hasCache': _snapshot.hasValues,
          },
        );
        return;
      }
    }

    await _fetchCoalescer.run(() => _doRefreshFromRemote(reason));
  }

  Future<void> _doRefreshFromRemote(final String reason) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      await _remoteRepository.forceFetch();
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstRemoteConfigRepository.$reason failed',
        error,
        stackTrace,
      );
      _telemetry(
        'remote_config_fetch_failed',
        <String, Object?>{
          'reason': reason,
          'durationMs': stopwatch.elapsedMilliseconds,
        },
      );
      if (!_snapshot.hasValues) {
        rethrow;
      }
      return;
    }

    final DateTime fetchedAt = DateTime.now().toUtc();
    final Map<String, dynamic> updatedValues = <String, dynamic>{
      ..._snapshot.values,
      ..._readTrackedValues(),
      OfflineFirstRemoteConfigRepository._lastSyncedKey: fetchedAt
          .toIso8601String(),
      OfflineFirstRemoteConfigRepository._lastDataSourceKey: 'remote',
    };
    final RemoteConfigSnapshot nextSnapshot = _snapshot.copyWith(
      values: updatedValues,
      lastFetchedAt: fetchedAt,
      dataSource: 'remote',
      lastSyncedAt: fetchedAt,
    );
    _snapshot = nextSnapshot;
    await _cacheRepository.saveSnapshot(nextSnapshot);
    stopwatch.stop();
    _telemetry(
      'remote_config_fetch_succeeded',
      <String, Object?>{
        'reason': reason,
        'durationMs': stopwatch.elapsedMilliseconds,
        'dataSource': nextSnapshot.dataSource ?? 'unknown',
        'hasValues': nextSnapshot.hasValues,
      },
    );
  }

  Future<void> _hydrateFromCache() async {
    final RemoteConfigSnapshot? cached = await _cacheRepository.loadSnapshot();
    if (cached != null) {
      _snapshot = cached;
    }
  }

  Map<String, dynamic> _readTrackedValues() {
    final Map<String, dynamic> values = <String, dynamic>{};
    for (final String key
        in OfflineFirstRemoteConfigRepository._trackedBoolKeys) {
      values[key] = _remoteRepository.getBool(key);
    }
    for (final String key
        in OfflineFirstRemoteConfigRepository._trackedStringKeys) {
      values[key] = _remoteRepository.getString(key);
    }
    for (final String key
        in OfflineFirstRemoteConfigRepository._trackedIntKeys) {
      values[key] = _remoteRepository.getInt(key);
    }
    return values;
  }
}
