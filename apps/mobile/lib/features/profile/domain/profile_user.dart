// coverage:ignore-file
// Simple data class; tested indirectly via ProfileCubit and ProfileRepository tests.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_user.freezed.dart';

@freezed
abstract class ProfileUser with _$ProfileUser {
  const factory ProfileUser({
    required String name,
    required String location,
    required String avatarUrl,
    required List<ProfileImage> galleryImages,
  }) = _ProfileUser;
}

@freezed
abstract class ProfileImage with _$ProfileImage {
  const factory ProfileImage({
    required String url,
    required double aspectRatio,
  }) = _ProfileImage;
}
