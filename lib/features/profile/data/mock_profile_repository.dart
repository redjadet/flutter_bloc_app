import 'dart:convert';

import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository();

  static String _decodeUrl(final String encoded) =>
      utf8.decode(base64Decode(encoded));

  static final String _avatarUrl = _decodeUrl(
    'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAvOTRjOTE5ZjIzNDJhYjA0ZTIxYWFhNjRjNWVkMjk0NjI0NWE0ODA0Mw==',
  );

  static final List<ProfileImage> _galleryImages = List.unmodifiable(
    <ProfileImage>[
      ProfileImage(
        url: _decodeUrl(
          'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAvOTRjOTE5ZjIzNDJhYjA0ZTIxYWFhNjRjNWVkMjk0NjI0NWE0ODA0Mw==',
        ),
        aspectRatio: 0.71,
      ),
      ProfileImage(
        url: _decodeUrl(
          'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAvODFiMzQzMzkwOTFiZDExMmRlZjc4ZWJiZWEwMzRjZmQ5ZDgyZTY1Nw==',
        ),
        aspectRatio: 1.41,
      ),
      ProfileImage(
        url: _decodeUrl(
          'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAvMDNlMTczNmYwMTNjODZkM2I1OTIzNzA5YTgwNDcxODBkZmNkYmJiZA==',
        ),
        aspectRatio: 1.41,
      ),
      ProfileImage(
        url: _decodeUrl(
          'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAvMDBhNmVkN2E2Y2VhMWFjMDI1MjUzNGVmNWEwY2IwMDhhZDI0NTQyMg==',
        ),
        aspectRatio: 1.41,
      ),
      ProfileImage(
        url: _decodeUrl(
          'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAvZTlkOWIwMWJlMmY5M2U3OGIwYzhhNzM3OGM5OWMyY2ZkYjJlMWFhYg==',
        ),
        aspectRatio: 1.41,
      ),
      ProfileImage(
        url: _decodeUrl(
          'aHR0cHM6Ly9hcGkuYnVpbGRlci5pby9hcGkvdjEvaW1hZ2UvYXNzZXRzL1RFTVAvOGUyYzFlZjIyYmIzN2IwZWE4NDI0MGI4ZDkxMTNkODY4YjhkNjU4NQ==',
        ),
        aspectRatio: 0.71,
      ),
    ],
  );

  @override
  Future<ProfileUser> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return ProfileUser(
      name: 'Jane',
      location: 'San Francisco, CA',
      avatarUrl: _avatarUrl,
      galleryImages: _galleryImages,
    );
  }
}
