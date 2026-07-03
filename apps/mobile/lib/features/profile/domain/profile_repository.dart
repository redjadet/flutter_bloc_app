import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';

/// Contract for retrieving profile data for the demo page.
abstract interface class ProfileRepository {
  /// Loads the current user's profile (e.g. display name, avatar URL).
  Future<ProfileUser> getProfile();
}
