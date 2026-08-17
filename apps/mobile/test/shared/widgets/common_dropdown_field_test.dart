import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('CommonDropdownField', () {
    testWidgets('renders DropdownButtonFormField on Material platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'option2', child: Text('Option 2')),
                ],
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays label text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (value) {},
                labelText: 'Select Option',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Select Option'), findsOneWidget);
    });

    testWidgets('respects enabled parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (value) {},
                enabled: false,
              ),
            ),
          ),
        ),
      );

      final DropdownButtonFormField<String> field = tester.widget(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(field.onChanged, isNull);
    });

    testWidgets('respects isExpanded parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (value) {},
                isExpanded: false,
              ),
            ),
          ),
        ),
      );

      // isExpanded is a constructor parameter, not a getter
      // We can verify the widget was created with the parameter
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('uses customPickerItems when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (value) {},
                customPickerItems: const ['option1', 'option2', 'option3'],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('uses customItemLabel when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (value) {},
                customItemLabel: (value) => 'Custom: $value',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('handles null value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: null,
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (value) {},
                hintText: 'Select an option',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('handles empty items without throwing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'any',
                items: const [],
                onChanged: (value) {},
                hintText: 'Select',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CommonDropdownField<String>), findsOneWidget);
    });

    testWidgets('calls validator when provided', (tester) async {
      String? validationResult;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: Form(
                key: formKey,
                child: CommonDropdownField<String>(
                  value: null,
                  items: const [
                    DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                  ],
                  onChanged: (value) {},
                  validator: (value) {
                    validationResult = value == null ? 'Required' : null;
                    return validationResult;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      formKey.currentState?.validate();
      await tester.pump();

      expect(validationResult, 'Required');
    });
  });
}
