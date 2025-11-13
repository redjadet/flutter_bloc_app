// coverage:ignore-file
// Simple data class with only properties and Equatable props getter.
// Tested indirectly via ProfileCubit and ProfileRepository tests.

import 'package:equatable/equatable.dart';

class ProfileUser extends Equatable {
  const ProfileUser({
    required this.name,
    required this.location,
    required this.avatarUrl,
    required this.galleryImages,
  });

  final String name;
  final String location;
  final String avatarUrl;
  final List<ProfileImage> galleryImages;

  @override
  List<Object?> get props => [name, location, avatarUrl, galleryImages];
}

class ProfileImage extends Equatable {
  const ProfileImage({
    required this.url,
    required this.aspectRatio,
  });

  final String url;
  final double aspectRatio;

  @override
  List<Object?> get props => [url, aspectRatio];
}
