import 'dart:io';

import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('HiveProfileCacheRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late HiveProfileCacheRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('profile_cache_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = HiveProfileCacheRepository(hiveService: hiveService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('returns null when no profile cached', () async {
      final ProfileUser? result = await repository.loadProfile();
      expect(result, isNull);
    });

    test('loadMetadata returns defaults when empty', () async {
      final ProfileCacheMetadata metadata = await repository.loadMetadata();
      expect(metadata.hasProfile, isFalse);
      expect(metadata.lastSyncedAt, isNull);
      expect(metadata.sizeBytes, isNull);
    });

    test('saveProfile and loadProfile round-trip', () async {
      const ProfileUser user = ProfileUser(
        name: 'Jane',
        location: 'SF',
        avatarUrl: 'https://example.com/avatar.png',
        galleryImages: <ProfileImage>[
          ProfileImage(url: 'https://example.com/1.png', aspectRatio: 1.5),
        ],
      );

      await repository.saveProfile(user);
      final ProfileUser? loaded = await repository.loadProfile();

      expect(loaded, isNotNull);
      expect(loaded!.name, user.name);
      expect(loaded.location, user.location);
      expect(loaded.avatarUrl, user.avatarUrl);
      expect(loaded.galleryImages.length, 1);
      expect(loaded.galleryImages.first.aspectRatio, 1.5);
    });

    test('metadata captures lastSyncedAt and sizeBytes', () async {
      const ProfileUser user = ProfileUser(
        name: 'Jane',
        location: 'SF',
        avatarUrl: 'https://example.com/avatar.png',
        galleryImages: <ProfileImage>[
          ProfileImage(url: 'https://example.com/1.png', aspectRatio: 1.5),
        ],
      );

      await repository.saveProfile(user);
      final ProfileCacheMetadata metadata = await repository.loadMetadata();

      expect(metadata.hasProfile, isTrue);
      expect(metadata.lastSyncedAt, isNotNull);
      expect(metadata.sizeBytes, isNotNull);
      expect(metadata.sizeBytes! > 0, isTrue);
    });

    test(
      'saveProfile stores lastSyncedAt with explicit UTC timezone',
      () async {
        const ProfileUser user = ProfileUser(
          name: 'Jane',
          location: 'SF',
          avatarUrl: 'https://example.com/avatar.png',
          galleryImages: <ProfileImage>[
            ProfileImage(url: 'https://example.com/1.png', aspectRatio: 1.5),
          ],
        );

        await repository.saveProfile(user);

        final Box<dynamic> box = await hiveService.openBox('profile_cache');
        final dynamic raw = box.get('profile_last_synced_at');
        expect(raw, isA<String>());
        final String stored = raw as String;
        final DateTime parsed = DateTime.parse(stored);

        expect(stored.endsWith('Z'), isTrue);
        expect(parsed.isUtc, isTrue);
      },
    );

    test('clearProfile removes cached profile', () async {
      const ProfileUser user = ProfileUser(
        name: 'Jane',
        location: 'SF',
        avatarUrl: 'https://example.com/avatar.png',
        galleryImages: <ProfileImage>[
          ProfileImage(url: 'https://example.com/1.png', aspectRatio: 1.5),
        ],
      );

      await repository.saveProfile(user);
      expect(await repository.loadProfile(), isNotNull);

      await repository.clearProfile();
      expect(await repository.loadProfile(), isNull);
      final ProfileCacheMetadata metadata = await repository.loadMetadata();
      expect(metadata.hasProfile, isFalse);
      expect(metadata.lastSyncedAt, isNull);
    });

    test(
      'loadMetadata treats lastSyncedAt without timezone as UTC instant',
      () async {
        final Box<dynamic> box = await hiveService.openBox('profile_cache');
        await box.put('profile_last_synced_at', '2020-06-15T14:30:00.000');
        await box.put('profile', <String, dynamic>{
          'name': 'Jane',
          'location': 'SF',
          'avatarUrl': 'https://example.com/a.png',
          'galleryImages': <dynamic>[],
        });

        final ProfileCacheMetadata metadata = await repository.loadMetadata();

        expect(metadata.hasProfile, isTrue);
        expect(metadata.lastSyncedAt, DateTime.utc(2020, 6, 15, 14, 30));
      },
    );

    test(
      'loadMetadata drops implausible lastSyncedAt from raw storage',
      () async {
        final Box<dynamic> box = await hiveService.openBox('profile_cache');
        await box.put(
          'profile_last_synced_at',
          DateTime.utc(3000, 1, 1).toUtc().toIso8601String(),
        );
        await box.put('profile', <String, dynamic>{
          'name': 'Jane',
          'location': 'SF',
          'avatarUrl': 'https://example.com/a.png',
          'galleryImages': <dynamic>[],
        });

        final ProfileCacheMetadata metadata = await repository.loadMetadata();

        expect(metadata.hasProfile, isTrue);
        expect(metadata.lastSyncedAt, isNull);
      },
    );

    test('loadProfile returns null for malformed cached field types', () async {
      final Box<dynamic> box = await hiveService.openBox('profile_cache');
      await box.put('profile', <String, dynamic>{
        'name': 42,
        'location': true,
        'avatarUrl': <String>['bad'],
        'galleryImages': <dynamic>[
          <String, dynamic>{'url': 99, 'aspectRatio': 'bad'},
        ],
      });

      final ProfileUser? loaded = await repository.loadProfile();

      expect(loaded, isNull);
    });
  });
}
