import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonPageLayout', () {
    testWidgets('renders title and body', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CommonPageLayout(
            title: 'Test Title',
            body: Text('Body Content'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders body without responsive wrapper when disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CommonPageLayout(
            title: 'No Wrapper',
            useResponsiveBody: false,
            body: Text('Plain Body'),
          ),
        ),
      );

      expect(find.text('No Wrapper'), findsOneWidget);
      expect(find.text('Plain Body'), findsOneWidget);
    });
  });
}
