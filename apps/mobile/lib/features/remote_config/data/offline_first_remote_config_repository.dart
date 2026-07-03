import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/remote_config/data/remote_config_cache_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_keys.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_snapshot.dart';
import 'package:flutter_bloc_app/shared/diagnostics/integration_log_messages.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/in_flight_coalescer.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'offline_first_remote_config_repository_sync.part.dart';

/// Offline-first adapter that wraps the Firebase Remote Config repository.
///
/// Loads cached values from Hive on startup, serves cached values when offline,
/// and refreshes the cache whenever a remote fetch succeeds. It also registers
/// with the global sync registry so background sync can refresh Remote Config.
class OfflineFirstRemoteConfigRepository
    implements RemoteConfigService, SyncableRepository {
  OfflineFirstRemoteConfigRepository({
    required this._remoteRepository,
    required this._cacheRepository,
    required this._networkStatusService,
    required this._registry,
    final void Function(String event, Map<String, Object?> payload)? telemetry,
  }) : _telemetry = telemetry ?? _defaultTelemetry {
    if (!shouldSkipBackgroundSyncOnMacOsDebug) {
      _registry.register(this);
    }
  }

  static const String remoteConfigEntity = 'remote_config';
  static const List<String> _trackedBoolKeys = <String>[
    RemoteConfigKeys.awesomeFeatureEnabled,
    RemoteConfigKeys.supabaseConfigEnabled,
  ];
  static const List<String> _trackedStringKeys = <String>[
    RemoteConfigKeys.testValue1,
    RemoteConfigKeys.supabaseUrl,
    RemoteConfigKeys.supabaseAnonKey,
    RemoteConfigKeys.renderChatDemoHfReadToken,
  ];
  static const List<String> _trackedIntKeys = <String>[
    RemoteConfigKeys.supabaseConfigVersion,
  ];

  /// Matches background sync interval; avoids redundant network fetches when
  /// sync cycles fire in quick succession at startup.
  static const Duration _pullRemoteMinInterval = Duration(seconds: 60);

  final RemoteConfigRemoteDataSource _remoteRepository;
  final RemoteConfigCacheRepository _cacheRepository;
  final NetworkStatusService _networkStatusService;
  final SyncableRepositoryRegistry _registry;
  final void Function(String event, Map<String, Object?> payload) _telemetry;

  RemoteConfigSnapshot _snapshot = RemoteConfigSnapshot.empty;
  DateTime? _lastSuccessfulRemoteRefreshAt;
  bool _loggedPullRemoteSkipInThrottleWindow = false;
  final InFlightCoalescer _fetchCoalescer = InFlightCoalescer();

  @visibleForTesting
  static bool get shouldSkipBackgroundSyncOnMacOsDebug =>
      !kIsWeb && !kReleaseMode && defaultTargetPlatform == TargetPlatform.macOS;

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
  Future<void> clearCache() async {
    _snapshot = RemoteConfigSnapshot.empty;
    _lastSuccessfulRemoteRefreshAt = null;
    _loggedPullRemoteSkipInThrottleWindow = false;
    await _cacheRepository.clear();
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

  static void _defaultTelemetry(
    final String event,
    final Map<String, Object?> payload,
  ) {
    AppLogger.debug('RemoteConfigTelemetry[$event] $payload');
  }
}
