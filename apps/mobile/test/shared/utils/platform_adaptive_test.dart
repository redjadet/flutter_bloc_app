import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('PlatformAdaptive', () {
    testWidgets('isCupertino returns false for Android platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) {
              expect(PlatformAdaptive.isCupertino(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('isCupertino returns true for iOS platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) {
              expect(PlatformAdaptive.isCupertino(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('isCupertino returns true for macOS platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: Builder(
            builder: (context) {
              expect(PlatformAdaptive.isCupertino(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    test('isCupertinoFromTheme returns true for iOS theme', () {
      final theme = ThemeData(platform: TargetPlatform.iOS);
      expect(PlatformAdaptive.isCupertinoFromTheme(theme), isTrue);
    });

    test('isCupertinoFromTheme returns false for Android theme', () {
      final theme = ThemeData(platform: TargetPlatform.android);
      expect(PlatformAdaptive.isCupertinoFromTheme(theme), isFalse);
    });

    test('isCupertinoPlatform returns true for iOS', () {
      expect(PlatformAdaptive.isCupertinoPlatform(TargetPlatform.iOS), isTrue);
    });

    test('isCupertinoPlatform returns true for macOS', () {
      expect(
        PlatformAdaptive.isCupertinoPlatform(TargetPlatform.macOS),
        isTrue,
      );
    });

    test('isCupertinoPlatform returns false for Android', () {
      expect(
        PlatformAdaptive.isCupertinoPlatform(TargetPlatform.android),
        isFalse,
      );
    });

    testWidgets('button delegates to PlatformAdaptiveButtons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.button(
                context: context,
                onPressed: () {},
                child: const Text('Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('textButton delegates to PlatformAdaptiveButtons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.textButton(
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

    testWidgets('filledButton delegates to PlatformAdaptiveButtons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.filledButton(
                context: context,
                onPressed: () {},
                child: const Text('Filled Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('outlinedButton delegates to PlatformAdaptiveButtons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.outlinedButton(
                context: context,
                onPressed: () {},
                child: const Text('Outlined Button'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('dialogAction delegates to PlatformAdaptiveButtons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.dialogAction(
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
    });

    testWidgets('textField delegates to PlatformAdaptiveInputs', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.textField(
                context: context,
                controller: controller,
                hintText: 'Enter text',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('checkbox delegates to PlatformAdaptiveInputs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.checkbox(
                context: context,
                value: true,
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('listTile delegates to PlatformAdaptiveInputs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: PlatformAdaptive.listTile(
                context: context,
                title: const Text('Title'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
    });
  });
}
