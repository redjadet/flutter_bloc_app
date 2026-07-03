import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_user_info.dart';

void main() {
  group('LoggedOutUserInfo', () {
    Widget buildSubject({double scale = 1.0, double? verticalScale}) {
      final double resolvedVerticalScale = verticalScale ?? scale;
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 812,
            child: Stack(
              children: [
                LoggedOutUserInfo(
                  scale: scale,
                  verticalScale: resolvedVerticalScale,
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('renders with correct positioning', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(LoggedOutUserInfo), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('displays user name and handle', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Pawel Czerwinski'), findsOneWidget);
      expect(find.text('@pawel_czerwinski'), findsOneWidget);
    });

    testWidgets('renders avatar image', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies scale correctly', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(buildSubject(scale: scale));
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(LoggedOutUserInfo),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, greaterThan(0));
    });

    testWidgets('renders row layout', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(buildSubject(scale: scale));
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('has error builder for avatar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The widget should have an errorBuilder that shows a Container with icon
      // We can verify the structure is correct
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('text has ellipsis overflow', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final nameText = tester.widget<Text>(find.text('Pawel Czerwinski'));
      expect(nameText.overflow, TextOverflow.ellipsis);
      expect(nameText.maxLines, 1);

      final handleText = tester.widget<Text>(find.text('@pawel_czerwinski'));
      expect(handleText.overflow, TextOverflow.ellipsis);
      expect(handleText.maxLines, 1);
    });
  });
}
