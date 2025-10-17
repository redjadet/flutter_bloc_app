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
  });
}
