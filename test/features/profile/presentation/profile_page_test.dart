import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('renders profile page', (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('SAN FRANCISCO, CA'), findsOneWidget);
      expect(find.text('FOLLOW JANE'), findsOneWidget);
      expect(find.text('MESSAGE'), findsOneWidget);
      expect(find.text('SEE MORE'), findsOneWidget);
    });

    testWidgets('displays profile header with avatar', (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pumpAndSettle();

      expect(find.byType(ProfileHeader), findsOneWidget);
    });

    testWidgets('displays action buttons', (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pumpAndSettle();

      expect(find.byType(ProfileActionButtons), findsOneWidget);
    });

    testWidgets('displays image gallery', (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pumpAndSettle();

      expect(find.byType(ProfileGallery), findsOneWidget);
    });

    testWidgets('displays bottom navigation', (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

      await tester.pumpAndSettle();

      expect(find.byType(ProfileBottomNav), findsOneWidget);
    });
  });
}
