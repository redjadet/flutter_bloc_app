import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive_buttons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformAdaptiveButtons', () {
    testWidgets('button creates Material ElevatedButton on Material platform', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveButtons.button(
                context: context,
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('button respects onPressed parameter', (final tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveButtons.button(
                context: context,
                onPressed: () {
                  pressed = true;
                },
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('button respects disabled state', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveButtons.button(
                context: context,
                onPressed: null,
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      final ElevatedButton button = tester.widget(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('textButton creates Material TextButton on Material platform', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveButtons.textButton(
                context: context,
                onPressed: () {},
                child: const Text('Text Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets(
      'filledButton creates Material FilledButton on Material platform',
      (final tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (final context) =>
                    PlatformAdaptiveButtons.filledButton(
                      context: context,
                      onPressed: () {},
                      child: const Text('Filled Button'),
                    ),
              ),
            ),
          ),
        );

        expect(find.byType(FilledButton), findsOneWidget);
      },
    );

    testWidgets(
      'outlinedButton creates Material OutlinedButton on Material platform',
      (final tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (final context) =>
                    PlatformAdaptiveButtons.outlinedButton(
                      context: context,
                      onPressed: () {},
                      child: const Text('Outlined Button'),
                    ),
              ),
            ),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      },
    );

    testWidgets(
      'dialogAction creates Material TextButton on Material platform',
      (final tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (final context) =>
                    PlatformAdaptiveButtons.dialogAction(
                      context: context,
                      onPressed: () {},
                      label: 'Action',
                    ),
              ),
            ),
          ),
        );

        expect(find.byType(TextButton), findsOneWidget);
        expect(find.text('Action'), findsOneWidget);
      },
    );

    testWidgets(
      'dialogAction applies destructive styling when isDestructive is true',
      (final tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (final context) =>
                    PlatformAdaptiveButtons.dialogAction(
                      context: context,
                      onPressed: () {},
                      label: 'Delete',
                      isDestructive: true,
                    ),
              ),
            ),
          ),
        );

        final TextButton button = tester.widget(find.byType(TextButton));
        expect(button.style, isNotNull);
      },
    );
  });
}
