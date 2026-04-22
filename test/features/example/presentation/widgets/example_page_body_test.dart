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
            onOpenIgamingDemo: () {},
            onOpenStaffAppDemo: () {},
            onOpenFcmDemo: () {},
            onOpenScapes: () {},
            onOpenWalletconnectAuth: () {},
            onOpenCameraGallery: () {},
            onOpenCaseStudyDemo: () {},
            onOpenIapDemo: () {},
            onOpenAiDecisionDemo: () {},
            onOpenOnlineTherapyDemo: () {},
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

    testWidgets('invokes onOpenFcmDemo when tapping FCM demo button', (
      final tester,
    ) async {
      bool fcmTapped = false;
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
            onOpenRegister: () {},
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
            onOpenIgamingDemo: () {},
            onOpenStaffAppDemo: () {},
            onOpenFcmDemo: () {
              fcmTapped = true;
            },
            onOpenScapes: () {},
            onOpenWalletconnectAuth: () {},
            onOpenCameraGallery: () {},
            onOpenCaseStudyDemo: () {},
            onOpenIapDemo: () {},
            onOpenAiDecisionDemo: () {},
            onOpenOnlineTherapyDemo: () {},
          ),
        ),
      );

      final fcmButton = find.text('FCM Demo');
      await tester.ensureVisible(fcmButton);
      await tester.tap(fcmButton, warnIfMissed: false);
      await tester.pump();

      expect(fcmTapped, isTrue);
    });

    testWidgets('invokes onOpenCaseStudyDemo when tapping case study button', (
      final tester,
    ) async {
      bool caseStudyTapped = false;
      final theme = ThemeData.light();
      final l10n = AppLocalizationsEn();
      await tester.pumpWidget(
        MaterialApp(
          home: ExamplePageBody(
            l10n: l10n,
            theme: theme,
            colors: theme.colorScheme,
            onBackPressed: () {},
            onLoadPlatformInfo: () {},
            onOpenWebsocket: () {},
            onOpenSearch: () {},
            onOpenTodoList: () {},
            onOpenProfile: () {},
            onOpenRegister: () {},
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
            onOpenIgamingDemo: () {},
            onOpenStaffAppDemo: () {},
            onOpenScapes: () {},
            onOpenWalletconnectAuth: () {},
            onOpenCameraGallery: () {},
            onOpenCaseStudyDemo: () {
              caseStudyTapped = true;
            },
            onOpenIapDemo: () {},
            onOpenAiDecisionDemo: () {},
            onOpenOnlineTherapyDemo: () {},
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('example-case-study-demo-button')),
      );
      await tester.pump();

      expect(caseStudyTapped, isTrue);
    });
  });
}
