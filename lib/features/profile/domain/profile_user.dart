// coverage:ignore-file
// Simple data class; tested indirectly via ProfileCubit and ProfileRepository tests.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_user.freezed.dart';

@freezed
abstract class ProfileUser with _$ProfileUser {
  const factory ProfileUser({
    required final String name,
    required final String location,
    required final String avatarUrl,
    required final List<ProfileImage> galleryImages,
  }) = _ProfileUser;
}

@freezed
abstract class ProfileImage with _$ProfileImage {
  const factory ProfileImage({
    required final String url,
    required final double aspectRatio,
  }) = _ProfileImage;
}
