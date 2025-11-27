import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/features/profile/data/offline_first_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeNetworkStatusService implements NetworkStatusService {
  _FakeNetworkStatusService(this._status);

  NetworkStatus _status;
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => _status;

  void setStatus(final NetworkStatus status) {
    _status = status;
  }

  @override
  Future<void> dispose() async {}
}

class _StubProfileRepository implements ProfileRepository {
  _StubProfileRepository({required this.onGetProfile});

  final Future<ProfileUser> Function() onGetProfile;
  int callCount = 0;

  @override
  Future<ProfileUser> getProfile() async {
    callCount++;
    return onGetProfile();
  }
}

void main() {
  const ProfileUser cachedUser = ProfileUser(
    name: 'Cached',
    location: 'Offline',
    avatarUrl: 'https://example.com/cached.png',
    galleryImages: <ProfileImage>[
      ProfileImage(url: 'https://example.com/1.png', aspectRatio: 1.0),
    ],
  );
  const ProfileUser remoteUser = ProfileUser(
    name: 'Remote',
    location: 'Online',
    avatarUrl: 'https://example.com/remote.png',
    galleryImages: <ProfileImage>[
      ProfileImage(url: 'https://example.com/2.png', aspectRatio: 1.0),
    ],
  );

  group('OfflineFirstProfileRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late ProfileCacheRepository cacheRepository;
    late SyncableRepositoryRegistry registry;
    late _FakeNetworkStatusService networkStatus;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('profile_offline_first_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      cacheRepository = ProfileCacheRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
      networkStatus = _FakeNetworkStatusService(NetworkStatus.online);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('returns cached profile when offline', () async {
      await cacheRepository.saveProfile(cachedUser);
      networkStatus.setStatus(NetworkStatus.offline);
      final _StubProfileRepository remote = _StubProfileRepository(
        onGetProfile: () async => remoteUser,
      );

      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: remote,
            cacheRepository: cacheRepository,
            networkStatusService: networkStatus,
            registry: registry,
          );

      final ProfileUser result = await repository.getProfile();
      expect(result.name, cachedUser.name);
      expect(remote.callCount, 0);
      expect(
        registry.resolve(OfflineFirstProfileRepository.profileEntity),
        isNotNull,
      );
    });

    test('returns cached immediately and refreshes when online', () async {
      await cacheRepository.saveProfile(cachedUser);
      final Completer<void> fetchStarted = Completer<void>();
      final _StubProfileRepository remote = _StubProfileRepository(
        onGetProfile: () async {
          fetchStarted.complete();
          return remoteUser;
        },
      );

      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: remote,
            cacheRepository: cacheRepository,
            networkStatusService: networkStatus,
            registry: registry,
          );

      final ProfileUser result = await repository.getProfile();
      expect(result.name, cachedUser.name);
      await fetchStarted.future;
      // Allow background refresh to write cache
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final ProfileUser? refreshed = await cacheRepository.loadProfile();
      expect(refreshed!.name, remoteUser.name);
    });

    test('fetches remote when no cache and online', () async {
      final _StubProfileRepository remote = _StubProfileRepository(
        onGetProfile: () async => remoteUser,
      );

      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: remote,
            cacheRepository: cacheRepository,
            networkStatusService: networkStatus,
            registry: registry,
          );

      final ProfileUser result = await repository.getProfile();
      expect(result.name, remoteUser.name);
      final ProfileUser? cached = await cacheRepository.loadProfile();
      expect(cached, isNotNull);
      expect(cached!.name, remoteUser.name);
    });

    test('throws when offline with no cache', () async {
      networkStatus.setStatus(NetworkStatus.offline);
      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: _StubProfileRepository(
              onGetProfile: () async => remoteUser,
            ),
            cacheRepository: cacheRepository,
            networkStatusService: networkStatus,
            registry: registry,
          );

      expect(repository.getProfile, throwsA(isA<Exception>()));
    });
  });
}
