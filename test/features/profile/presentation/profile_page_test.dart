import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/profile.dart';
import 'package:flutter_test/flutter_test.dart';

const _profileLoadDuration = Duration(milliseconds: 600);

Future<void> _pumpProfilePage(final WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
  await tester.pump(_profileLoadDuration);
  await tester.pump();
}

void main() {
  group('ProfilePage', () {
    testWidgets('renders profile page', (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(_profileLoadDuration);
      await tester.pump();
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

    testWidgets('displays profile header with avatar', (final tester) async {
      await _pumpProfilePage(tester);
      expect(find.byType(ProfileHeader), findsOneWidget);
    });

    testWidgets('displays action buttons', (final tester) async {
      await _pumpProfilePage(tester);
      expect(find.byType(ProfileActionButtons), findsOneWidget);
    });

    testWidgets('displays image gallery', (final tester) async {
      await _pumpProfilePage(tester);
      expect(find.byType(ProfileGallery), findsOneWidget);
    });

    testWidgets('displays bottom navigation', (final tester) async {
      await _pumpProfilePage(tester);
      expect(find.byType(ProfileBottomNav), findsOneWidget);
    });
  });
}
