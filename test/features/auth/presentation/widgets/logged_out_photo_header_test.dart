import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_photo_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggedOutPhotoHeader', () {
    Widget buildSubject({double scale = 1.0, double horizontalOffset = 0.0}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 812,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                LoggedOutPhotoHeader(
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

      expect(find.byType(LoggedOutPhotoHeader), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('displays photo text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('photo'), findsOneWidget);
    });

    testWidgets('renders icon container', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('applies scale correctly', (tester) async {
      const scale = 1.0;
      await tester.pumpWidget(buildSubject(scale: scale));
      await tester.pumpAndSettle();

      final Positioned positioned = tester.widget(find.byType(Positioned));
      expect(positioned.left, equals(84 * scale));
      expect(positioned.top, equals(307 * scale));
      expect(positioned.width, equals(206 * scale));
      expect(positioned.height, equals(54 * scale));
    });

    testWidgets('applies horizontal offset correctly', (tester) async {
      const horizontalOffset = 50.0;
      const scale = 1.0;
      await tester.pumpWidget(
        buildSubject(scale: scale, horizontalOffset: horizontalOffset),
      );
      await tester.pumpAndSettle();

      final Positioned positioned = tester.widget(find.byType(Positioned));
      expect(positioned.left, equals(horizontalOffset + 84 * scale));
    });

    testWidgets('icon container has gradient', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      expect(containers, findsWidgets);

      // Find container with gradient decoration
      Container? gradientContainer;
      for (final element in tester.allElements) {
        final widget = element.widget;
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          if (decoration.gradient != null) {
            gradientContainer = widget;
            break;
          }
        }
      }
      expect(gradientContainer, isNotNull);
    });
  });
}
