import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/profile/profile.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

const _profileUser = ProfileUser(
  name: 'Jane',
  location: 'San Francisco, CA',
  avatarUrl: 'https://example.com/avatar.png',
  galleryImages: [
    ProfileImage(url: 'https://example.com/1.png', aspectRatio: 0.71),
  ],
);

class _StubProfileRepository implements ProfileRepository {
  _StubProfileRepository(this._onGetProfile);

  final Future<ProfileUser> Function() _onGetProfile;

  @override
  Future<ProfileUser> getProfile() => _onGetProfile();
}

void main() {
  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits loading then success with profile data',
      build: () => ProfileCubit(
        repository: _StubProfileRepository(() async => _profileUser),
      ),
      act: (final cubit) => cubit.loadProfile(),
      expect: () => <ProfileState>[
        const ProfileState(status: ViewStatus.loading),
        const ProfileState(status: ViewStatus.success, user: _profileUser),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits error state when repository throws',
      build: () => ProfileCubit(
        repository: _StubProfileRepository(() => Future.error(Exception())),
      ),
      act: (final cubit) => cubit.loadProfile(),
      expect: () => <dynamic>[
        const ProfileState(status: ViewStatus.loading),
        isA<ProfileState>()
            .having((final state) => state.status, 'status', ViewStatus.error)
            .having((final state) => state.error, 'error', isA<Exception>()),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'can recover after an error',
      build: () {
        var fail = true;
        return ProfileCubit(
          repository: _StubProfileRepository(() async {
            if (fail) {
              fail = false;
              throw Exception('offline');
            }
            return _profileUser;
          }),
        );
      },
      act: (final cubit) async {
        await cubit.loadProfile();
        await cubit.loadProfile();
      },
      expect: () => <dynamic>[
        const ProfileState(status: ViewStatus.loading),
        isA<ProfileState>().having(
          (final state) => state.status,
          'status',
          ViewStatus.error,
        ),
        const ProfileState(status: ViewStatus.loading),
        const ProfileState(status: ViewStatus.success, user: _profileUser),
      ],
    );
  });
}
