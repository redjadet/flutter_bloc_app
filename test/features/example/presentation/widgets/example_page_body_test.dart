import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/example/presentation/widgets/example_page_body.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExamplePageBody', () {
    testWidgets('invokes onOpenRegister when tapping register button', (
      final tester,
    ) async {
      bool registerTapped = false;
      final theme = ThemeData.light();
      await tester.pumpWidget(
        MaterialApp(
          home: ExamplePageBody(
            l10n: AppLocalizationsEn(),
            theme: theme,
            colors: theme.colorScheme,
            onBackPressed: () {},
            onLoadPlatformInfo: () {},
            onOpenWebsocket: () {},
            onOpenSearch: () {},
            onOpenTodoList: () {},
            onOpenProfile: () {},
            onOpenRegister: () {
              registerTapped = true;
            },
            onOpenLoggedOut: () {},
            onRunIsolates: () {},
            isRunningIsolates: false,
            isolateError: null,
            fibonacciInput: null,
            fibonacciResult: null,
            parallelValues: const <int>[],
            parallelDuration: Duration.zero,
            onOpenChatList: () {},
            onOpenLibraryDemo: () {},
          ),
        ),
      );

      final registerButton = find.byKey(
        const ValueKey('example-register-button'),
      );

      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton, warnIfMissed: false);
      await tester.pump();

      expect(registerTapped, isTrue);
    });
  });
}
