import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

/// Offline-first implementation of [ProfileRepository].
///
/// Serves cached profile data when offline and refreshes in the background
/// when online. Read-only; no pending operations are queued.
class OfflineFirstProfileRepository
    implements ProfileRepository, SyncableRepository {
  OfflineFirstProfileRepository({
    required this._remoteRepository,
    required this._cacheRepository,
    required this._networkStatusService,
    required this._registry,
  }) {
    _registry.register(this);
  }

  static const String profileEntity = 'profile';

  final ProfileRepository _remoteRepository;
  final ProfileCacheRepository _cacheRepository;
  final NetworkStatusService _networkStatusService;
  final SyncableRepositoryRegistry _registry;

  final InFlightCoalescer _refreshCoalescer = InFlightCoalescer();

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
      // Return cached immediately and refresh in the background when online.
      // In-flight coalescing: concurrent callers share one refresh.
      unawaited(
        _refreshAndCache().catchError((
          final Object error,
          final StackTrace st,
        ) {
          AppLogger.error(
            'OfflineFirstProfileRepository background refresh failed',
            error,
            st,
          );
        }),
      );
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

  /// Refreshes profile from remote and saves to cache.
  /// Concurrent callers await the same in-flight future.
  Future<void> _refreshAndCache() =>
      _refreshCoalescer.run(() => _doRefreshAndCache());

  Future<void> _doRefreshAndCache() async {
    final ProfileUser profile = await _remoteRepository.getProfile();
    await _saveProfileToCache(profile);
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
      rethrow;
    }
  }
}
