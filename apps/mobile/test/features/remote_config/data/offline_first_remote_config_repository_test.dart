import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/remote_config/data/offline_first_remote_config_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/data/remote_config_cache_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_keys.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_snapshot.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigRemoteDataSource extends Mock
    implements RemoteConfigRemoteDataSource {}

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
    late _MockRemoteConfigRemoteDataSource remoteRepository;
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
      remoteRepository = _MockRemoteConfigRemoteDataSource();
      networkStatusService = _FakeNetworkStatusService(NetworkStatus.online);
      registry = SyncableRepositoryRegistry();

      when(() => remoteRepository.initialize()).thenAnswer((_) async {});
      when(() => remoteRepository.forceFetch()).thenAnswer((_) async {});
      when(
        () => remoteRepository.getString(RemoteConfigKeys.testValue1),
      ).thenReturn('remote');
      when(
        () => remoteRepository.getBool(RemoteConfigKeys.awesomeFeatureEnabled),
      ).thenReturn(true);
      when(
        () => remoteRepository.getBool(RemoteConfigKeys.supabaseConfigEnabled),
      ).thenReturn(true);
      when(
        () => remoteRepository.getString(RemoteConfigKeys.supabaseUrl),
      ).thenReturn('');
      when(
        () => remoteRepository.getString(RemoteConfigKeys.supabaseAnonKey),
      ).thenReturn('');
      when(
        () => remoteRepository.getString(
          RemoteConfigKeys.renderChatDemoHfReadToken,
        ),
      ).thenReturn('');
      when(
        () => remoteRepository.getInt(RemoteConfigKeys.supabaseConfigVersion),
      ).thenReturn(1);

      repository = OfflineFirstRemoteConfigRepository(
        remoteRepository: remoteRepository,
        cacheRepository: cacheRepository,
        networkStatusService: networkStatusService,
        registry: registry,
      );
    });

    tearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('registers with sync registry', () {
      expect(
        registry.resolve(OfflineFirstRemoteConfigRepository.remoteConfigEntity),
        isNotNull,
      );
    });

    test('does not register for background sync on macOS debug', () {
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final debugRegistry = SyncableRepositoryRegistry();

      OfflineFirstRemoteConfigRepository(
        remoteRepository: remoteRepository,
        cacheRepository: cacheRepository,
        networkStatusService: networkStatusService,
        registry: debugRegistry,
      );

      expect(
        OfflineFirstRemoteConfigRepository.shouldSkipBackgroundSyncOnMacOsDebug,
        isTrue,
      );
      expect(
        debugRegistry.resolve(
          OfflineFirstRemoteConfigRepository.remoteConfigEntity,
        ),
        isNull,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    test('loads cached values when offline and skips remote fetch', () async {
      final RemoteConfigSnapshot snapshot = RemoteConfigSnapshot(
        values: <String, dynamic>{RemoteConfigKeys.testValue1: 'cached'},
      );
      await cacheRepository.saveSnapshot(snapshot);
      networkStatusService.setStatus(NetworkStatus.offline);

      await repository.initialize();
      await repository.forceFetch();

      expect(repository.getString(RemoteConfigKeys.testValue1), 'cached');
      verifyNever(() => remoteRepository.forceFetch());
    });

    test('refreshes cache when online', () async {
      await repository.initialize();

      await repository.forceFetch();

      final RemoteConfigSnapshot? cached = await cacheRepository.loadSnapshot();
      expect(cached, isNotNull);
      expect(cached!.values[RemoteConfigKeys.testValue1], 'remote');
      expect(cached.values[RemoteConfigKeys.awesomeFeatureEnabled], isTrue);
    });

    test('pullRemote skips fetch when offline', () async {
      networkStatusService.setStatus(NetworkStatus.offline);

      await repository.pullRemote();

      verifyNever(() => remoteRepository.forceFetch());
    });

    test('pullRemote skips fetch when refreshed recently', () async {
      await repository.initialize();
      await repository.forceFetch();
      clearInteractions(remoteRepository);

      await repository.pullRemote();

      verifyNever(() => remoteRepository.forceFetch());
    });

    test('pullRemote skip telemetry logs once per throttle window', () async {
      final List<Map<String, Object?>> telemetryEvents =
          <Map<String, Object?>>[];
      final OfflineFirstRemoteConfigRepository throttledRepository =
          OfflineFirstRemoteConfigRepository(
            remoteRepository: remoteRepository,
            cacheRepository: cacheRepository,
            networkStatusService: networkStatusService,
            registry: registry,
            telemetry:
                (final String event, final Map<String, Object?> payload) {
                  telemetryEvents.add(payload);
                },
          );

      final DateTime fetchedAt = DateTime.now().toUtc();
      await cacheRepository.saveSnapshot(
        RemoteConfigSnapshot(
          values: <String, dynamic>{RemoteConfigKeys.testValue1: 'cached'},
          lastFetchedAt: fetchedAt,
          dataSource: 'remote',
          lastSyncedAt: fetchedAt,
        ),
      );
      await throttledRepository.initialize();
      clearInteractions(remoteRepository);

      await throttledRepository.pullRemote();
      await throttledRepository.pullRemote();
      await throttledRepository.pullRemote();

      expect(
        telemetryEvents.where(
          (final Map<String, Object?> event) =>
              event['reason'] == 'recent_refresh',
        ),
        hasLength(1),
      );
      verifyNever(() => remoteRepository.forceFetch());

      telemetryEvents.clear();
      await throttledRepository.forceFetch();
      clearInteractions(remoteRepository);
      await throttledRepository.pullRemote();
      await throttledRepository.pullRemote();

      expect(
        telemetryEvents.where(
          (final Map<String, Object?> event) =>
              event['reason'] == 'recent_refresh',
        ),
        isEmpty,
      );
      verifyNever(() => remoteRepository.forceFetch());
    });

    test('concurrent forceFetch calls run only one remote fetch', () async {
      await repository.initialize();
      int forceFetchCalls = 0;
      when(() => remoteRepository.forceFetch()).thenAnswer((_) async {
        forceFetchCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });

      final List<Future<void>> calls = <Future<void>>[
        repository.forceFetch(),
        repository.forceFetch(),
        repository.forceFetch(),
      ];
      await Future.wait(calls);

      expect(forceFetchCalls, 1);
    });

    test('uses cache when remote fetch fails but cache exists', () async {
      final RemoteConfigSnapshot snapshot = RemoteConfigSnapshot(
        values: <String, dynamic>{RemoteConfigKeys.testValue1: 'cached'},
      );
      await cacheRepository.saveSnapshot(snapshot);
      await repository.initialize();
      when(() => remoteRepository.forceFetch()).thenThrow(Exception('fail'));

      await repository.forceFetch();

      expect(repository.getString(RemoteConfigKeys.testValue1), 'cached');
    });
  });
}
