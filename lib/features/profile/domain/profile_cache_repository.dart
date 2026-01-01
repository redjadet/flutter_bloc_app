import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';

class ProfileCacheMetadata {
  const ProfileCacheMetadata({
    required this.hasProfile,
    required this.lastSyncedAt,
    required this.sizeBytes,
  });

  final bool hasProfile;
  final DateTime? lastSyncedAt;
  final int? sizeBytes;
}

abstract class ProfileCacheRepository {
  Future<ProfileUser?> loadProfile();
  Future<void> saveProfile(final ProfileUser user);
  Future<void> clearProfile();
  Future<ProfileCacheMetadata> loadMetadata();
}
