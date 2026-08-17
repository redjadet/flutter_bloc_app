import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('PlatformAdaptiveInputs', () {
    testWidgets('textField creates Material TextField on Material platform', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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

    testWidgets('textField respects enabled parameter', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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

    testWidgets('textField respects maxLines parameter', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: true,
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(CupertinoCheckbox), findsNothing);
    });

    testWidgets('checkbox respects value parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: false,
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('checkbox respects null value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: null,
                onChanged: (value) {},
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
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.listTile(
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

    testWidgets('listTile respects selected parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.listTile(
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

    testWidgets('listTile includes subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.listTile(
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

    testWidgets('textField respects autofocus parameter', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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

    testWidgets('textField respects keyboardType parameter', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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

    testWidgets('textField respects obscureText parameter', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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
      tester,
    ) async {
      final controller = TextEditingController();
      final decoration = const InputDecoration(labelText: 'Custom Label');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.textField(
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

    testWidgets('checkbox respects activeColor parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: true,
                onChanged: (value) {},
                activeColor: Colors.red,
              ),
            ),
          ),
        ),
      );

      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.activeColor, Colors.red);
    });

    testWidgets('checkbox respects checkColor parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.checkbox(
                context: context,
                value: true,
                onChanged: (value) {},
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
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.listTile(
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
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.listTile(
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

    testWidgets('listTile calls onTap when provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => PlatformAdaptiveInputs.listTile(
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
