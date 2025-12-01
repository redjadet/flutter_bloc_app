import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveButtonsContext', () {
    testWidgets('responsiveButtonHeight returns correct value for mobile', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final height = context.responsiveButtonHeight;
              expect(height, greaterThan(0));
              return SizedBox(height: height);
            },
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('responsiveButtonPadding returns correct value', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = context.responsiveButtonPadding;
              expect(padding, greaterThan(0));
              return SizedBox(width: padding);
            },
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('responsiveButtonStyle has correct properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final style = context.responsiveButtonStyle;
              expect(style.padding, isNotNull);
              expect(style.minimumSize, isNotNull);
              expect(style.textStyle, isNotNull);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('responsiveElevatedButtonStyle has correct properties', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final style = context.responsiveElevatedButtonStyle;
              expect(style.padding, isNotNull);
              expect(style.minimumSize, isNotNull);
              expect(style.textStyle, isNotNull);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('responsiveTextButtonStyle has correct properties', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final style = context.responsiveTextButtonStyle;
              expect(style.padding, isNotNull);
              expect(style.minimumSize, isNotNull);
              expect(style.textStyle, isNotNull);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('responsiveFilledButtonStyle has correct properties', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final style = context.responsiveFilledButtonStyle;
              expect(style.padding, isNotNull);
              expect(style.minimumSize, isNotNull);
              expect(style.textStyle, isNotNull);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('button styles are consistent across different contexts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final elevatedStyle = context.responsiveElevatedButtonStyle;
              final textStyle = context.responsiveTextButtonStyle;
              final filledStyle = context.responsiveFilledButtonStyle;

              // All styles should have similar padding and minimum size
              expect(elevatedStyle.padding, isNotNull);
              expect(textStyle.padding, isNotNull);
              expect(filledStyle.padding, isNotNull);

              expect(elevatedStyle.minimumSize, isNotNull);
              expect(textStyle.minimumSize, isNotNull);
              expect(filledStyle.minimumSize, isNotNull);

              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pump();
    });
  });
}
