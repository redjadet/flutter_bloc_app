import 'dart:async';

import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Offline-first implementation of [ProfileRepository].
///
/// Serves cached profile data when offline and refreshes in the background
/// when online. Read-only; no pending operations are queued.
class OfflineFirstProfileRepository
    implements ProfileRepository, SyncableRepository {
  OfflineFirstProfileRepository({
    required ProfileRepository remoteRepository,
    required ProfileCacheRepository cacheRepository,
    required NetworkStatusService networkStatusService,
    required SyncableRepositoryRegistry registry,
  }) : _remoteRepository = remoteRepository,
       _cacheRepository = cacheRepository,
       _networkStatusService = networkStatusService,
       _registry = registry {
    _registry.register(this);
  }

  static const String profileEntity = 'profile';

  final ProfileRepository _remoteRepository;
  final ProfileCacheRepository _cacheRepository;
  final NetworkStatusService _networkStatusService;
  final SyncableRepositoryRegistry _registry;

  @override
  String get entityType => profileEntity;

  @override
  Future<ProfileUser> getProfile() async {
    final ProfileUser? cached = await _cacheRepository.loadProfile();
    final NetworkStatus networkStatus = await _networkStatusService
        .getCurrentStatus();
    final bool isOnline = networkStatus == NetworkStatus.online;

    if (cached != null) {
      if (!isOnline) {
        return cached;
      }
      // Return cached immediately and refresh in the background when online
      unawaited(_refreshAndCache());
      return cached;
    }

    if (isOnline) {
      try {
        final ProfileUser profile = await _remoteRepository.getProfile();
        await _saveProfileToCache(profile);
        return profile;
      } on Exception catch (error, stackTrace) {
        AppLogger.error(
          'OfflineFirstProfileRepository.getProfile failed',
          error,
          stackTrace,
        );
        rethrow;
      }
    }

    throw Exception('Offline and no cached profile available');
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    AppLogger.info(
      'OfflineFirstProfileRepository.processOperation: no-op for profile',
    );
  }

  @override
  Future<void> pullRemote() async {
    final NetworkStatus status = await _networkStatusService.getCurrentStatus();
    if (status != NetworkStatus.online) {
      return;
    }
    await _refreshAndCache();
  }

  Future<void> _refreshAndCache() async {
    try {
      final ProfileUser profile = await _remoteRepository.getProfile();
      await _saveProfileToCache(profile);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstProfileRepository._refreshAndCache failed',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _saveProfileToCache(final ProfileUser profile) async {
    try {
      await _cacheRepository.saveProfile(profile);
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstProfileRepository._saveProfileToCache failed',
        error,
        stackTrace,
      );
    }
  }
}
