import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_button_styles.dart';
import 'package:flutter_bloc_app/shared/responsive/responsive_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileButtonStyles', () {
    testWidgets('profileOutlinedButtonStyle creates button style', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: Builder(
                builder: (final context) {
                  final style = profileOutlinedButtonStyle(
                    context,
                    backgroundColor: Colors.blue,
                  );
                  expect(style, isNotNull);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('profileButtonTextStyle creates text style with theme', (
      final tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            child: Scaffold(
              body: Builder(
                builder: (final context) {
                  final style = profileButtonTextStyle(
                    context,
                    color: Colors.red,
                    fontSize: 16.0,
                  );
                  expect(style, isNotNull);
                  expect(style.color, Colors.red);
                  expect(style.fontSize, 16.0);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'profileButtonTextStyle falls back when theme textTheme is null',
      (final tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              textTheme: const TextTheme(), // Empty textTheme
            ),
            home: ResponsiveScope(
              child: Scaffold(
                body: Builder(
                  builder: (final context) {
                    final style = profileButtonTextStyle(
                      context,
                      color: Colors.blue,
                      fontSize: 14.0,
                    );
                    expect(style, isNotNull);
                    expect(style.color, Colors.blue);
                    expect(style.fontSize, 14.0);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );

        // Should not throw
        expect(tester.takeException(), isNull);
      },
    );
  });
}
