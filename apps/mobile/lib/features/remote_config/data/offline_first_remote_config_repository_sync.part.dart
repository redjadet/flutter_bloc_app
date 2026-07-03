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

    if (reason == 'pullRemote' && _shouldSkipPullRemoteDueToRecentRefresh()) {
      _maybeLogPullRemoteSkip();
      return;
    }

    await _fetchCoalescer.run(() => _doRefreshFromRemote(reason));
  }

  Future<void> _doRefreshFromRemote(final String reason) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      await _remoteRepository.forceFetch();
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        IntegrationLogMessages.offlineFirstRemoteConfigFetchFailed(reason),
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
      RemoteConfigKeys.lastSyncedAt: fetchedAt.toIso8601String(),
      RemoteConfigKeys.lastDataSource: 'remote',
    };
    final RemoteConfigSnapshot nextSnapshot = _snapshot.copyWith(
      values: updatedValues,
      lastFetchedAt: fetchedAt,
      dataSource: 'remote',
      lastSyncedAt: fetchedAt,
    );
    _snapshot = nextSnapshot;
    _lastSuccessfulRemoteRefreshAt = fetchedAt;
    _loggedPullRemoteSkipInThrottleWindow = true;
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
      _lastSuccessfulRemoteRefreshAt = cached.lastFetchedAt;
    }
  }

  bool _shouldSkipPullRemoteDueToRecentRefresh() {
    final DateTime? lastRefresh = _lastSuccessfulRemoteRefreshAt;
    if (lastRefresh == null || !_snapshot.hasValues) {
      _loggedPullRemoteSkipInThrottleWindow = false;
      return false;
    }
    final Duration elapsed = DateTime.now().toUtc().difference(lastRefresh);
    if (elapsed >= OfflineFirstRemoteConfigRepository._pullRemoteMinInterval) {
      _loggedPullRemoteSkipInThrottleWindow = false;
      return false;
    }
    return true;
  }

  void _maybeLogPullRemoteSkip() {
    if (_loggedPullRemoteSkipInThrottleWindow) {
      return;
    }
    _loggedPullRemoteSkipInThrottleWindow = true;
    AppLogger.debug(
      'OfflineFirstRemoteConfigRepository.pullRemote skipped (recent refresh)',
    );
    _telemetry(
      'remote_config_fetch_skipped',
      <String, Object?>{
        'reason': 'recent_refresh',
        'hasCache': _snapshot.hasValues,
      },
    );
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
