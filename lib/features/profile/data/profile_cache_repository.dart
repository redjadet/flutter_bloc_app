import 'dart:convert';

import 'package:flutter_bloc_app/features/profile/domain/profile_cache_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive/hive.dart';

/// Hive-backed cache for profile data so the profile page can hydrate offline.
class HiveProfileCacheRepository extends HiveRepositoryBase
    implements ProfileCacheRepository {
  HiveProfileCacheRepository({required super.hiveService});

  static const String _boxName = 'profile_cache';
  static const String _profileKey = 'profile';
  static const String _lastSyncedKey = 'profile_last_synced_at';

  @override
  String get boxName => _boxName;

  @override
  Future<ProfileUser?> loadProfile() async => StorageGuard.run<ProfileUser?>(
    logContext: 'HiveProfileCacheRepository.loadProfile',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic raw = box.get(_profileKey);
      return _parseProfile(raw);
    },
    fallback: () => null,
  );

  @override
  Future<void> saveProfile(final ProfileUser user) async =>
      StorageGuard.run<void>(
        logContext: 'HiveProfileCacheRepository.saveProfile',
        action: () async {
          final Box<dynamic> box = await getBox();
          final Map<String, dynamic> payload = _profileToJson(user);
          await box.put(_profileKey, payload);
          await box.put(
            _lastSyncedKey,
            DateTime.now().toUtc().toIso8601String(),
          );
        },
      );

  @override
  Future<void> clearProfile() async => StorageGuard.run<void>(
    logContext: 'HiveProfileCacheRepository.clearProfile',
    action: () async {
      final Box<dynamic> box = await getBox();
      await safeDeleteKey(box, _profileKey);
      await safeDeleteKey(box, _lastSyncedKey);
    },
  );

  @override
  Future<ProfileCacheMetadata> loadMetadata() async => StorageGuard.run(
    logContext: 'HiveProfileCacheRepository.loadMetadata',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic rawProfile = box.get(_profileKey);
      final bool hasProfile = rawProfile != null;
      final int? sizeBytes = _estimateSizeBytes(rawProfile);
      final String? rawDate = box.get(_lastSyncedKey) as String?;
      final DateTime? lastSynced = rawDate == null
          ? null
          : DateTime.tryParse(rawDate)?.toUtc();
      return ProfileCacheMetadata(
        hasProfile: hasProfile,
        lastSyncedAt: lastSynced,
        sizeBytes: sizeBytes,
      );
    },
    fallback: () => const ProfileCacheMetadata(
      hasProfile: false,
      lastSyncedAt: null,
      sizeBytes: null,
    ),
  );

  ProfileUser? _parseProfile(final dynamic raw) {
    if (raw is Map<dynamic, dynamic>) {
      final Map<String, dynamic> map = raw.map(
        (final dynamic key, final dynamic value) =>
            MapEntry(key.toString(), value),
      );
      final List<dynamic>? galleryRaw = map['galleryImages'] as List<dynamic>?;
      final List<ProfileImage> gallery = galleryRaw == null
          ? const <ProfileImage>[]
          : galleryRaw
                .whereType<Map<dynamic, dynamic>>()
                .map(_mapToImage)
                .toList(growable: false);
      final String? name = map['name'] as String?;
      final String? location = map['location'] as String?;
      final String? avatarUrl = map['avatarUrl'] as String?;
      if (name == null || location == null || avatarUrl == null) {
        return null;
      }
      return ProfileUser(
        name: name,
        location: location,
        avatarUrl: avatarUrl,
        galleryImages: gallery,
      );
    }
    return null;
  }

  ProfileImage _mapToImage(final Map<dynamic, dynamic> raw) {
    final Map<String, dynamic> normalized = raw.map(
      (final dynamic key, final dynamic value) =>
          MapEntry(key.toString(), value),
    );
    final String url = normalized['url'] as String? ?? '';
    final double aspectRatio =
        (normalized['aspectRatio'] as num?)?.toDouble() ?? 1.0;
    return ProfileImage(url: url, aspectRatio: aspectRatio);
  }

  Map<String, dynamic> _profileToJson(final ProfileUser user) =>
      <String, dynamic>{
        'name': user.name,
        'location': user.location,
        'avatarUrl': user.avatarUrl,
        'galleryImages': user.galleryImages
            .map(
              (final ProfileImage image) => <String, dynamic>{
                'url': image.url,
                'aspectRatio': image.aspectRatio,
              },
            )
            .toList(growable: false),
      };

  int? _estimateSizeBytes(final dynamic raw) {
    if (raw == null) {
      return null;
    }
    try {
      final String encoded = jsonEncode(raw);
      return utf8.encode(encoded).length;
    } on Exception {
      return null;
    }
  }
}
