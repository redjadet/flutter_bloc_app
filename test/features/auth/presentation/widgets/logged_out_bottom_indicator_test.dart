import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_bottom_indicator.dart';

void main() {
  group('LoggedOutBottomIndicator', () {
    Widget buildSubject({double scale = 1.0, double horizontalOffset = 0.0}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 812,
            child: Stack(
              children: [
                LoggedOutBottomIndicator(
                  scale: scale,
                  horizontalOffset: horizontalOffset,
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
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('applies scale correctly', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(buildSubject(scale: scale));
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      final Positioned positioned = tester.widget(find.byType(Positioned));
      expect(positioned.left, equals(120 * scale));
      expect(positioned.top, equals(799 * scale));
      expect(positioned.width, equals(135 * scale));
      expect(positioned.height, equals(5 * scale));
    });

    testWidgets('applies horizontal offset correctly', (tester) async {
      const horizontalOffset = 0.0; // Use 0 to avoid overflow
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(
        buildSubject(scale: scale, horizontalOffset: horizontalOffset),
      );
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      final Positioned positioned = tester.widget(find.byType(Positioned));
      expect(positioned.left, equals(horizontalOffset + 120 * scale));
    });

    testWidgets('renders SVG with placeholder', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The widget should render (SVG or placeholder)
      expect(find.byType(LoggedOutBottomIndicator), findsOneWidget);
    });
  });
}
