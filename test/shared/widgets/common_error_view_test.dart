import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/widgets/common_error_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonErrorView', () {
    testWidgets('renders message and retry button when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonErrorView(
              message: 'Something went wrong',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byType(CommonRetryButton), findsOneWidget);
    });

    testWidgets('renders without retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CommonErrorView(message: 'No retry available')),
        ),
      );

      expect(find.text('No retry available'), findsOneWidget);
      expect(find.byType(CommonRetryButton), findsNothing);
    });
  });
}
