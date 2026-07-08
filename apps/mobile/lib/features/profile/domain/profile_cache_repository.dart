import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:utilities/utilities.dart';

export 'package:utilities/utilities.dart' show ProfileCacheMetadata;

abstract class ProfileCacheRepository implements ProfileCacheControlsPort {
  Future<ProfileUser?> loadProfile();
  Future<void> saveProfile(final ProfileUser user);
}
