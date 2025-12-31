import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_photo_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggedOutPhotoHeader', () {
    Widget buildSubject({double scale = 1.0, double? verticalScale}) {
      final double resolvedVerticalScale = verticalScale ?? scale;
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

      expect(find.byType(LoggedOutPhotoHeader), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
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

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(LoggedOutPhotoHeader),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, equals(54 * scale));
    });

    testWidgets('renders row layout', (tester) async {
      const scale = 1.0;
      await tester.pumpWidget(buildSubject(scale: scale));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsOneWidget);
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
