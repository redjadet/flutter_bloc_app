import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/profile/profile.dart';
import 'package:flutter_test/flutter_test.dart';

const _testUser = ProfileUser(
  name: 'Jane',
  location: 'San Francisco, CA',
  avatarUrl: 'https://example.com/avatar.png',
  galleryImages: [
    ProfileImage(url: 'https://example.com/1.png', aspectRatio: 0.71),
    ProfileImage(url: 'https://example.com/2.png', aspectRatio: 1.41),
    ProfileImage(url: 'https://example.com/3.png', aspectRatio: 1.0),
    ProfileImage(url: 'https://example.com/4.png', aspectRatio: 1.3),
  ],
);

Future<void> _pumpProfilePage(
  final WidgetTester tester, {
  required final ProfileRepository repository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => ProfileCubit(repository: repository)..loadProfile(),
        child: const ProfilePage(),
      ),
    ),
  );
}

Future<void> _resolveAsyncWork(final WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

class _SuccessProfileRepository implements ProfileRepository {
  const _SuccessProfileRepository();

  @override
  Future<ProfileUser> getProfile() async => _testUser;
}

class _FlakyProfileRepository implements ProfileRepository {
  int _calls = 0;

  @override
  Future<ProfileUser> getProfile() async {
    _calls++;
    if (_calls == 1) {
      throw Exception('network down');
    }
    return _testUser;
  }
}

void main() {
  group('ProfilePage', () {
    testWidgets('renders loading then profile content', (final tester) async {
      await _pumpProfilePage(
        tester,
        repository: const _SuccessProfileRepository(),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await _resolveAsyncWork(tester);

      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('SAN FRANCISCO, CA'), findsOneWidget);
      expect(find.text('FOLLOW JANE'), findsOneWidget);
      expect(find.text('MESSAGE'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('SEE MORE'),
        find.byType(CustomScrollView),
        const Offset(0, -200),
      );
      expect(find.text('SEE MORE'), findsOneWidget);
    });

    testWidgets('displays profile sections', (final tester) async {
      await _pumpProfilePage(
        tester,
        repository: const _SuccessProfileRepository(),
      );
      await _resolveAsyncWork(tester);

      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.byType(ProfileActionButtons), findsOneWidget);
      expect(find.byType(ProfileGallery, skipOffstage: false), findsOneWidget);
      expect(find.byType(ProfileBottomNav), findsOneWidget);
    });

    testWidgets('shows retry view when loading fails', (final tester) async {
      final repository = _FlakyProfileRepository();
      await _pumpProfilePage(tester, repository: repository);
      await _resolveAsyncWork(tester);

      expect(find.text('Failed to load profile'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      await tester.tap(find.text('TRY AGAIN'));
      await _resolveAsyncWork(tester);

      expect(find.text('Jane'), findsOneWidget);
    });
  });
}
