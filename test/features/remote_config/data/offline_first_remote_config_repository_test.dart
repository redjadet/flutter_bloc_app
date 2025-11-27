import 'dart:io';

import 'package:flutter_bloc_app/features/remote_config/data/offline_first_remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/remote_config_cache_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_snapshot.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigRepository extends Mock
    implements RemoteConfigRepository {}

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

void main() {
  group('OfflineFirstRemoteConfigRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late RemoteConfigCacheRepository cacheRepository;
    late _MockRemoteConfigRepository remoteRepository;
    late _FakeNetworkStatusService networkStatusService;
    late SyncableRepositoryRegistry registry;
    late OfflineFirstRemoteConfigRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('remote_config_offline_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      cacheRepository = RemoteConfigCacheRepository(hiveService: hiveService);
      remoteRepository = _MockRemoteConfigRepository();
      networkStatusService = _FakeNetworkStatusService(NetworkStatus.online);
      registry = SyncableRepositoryRegistry();

      when(() => remoteRepository.initialize()).thenAnswer((_) async {});
      when(() => remoteRepository.forceFetch()).thenAnswer((_) async {});
      when(
        () => remoteRepository.getString(RemoteConfigRepository.testValueKey),
      ).thenReturn('remote');
      when(
        () =>
            remoteRepository.getBool(RemoteConfigRepository.awesomeFeatureKey),
      ).thenReturn(true);

      repository = OfflineFirstRemoteConfigRepository(
        remoteRepository: remoteRepository,
        cacheRepository: cacheRepository,
        networkStatusService: networkStatusService,
        registry: registry,
      );
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('registers with sync registry', () {
      expect(
        registry.resolve(OfflineFirstRemoteConfigRepository.remoteConfigEntity),
        isNotNull,
      );
    });

    test('loads cached values when offline and skips remote fetch', () async {
      final RemoteConfigSnapshot snapshot = RemoteConfigSnapshot(
        values: <String, dynamic>{
          RemoteConfigRepository.testValueKey: 'cached',
        },
      );
      await cacheRepository.saveSnapshot(snapshot);
      networkStatusService.setStatus(NetworkStatus.offline);

      await repository.initialize();
      await repository.forceFetch();

      expect(
        repository.getString(RemoteConfigRepository.testValueKey),
        'cached',
      );
      verifyNever(() => remoteRepository.forceFetch());
    });

    test('refreshes cache when online', () async {
      await repository.initialize();

      await repository.forceFetch();

      final RemoteConfigSnapshot? cached = await cacheRepository.loadSnapshot();
      expect(cached, isNotNull);
      expect(cached!.values[RemoteConfigRepository.testValueKey], 'remote');
      expect(cached.values[RemoteConfigRepository.awesomeFeatureKey], isTrue);
    });

    test('pullRemote skips fetch when offline', () async {
      networkStatusService.setStatus(NetworkStatus.offline);

      await repository.pullRemote();

      verifyNever(() => remoteRepository.forceFetch());
    });

    test('uses cache when remote fetch fails but cache exists', () async {
      final RemoteConfigSnapshot snapshot = RemoteConfigSnapshot(
        values: <String, dynamic>{
          RemoteConfigRepository.testValueKey: 'cached',
        },
      );
      await cacheRepository.saveSnapshot(snapshot);
      await repository.initialize();
      when(() => remoteRepository.forceFetch()).thenThrow(Exception('fail'));

      await repository.forceFetch();

      expect(
        repository.getString(RemoteConfigRepository.testValueKey),
        'cached',
      );
    });
  });
}
