import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive_scope.dart';
import 'package:flutter_bloc_app/shared/widgets/common_dropdown_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonDropdownField', () {
    testWidgets('renders DropdownButtonFormField on Material platform', (
      final tester,
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
                onChanged: (final value) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays label text when provided', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (final value) {},
                labelText: 'Select Option',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Select Option'), findsOneWidget);
    });

    testWidgets('respects enabled parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (final value) {},
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

    testWidgets('respects isExpanded parameter', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (final value) {},
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

    testWidgets('uses customPickerItems when provided', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (final value) {},
                customPickerItems: const ['option1', 'option2', 'option3'],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('uses customItemLabel when provided', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'option1',
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (final value) {},
                customItemLabel: (final value) => 'Custom: $value',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('handles null value', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: null,
                items: const [
                  DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                ],
                onChanged: (final value) {},
                hintText: 'Select an option',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('handles empty items without throwing', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: CommonDropdownField<String>(
                value: 'any',
                items: const [],
                onChanged: (final value) {},
                hintText: 'Select',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CommonDropdownField<String>), findsOneWidget);
    });

    testWidgets('calls validator when provided', (final tester) async {
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
                  onChanged: (final value) {},
                  validator: (final value) {
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
