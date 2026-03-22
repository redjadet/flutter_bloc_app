/// Metadata shown on the profile cache diagnostics card in settings.
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

/// Narrow port for profile cache diagnostics actions in settings.
abstract class ProfileCacheControlsPort {
  Future<void> clearProfile();
  Future<ProfileCacheMetadata> loadMetadata();
}
