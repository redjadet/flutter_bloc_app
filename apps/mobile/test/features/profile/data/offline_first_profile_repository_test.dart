import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc_app/features/profile/data/offline_first_profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';
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

class _FailingSaveProfileCacheRepository implements ProfileCacheRepository {
  @override
  Future<ProfileUser?> loadProfile() async => null;

  @override
  Future<void> saveProfile(final ProfileUser profile) async {
    throw Exception('cache write failed');
  }

  @override
  Future<void> clearProfile() async {}

  @override
  Future<ProfileCacheMetadata> loadMetadata() async =>
      const ProfileCacheMetadata(
        hasProfile: false,
        lastSyncedAt: null,
        sizeBytes: null,
      );
}

class _CompletingProfileCacheRepository implements ProfileCacheRepository {
  _CompletingProfileCacheRepository({
    required this._delegate,
    required this._saveCompleter,
  });

  final ProfileCacheRepository _delegate;
  final Completer<void> _saveCompleter;

  @override
  Future<ProfileUser?> loadProfile() => _delegate.loadProfile();

  @override
  Future<void> saveProfile(final ProfileUser profile) async {
    await _delegate.saveProfile(profile);
    if (!_saveCompleter.isCompleted) {
      _saveCompleter.complete();
    }
  }

  @override
  Future<void> clearProfile() => _delegate.clearProfile();

  @override
  Future<ProfileCacheMetadata> loadMetadata() => _delegate.loadMetadata();
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
      cacheRepository = HiveProfileCacheRepository(hiveService: hiveService);
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
      final Completer<void> cacheSaved = Completer<void>();
      final _StubProfileRepository remote = _StubProfileRepository(
        onGetProfile: () async {
          fetchStarted.complete();
          return remoteUser;
        },
      );
      final ProfileCacheRepository completingCacheRepository =
          _CompletingProfileCacheRepository(
            delegate: cacheRepository,
            saveCompleter: cacheSaved,
          );

      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: remote,
            cacheRepository: completingCacheRepository,
            networkStatusService: networkStatus,
            registry: registry,
          );

      final ProfileUser result = await repository.getProfile();
      expect(result.name, cachedUser.name);
      await fetchStarted.future;
      await cacheSaved.future;
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

    test(
      'concurrent getProfile with cache run only one background refresh',
      () async {
        await cacheRepository.saveProfile(cachedUser);
        int getProfileCalls = 0;
        final _StubProfileRepository remote = _StubProfileRepository(
          onGetProfile: () async {
            getProfileCalls++;
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

        final List<Future<ProfileUser>> calls = <Future<ProfileUser>>[
          repository.getProfile(),
          repository.getProfile(),
          repository.getProfile(),
        ];
        await Future.wait(calls);

        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(getProfileCalls, 1);
      },
    );

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

    test('pullRemote propagates remote failure and keeps cache', () async {
      await cacheRepository.saveProfile(cachedUser);
      final _StubProfileRepository remote = _StubProfileRepository(
        onGetProfile: () async {
          throw Exception('network');
        },
      );

      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: remote,
            cacheRepository: cacheRepository,
            networkStatusService: networkStatus,
            registry: registry,
          );

      await expectLater(repository.pullRemote(), throwsA(isA<Exception>()));
      final ProfileUser? cached = await cacheRepository.loadProfile();
      expect(cached!.name, cachedUser.name);
    });

    test('pullRemote propagates cache save failure', () async {
      final _StubProfileRepository remote = _StubProfileRepository(
        onGetProfile: () async => remoteUser,
      );
      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: remote,
            cacheRepository: _FailingSaveProfileCacheRepository(),
            networkStatusService: networkStatus,
            registry: registry,
          );

      await expectLater(repository.pullRemote(), throwsA(isA<Exception>()));
    });

    test('cold getProfile propagates cache save failure', () async {
      final _StubProfileRepository remote = _StubProfileRepository(
        onGetProfile: () async => remoteUser,
      );
      final OfflineFirstProfileRepository repository =
          OfflineFirstProfileRepository(
            remoteRepository: remote,
            cacheRepository: _FailingSaveProfileCacheRepository(),
            networkStatusService: networkStatus,
            registry: registry,
          );

      await expectLater(repository.getProfile(), throwsA(isA<Exception>()));
    });
  });
}
