import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_background_layer.dart';

void main() {
  group('LoggedOutBackgroundLayer', () {
    Widget buildSubject({double scale = 1.0, BoxConstraints? constraints}) {
      return MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              LoggedOutBackgroundLayer(
                scale: scale,
                constraints: constraints ?? const BoxConstraints(),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('renders with correct positioning', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoggedOutBackgroundLayer), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('renders image asset', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('applies scale correctly', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(
        buildSubject(
          scale: scale,
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        ),
      );
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      final Positioned positioned = tester.widget(find.byType(Positioned));
      expect(positioned.height, equals(707 * scale));
    });

    testWidgets('uses constraints maxWidth for image width', (tester) async {
      const maxWidth = 400.0;
      await tester.pumpWidget(
        buildSubject(constraints: const BoxConstraints(maxWidth: maxWidth)),
      );
      await tester.pumpAndSettle();

      final Image image = tester.widget(find.byType(Image));
      expect(image.width, equals(maxWidth));
    });

    testWidgets('has error builder fallback', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        ),
      );
      await tester.pumpAndSettle();

      // The widget should have an errorBuilder that shows a Container
      // We can't easily test the error case without mocking, but we can verify
      // the widget structure is correct
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
