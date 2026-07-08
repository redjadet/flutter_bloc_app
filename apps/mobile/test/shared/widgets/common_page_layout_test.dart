import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
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

    testWidgets('uses custom appBar instead of CommonAppBar title', (
      tester,
    ) async {
      const customTitle = Key('custom-app-bar-title');

      await tester.pumpWidget(
        MaterialApp(
          home: CommonPageLayout(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(title: const Text('Custom', key: customTitle)),
            ),
            useResponsiveBody: false,
            body: const Text('Custom Body'),
          ),
        ),
      );

      expect(find.byKey(customTitle), findsOneWidget);
      expect(find.text('Custom Body'), findsOneWidget);
      expect(find.text('Test Title'), findsNothing);
    });
  });
}
