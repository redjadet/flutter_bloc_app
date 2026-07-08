import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTypography', () {
    testWidgets('derives styles from theme text roles', (final tester) async {
      late TextStyle button;
      late TextStyle body;
      late TextStyle title;
      late TextStyle headline;
      late TextStyle display;
      late TextStyle label;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              bodyMedium: TextStyle(fontSize: 16),
              titleLarge: TextStyle(fontSize: 20),
              headlineMedium: TextStyle(fontSize: 24),
              displayMedium: TextStyle(fontSize: 32),
              labelMedium: TextStyle(fontSize: 12),
            ),
          ),
          home: Builder(
            builder: (final context) {
              button = AppTypography.buttonText(
                context,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              );
              body = AppTypography.bodyText(context, fontSize: 18);
              title = AppTypography.titleText(context);
              headline = AppTypography.headlineText(context);
              display = AppTypography.displayText(context);
              label = AppTypography.labelText(context, letterSpacing: 1.2);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(button.color, Colors.red);
      expect(button.fontWeight, FontWeight.bold);
      expect(body.fontSize, 18);
      expect(title.fontSize, 20);
      expect(headline.fontSize, 24);
      expect(display.fontSize, 32);
      expect(label.letterSpacing, 1.2);
    });
  });
}
