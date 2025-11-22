import 'dart:io';

import 'package:flutter_bloc_app/features/profile/data/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('ProfileCacheRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late ProfileCacheRepository repository;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('profile_cache_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      repository = ProfileCacheRepository(hiveService: hiveService);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test('returns null when no profile cached', () async {
      final ProfileUser? result = await repository.loadProfile();
      expect(result, isNull);
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
    });
  });
}
