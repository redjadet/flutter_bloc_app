import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/services/retry_notification_service.dart';
import 'package:flutter_bloc_app/shared/widgets/retry_snackbar_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetrySnackBarListener', () {
    testWidgets('shows snackbar when notification is received', (
      final tester,
    ) async {
      final controller = StreamController<RetryNotification>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetrySnackBarListener(
              notifications: controller.stream,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      controller.add(
        RetryNotification(
          method: 'GET',
          uri: Uri.parse('https://example.com'),
          attempt: 1,
          maxAttempts: 3,
          delay: const Duration(seconds: 1),
          error: Exception('Test error'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SnackBar), findsOneWidget);
      await controller.close();
    });

    testWidgets('throttles notifications within 2 seconds', (
      final tester,
    ) async {
      final controller = StreamController<RetryNotification>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetrySnackBarListener(
              notifications: controller.stream,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      controller.add(
        RetryNotification(
          method: 'GET',
          uri: Uri.parse('https://example.com'),
          attempt: 1,
          maxAttempts: 3,
          delay: const Duration(seconds: 1),
          error: Exception('Test error'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(SnackBar), findsOneWidget);

      // Add another notification immediately
      controller.add(
        RetryNotification(
          method: 'GET',
          uri: Uri.parse('https://example.com'),
          attempt: 1,
          maxAttempts: 3,
          delay: const Duration(seconds: 1),
          error: Exception('Test error'),
        ),
      );
      await tester.pump();

      // Should still only have one snackbar (throttled)
      expect(find.byType(SnackBar), findsOneWidget);

      await controller.close();
    });

    testWidgets('handles notification when widget is not mounted', (
      final tester,
    ) async {
      final controller = StreamController<RetryNotification>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetrySnackBarListener(
              notifications: controller.stream,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Remove widget from tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Should not throw
      controller.add(
        RetryNotification(
          method: 'GET',
          uri: Uri.parse('https://example.com'),
          attempt: 1,
          maxAttempts: 3,
          delay: const Duration(seconds: 1),
          error: Exception('Test error'),
        ),
      );
      await tester.pump();

      await controller.close();
    });

    testWidgets(
      'handles notification when ScaffoldMessenger is not available',
      (final tester) async {
        final controller = StreamController<RetryNotification>.broadcast();

        await tester.pumpWidget(
          MaterialApp(
            home: RetrySnackBarListener(
              notifications: controller.stream,
              child: const Text('Content'),
            ),
          ),
        );

        // Should not throw
        controller.add(
          RetryNotification(
            method: 'GET',
            uri: Uri.parse('https://example.com'),
            attempt: 1,
            maxAttempts: 3,
            delay: const Duration(seconds: 1),
            error: Exception('Test error'),
          ),
        );
        await tester.pump();

        await controller.close();
      },
    );

    testWidgets('updates subscription when notifications stream changes', (
      final tester,
    ) async {
      final controller1 = StreamController<RetryNotification>.broadcast();
      final controller2 = StreamController<RetryNotification>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetrySnackBarListener(
              notifications: controller1.stream,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetrySnackBarListener(
              notifications: controller2.stream,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      controller2.add(
        RetryNotification(
          method: 'GET',
          uri: Uri.parse('https://example.com'),
          attempt: 1,
          maxAttempts: 3,
          delay: const Duration(seconds: 1),
          error: Exception('Test error'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SnackBar), findsOneWidget);

      await controller1.close();
      await controller2.close();
    });

    testWidgets('disposes subscription on dispose', (final tester) async {
      final controller = StreamController<RetryNotification>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetrySnackBarListener(
              notifications: controller.stream,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Should not throw
      controller.add(
        RetryNotification(
          method: 'GET',
          uri: Uri.parse('https://example.com'),
          attempt: 1,
          maxAttempts: 3,
          delay: const Duration(seconds: 1),
          error: Exception('Test error'),
        ),
      );
      await tester.pump();

      await controller.close();
    });
  });
}
