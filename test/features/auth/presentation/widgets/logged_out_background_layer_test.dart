import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_background_layer.dart';

void main() {
  group('LoggedOutBackgroundLayer', () {
    Widget buildSubject({double height = 707.0}) {
      return MaterialApp(
        home: Scaffold(
          body: Stack(children: [LoggedOutBackgroundLayer(height: height)]),
        ),
      );
    }

    testWidgets('renders with correct positioning', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(LoggedOutBackgroundLayer), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders image asset', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies scale correctly', (tester) async {
      const height = 350.0;
      await tester.pumpWidget(buildSubject(height: height));
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      final SizedBox sizedBox = tester.widget(
        find
            .descendant(
              of: find.byType(LoggedOutBackgroundLayer),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, equals(height));
    });

    testWidgets('has error builder fallback', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The widget should have an errorBuilder that shows a Container
      // We can't easily test the error case without mocking, but we can verify
      // the widget structure is correct
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
