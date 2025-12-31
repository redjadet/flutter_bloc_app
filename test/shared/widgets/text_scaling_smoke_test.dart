import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Text Scaling Smoke Tests', () {
    testWidgets('CommonPageLayout scales text at 1.3x', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: const MaterialApp(
            home: CommonPageLayout(
              title: 'Scaling Test',
              body: Column(
                children: [Text('Primary content'), Text('Secondary content')],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scaling Test'), findsOneWidget);
      expect(find.text('Primary content'), findsOneWidget);
      expect(find.text('Secondary content'), findsOneWidget);
    });

    testWidgets('CommonErrorView scales text at 1.3x', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: const MaterialApp(
            home: Scaffold(
              body: CommonErrorView(message: 'Test error message'),
            ),
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
    });
  });
}
