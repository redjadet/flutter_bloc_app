import 'package:flutter_bloc_app/features/remote_config/data/remote_config_cache_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_snapshot.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Offline-first adapter that wraps the Firebase Remote Config repository.
///
/// Loads cached values from Hive on startup, serves cached values when offline,
/// and refreshes the cache whenever a remote fetch succeeds. It also registers
/// with the global sync registry so background sync can refresh Remote Config.
class OfflineFirstRemoteConfigRepository
    implements RemoteConfigService, SyncableRepository {
  OfflineFirstRemoteConfigRepository({
    required RemoteConfigRepository remoteRepository,
    required RemoteConfigCacheRepository cacheRepository,
    required NetworkStatusService networkStatusService,
    required SyncableRepositoryRegistry registry,
  }) : _remoteRepository = remoteRepository,
       _cacheRepository = cacheRepository,
       _networkStatusService = networkStatusService,
       _registry = registry {
    _registry.register(this);
  }

  static const String remoteConfigEntity = 'remote_config';
  static const List<String> _trackedBoolKeys = <String>[
    RemoteConfigRepository.awesomeFeatureKey,
  ];
  static const List<String> _trackedStringKeys = <String>[
    RemoteConfigRepository.testValueKey,
  ];
  static const String _lastSyncedKey = 'last_synced_at';
  static const String _lastDataSourceKey = 'last_data_source';

  final RemoteConfigRepository _remoteRepository;
  final RemoteConfigCacheRepository _cacheRepository;
  final NetworkStatusService _networkStatusService;
  final SyncableRepositoryRegistry _registry;

  RemoteConfigSnapshot _snapshot = RemoteConfigSnapshot.empty;

  @override
  String get entityType => remoteConfigEntity;

  @override
  Future<void> initialize() async {
    await _hydrateFromCache();
    await _remoteRepository.initialize();
  }

  @override
  Future<void> forceFetch() async {
    final NetworkStatus status = await _networkStatusService.getCurrentStatus();
    if (status != NetworkStatus.online) {
      AppLogger.info(
        'OfflineFirstRemoteConfigRepository.forceFetch: offline, serving cache',
      );
      await _hydrateFromCache();
      return;
    }
    await _refreshFromRemote(
      reason: 'forceFetch',
      skipNetworkCheck: true,
    );
  }

  @override
  bool getBool(final String key) {
    final bool? cached = _snapshot.getValue<bool>(key);
    return cached ?? _remoteRepository.getBool(key);
  }

  @override
  double getDouble(final String key) {
    final double? cached = _snapshot.getValue<double>(key);
    return cached ?? _remoteRepository.getDouble(key);
  }

  @override
  int getInt(final String key) {
    final int? cached = _snapshot.getValue<int>(key);
    return cached ?? _remoteRepository.getInt(key);
  }

  @override
  String getString(final String key) {
    final String? cached = _snapshot.getValue<String>(key);
    return cached ?? _remoteRepository.getString(key);
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    // Remote Config is read-only today, but this method is required so the
    // repository participates in the sync registry. Reserved for future ops.
    AppLogger.debug(
      'OfflineFirstRemoteConfigRepository.processOperation noop for entity=${operation.entityType}',
    );
  }

  @override
  Future<void> pullRemote() => _refreshFromRemote(reason: 'pullRemote');

  Future<void> _hydrateFromCache() async {
    final RemoteConfigSnapshot? cached = await _cacheRepository.loadSnapshot();
    if (cached != null) {
      _snapshot = cached;
    }
  }

  Future<void> _refreshFromRemote({
    required final String reason,
    bool skipNetworkCheck = false,
  }) async {
    if (!skipNetworkCheck) {
      final NetworkStatus status = await _networkStatusService
          .getCurrentStatus();
      if (status != NetworkStatus.online) {
        AppLogger.debug(
          'OfflineFirstRemoteConfigRepository.$reason skipped (offline)',
        );
        return;
      }
    }
    try {
      await _remoteRepository.forceFetch();
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstRemoteConfigRepository.$reason failed',
        error,
        stackTrace,
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
      _lastSyncedKey: fetchedAt.toIso8601String(),
      _lastDataSourceKey: 'remote',
    };
    final RemoteConfigSnapshot nextSnapshot = _snapshot.copyWith(
      values: updatedValues,
      lastFetchedAt: fetchedAt,
      dataSource: 'remote',
      lastSyncedAt: fetchedAt,
    );
    _snapshot = nextSnapshot;
    await _cacheRepository.saveSnapshot(nextSnapshot);
  }

  Map<String, dynamic> _readTrackedValues() {
    final Map<String, dynamic> values = <String, dynamic>{};
    for (final String key in _trackedBoolKeys) {
      values[key] = _remoteRepository.getBool(key);
    }
    for (final String key in _trackedStringKeys) {
      values[key] = _remoteRepository.getString(key);
    }
    return values;
  }
}
