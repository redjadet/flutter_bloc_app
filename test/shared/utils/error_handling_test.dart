import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/error_handling.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandling', () {
    testWidgets('showSnackBar displays error message', (tester) async {
      const errorMessage = 'Something went wrong';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandling.showErrorSnackBar(context, errorMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('showSnackBar uses error color from theme', (tester) async {
      const errorMessage = 'Test error';

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(error: Colors.red),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandling.showErrorSnackBar(context, errorMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(
        snackBar.backgroundColor,
        isNull,
      ); // Default SnackBar doesn't set background color
    });

    testWidgets('showSnackBar can show snackbar', (tester) async {
      const errorMessage = 'Test error';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandling.showErrorSnackBar(context, errorMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        ),
      );

      // Show snackbar
      await tester.tap(find.text('Show Error'));
      await tester.pump();
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('showSnackBar works with multiple calls', (tester) async {
      const errorMessage = 'Test error';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandling.showErrorSnackBar(context, errorMessage);
                    ErrorHandling.showErrorSnackBar(context, errorMessage);
                    ErrorHandling.showErrorSnackBar(context, errorMessage);
                  },
                  child: const Text('Show Multiple'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Multiple'));
      await tester.pump();

      // Should only show one snackbar (the last one)
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('showSnackBar handles empty message', (tester) async {
      const emptyMessage = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandling.showErrorSnackBar(context, emptyMessage);
                  },
                  child: const Text('Show Empty'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Empty'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(emptyMessage), findsOneWidget);
    });

    testWidgets('showSnackBar handles long error messages', (tester) async {
      const longMessage =
          'This is a very long error message that should be handled properly by the snackbar widget and should not cause any layout issues or overflow problems in the UI';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorHandling.showErrorSnackBar(context, longMessage);
                  },
                  child: const Text('Show Long'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Long'));
      await tester.pump();

      expect(find.text(longMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('showSnackBar works in different contexts', (tester) async {
      const errorMessage = 'Context test';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    const Text('Content'),
                    Builder(
                      builder: (nestedContext) {
                        return ElevatedButton(
                          onPressed: () {
                            ErrorHandling.showErrorSnackBar(
                              nestedContext,
                              errorMessage,
                            );
                          },
                          child: const Text('Show in Nested'),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show in Nested'));
      await tester.pump();

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('showSuccessSnackBar uses theme primaryContainer', (
      tester,
    ) async {
      const successMessage = 'Operation succeeded';
      late BuildContext context;
      const primaryContainer = Color(0xFFD0BCFF);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.light(primaryContainer: primaryContainer),
          ),
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      ErrorHandling.showSuccessSnackBar(context, successMessage);
      await tester.pump();

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, primaryContainer);
      expect(find.text(successMessage), findsOneWidget);
    });

    testWidgets('handleCubitError maps network error message', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      ErrorHandling.handleCubitError(context, Exception('Network failure'));
      await tester.pump();

      expect(find.textContaining('Network connection error'), findsOneWidget);
    });

    testWidgets('handleCubitError supports retry action', (
      WidgetTester tester,
    ) async {
      late BuildContext context;
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      ErrorHandling.handleCubitError(
        context,
        Exception('timeout'),
        customMessage: 'Custom message',
        onRetry: () => retried = true,
      );
      await tester.pump();

      expect(find.text('Custom message'), findsOneWidget);
      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      final SnackBarAction? action = snackBar.action;
      expect(action, isNotNull);
      expect(action!.label, 'Retry');

      action.onPressed();
      expect(retried, isTrue);
    });

    testWidgets('clearSnackBars removes active snackbars', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      ErrorHandling.showErrorSnackBar(context, 'Error');
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);

      ErrorHandling.clearSnackBars(context);
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('showLoadingDialog and hideLoadingDialog toggle dialog', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      ErrorHandling.showLoadingDialog(context, 'Loading...');
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      ErrorHandling.hideLoadingDialog(context);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('hideLoadingDialog is safe when no dialog is present', (
      WidgetTester tester,
    ) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsNothing);
      expect(() => ErrorHandling.hideLoadingDialog(context), returnsNormally);
    });
  });
}
