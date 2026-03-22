import 'package:flutter_bloc_app/core/diagnostics/profile_cache_controls_port.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';

export 'package:flutter_bloc_app/core/diagnostics/profile_cache_controls_port.dart'
    show ProfileCacheMetadata;

abstract class ProfileCacheRepository implements ProfileCacheControlsPort {
  Future<ProfileUser?> loadProfile();
  Future<void> saveProfile(final ProfileUser user);
}
