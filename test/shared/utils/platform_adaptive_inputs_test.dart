import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive_inputs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformAdaptiveInputs', () {
    testWidgets('textField creates Material TextField on Material platform', (
      final tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                hintText: 'Enter text',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(CupertinoTextField), findsNothing);
    });

    testWidgets('textField uses placeholder when hintText is null', (
      final tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                placeholder: 'Placeholder',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('textField respects enabled parameter', (final tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                enabled: false,
              ),
            ),
          ),
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('textField respects maxLines parameter', (final tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                maxLines: 3,
              ),
            ),
          ),
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.maxLines, 3);
    });

    testWidgets('checkbox creates Material Checkbox on Material platform', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: true,
                onChanged: (final value) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(CupertinoCheckbox), findsNothing);
    });

    testWidgets('checkbox respects value parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: false,
                onChanged: (final value) {},
              ),
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('checkbox respects null value', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: null,
                onChanged: (final value) {},
              ),
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      // Material Checkbox requires tristate: true to accept null values
      expect(checkbox.tristate, isTrue);
      expect(checkbox.value, isNull);
    });

    testWidgets('listTile creates Material ListTile on Material platform', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.listTile(
                context: context,
                title: const Text('Title'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(CupertinoListTile), findsNothing);
    });

    testWidgets('listTile respects selected parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.listTile(
                context: context,
                title: const Text('Title'),
                selected: true,
              ),
            ),
          ),
        ),
      );

      final ListTile tile = tester.widget(find.byType(ListTile));
      expect(tile.selected, isTrue);
    });

    testWidgets('listTile includes subtitle when provided', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.listTile(
                context: context,
                title: const Text('Title'),
                subtitle: const Text('Subtitle'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('textField respects autofocus parameter', (final tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                autofocus: true,
              ),
            ),
          ),
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.autofocus, isTrue);
    });

    testWidgets('textField respects keyboardType parameter', (
      final tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('textField respects obscureText parameter', (
      final tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                obscureText: true,
              ),
            ),
          ),
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('textField uses custom decoration when provided', (
      final tester,
    ) async {
      final controller = TextEditingController();
      final decoration = const InputDecoration(labelText: 'Custom Label');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.textField(
                context: context,
                controller: controller,
                decoration: decoration,
              ),
            ),
          ),
        ),
      );

      final TextField field = tester.widget(find.byType(TextField));
      expect(field.decoration?.labelText, 'Custom Label');
    });

    testWidgets('checkbox respects activeColor parameter', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: true,
                onChanged: (final value) {},
                activeColor: Colors.red,
              ),
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.activeColor, Colors.red);
    });

    testWidgets('checkbox respects checkColor parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: true,
                onChanged: (final value) {},
                checkColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.checkColor, Colors.white);
    });

    testWidgets('listTile includes leading widget when provided', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.listTile(
                context: context,
                title: const Text('Title'),
                leading: const Icon(Icons.star),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('listTile includes trailing widget when provided', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.listTile(
                context: context,
                title: const Text('Title'),
                trailing: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('listTile calls onTap when provided', (final tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (final context) => PlatformAdaptiveInputs.listTile(
                context: context,
                title: const Text('Title'),
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });
  });
}
