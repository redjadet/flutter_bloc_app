import 'dart:io';

import 'package:flutter_bloc_app/features/remote_config/data/remote_config_cache_repository.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_snapshot.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('RemoteConfigCacheRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late RemoteConfigCacheRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('remote_config_cache_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = RemoteConfigCacheRepository(hiveService: hiveService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('returns null when no snapshot stored', () async {
      final RemoteConfigSnapshot? snapshot = await repository.loadSnapshot();
      expect(snapshot, isNull);
    });

    test('persists and reads snapshot metadata', () async {
      final RemoteConfigSnapshot snapshot = RemoteConfigSnapshot(
        values: <String, dynamic>{
          'awesome_feature_enabled': true,
          'test_value_1': 'cached',
        },
        lastFetchedAt: DateTime.utc(2025, 01, 01),
        templateVersion: 'v1',
        dataSource: 'remote',
        lastSyncedAt: DateTime.utc(2025, 01, 02, 12, 30),
      );

      await repository.saveSnapshot(snapshot);

      final RemoteConfigSnapshot? loaded = await repository.loadSnapshot();
      expect(loaded, isNotNull);
      expect(loaded!.values, containsPair('awesome_feature_enabled', true));
      expect(loaded.values, containsPair('test_value_1', 'cached'));
      expect(loaded.lastFetchedAt, snapshot.lastFetchedAt);
      expect(loaded.templateVersion, 'v1');
      expect(loaded.dataSource, 'remote');
      expect(loaded.lastSyncedAt, snapshot.lastSyncedAt);
    });

    test('clear removes stored snapshot', () async {
      final RemoteConfigSnapshot snapshot = RemoteConfigSnapshot(
        values: <String, dynamic>{'foo': 'bar'},
      );
      await repository.saveSnapshot(snapshot);

      await repository.clear();

      final RemoteConfigSnapshot? loaded = await repository.loadSnapshot();
      expect(loaded, isNull);
    });
  });
}
