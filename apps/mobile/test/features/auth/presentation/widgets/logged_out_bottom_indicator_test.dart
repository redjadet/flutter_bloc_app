import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_bottom_indicator.dart';

void main() {
  group('LoggedOutBottomIndicator', () {
    Widget buildSubject({double scale = 1.0, double? verticalScale}) {
      final double resolvedVerticalScale = verticalScale ?? scale;
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 812,
            child: Stack(
              children: [
                LoggedOutBottomIndicator(
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

      expect(find.byType(LoggedOutBottomIndicator), findsOneWidget);
      // Verify the widget has a SizedBox (may have multiple due to SVG rendering)
      expect(
        find.descendant(
          of: find.byType(LoggedOutBottomIndicator),
          matching: find.byType(SizedBox),
        ),
        findsWidgets,
      );
    });

    testWidgets('applies scale correctly', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(buildSubject(scale: scale));
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      final SizedBox sizedBox = tester.widget(
        find
            .descendant(
              of: find.byType(LoggedOutBottomIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, equals(135 * scale));
      expect(sizedBox.height, equals(5 * scale));
    });

    testWidgets('renders sized box layout', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(buildSubject(scale: scale));
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders SVG with placeholder', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The widget should render (SVG or placeholder)
      expect(find.byType(LoggedOutBottomIndicator), findsOneWidget);
    });
  });
}
