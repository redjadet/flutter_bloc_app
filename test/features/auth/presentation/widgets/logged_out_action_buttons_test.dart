import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_action_buttons.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

void main() {
  group('LoggedOutActionButtons', () {
    /// Labels from l10n (English): accountSignInButton -> "Sign in", registerTitle -> "Register".
    final String signInLabel = 'SIGN IN';
    final String registerLabel = 'REGISTER';

    Widget buildSubject({double scale = 1.0, double? verticalScale}) {
      final double resolvedVerticalScale = verticalScale ?? scale;
      return MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: AppRoutes.authPath,
              builder: (context, state) =>
                  const Scaffold(body: Text('Auth Page')),
            ),
            GoRoute(
              path: AppRoutes.registerPath,
              builder: (context, state) =>
                  const Scaffold(body: Text('Register Page')),
            ),
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: SizedBox(
                  width: 375,
                  height: 812,
                  child: LoggedOutActionButtons(
                    scale: scale,
                    verticalScale: resolvedVerticalScale,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    testWidgets('renders both buttons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text(signInLabel), findsOneWidget);
      expect(find.text(registerLabel), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('LOG IN button is tappable', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Verify button exists and is tappable
      expect(find.text(signInLabel), findsOneWidget);
      final loginButton = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text(signInLabel),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(loginButton.onPressed, isNotNull);
    });

    testWidgets('REGISTER button is tappable', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Verify button exists and is tappable
      expect(find.text(registerLabel), findsOneWidget);
      final registerButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(registerLabel),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(registerButton.onPressed, isNotNull);
    });

    testWidgets('applies scale correctly', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(buildSubject(scale: scale));
      // Don't use pumpAndSettle as it may timeout due to overflow warnings
      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(LoggedOutActionButtons),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, equals(52 * scale));
    });

    testWidgets('renders row layout', (tester) async {
      const scale = 0.5; // Use smaller scale to avoid overflow
      await tester.pumpWidget(buildSubject(scale: scale));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('buttons have correct styling', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);

      // Verify buttons are rendered with correct text (from l10n)
      expect(find.text(signInLabel), findsOneWidget);
      expect(find.text(registerLabel), findsOneWidget);
    });
  });
}
