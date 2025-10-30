import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';

/// Contract for retrieving profile data for the demo page.
abstract interface class ProfileRepository {
  Future<ProfileUser> getProfile();
}
