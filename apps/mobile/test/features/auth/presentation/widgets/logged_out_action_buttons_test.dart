import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/presentation/widgets/logged_out_action_buttons.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/layout_overflow_expectations.dart';

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

    testWidgets(
      'applies verticalScale to ResponsiveDualCtaRow height at wide width',
      (tester) async {
        const scale = 0.5;
        const verticalScale = 0.75;
        await tester.pumpWidget(
          buildSubject(scale: scale, verticalScale: verticalScale),
        );
        await tester.pump();

        final Finder dualCta = find.descendant(
          of: find.byType(LoggedOutActionButtons),
          matching: find.byType(ResponsiveDualCtaRow),
        );
        expect(dualCta, findsOneWidget);

        expect(
          find.descendant(of: dualCta, matching: find.byType(Row)),
          findsOneWidget,
        );

        final double expectedHeight = 52 * verticalScale;
        final Finder heightBox = find.descendant(
          of: dualCta,
          matching: find.byWidgetPredicate(
            (final Widget widget) =>
                widget is SizedBox &&
                widget.height == expectedHeight &&
                widget.child is Row,
          ),
        );
        expect(heightBox, findsOneWidget);
      },
    );

    testWidgets('uses ResponsiveDualCtaRow horizontal layout at wide width', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('stacks vertically without overflow below 360dp width', (
      tester,
    ) async {
      final capture = startLayoutOverflowCapture();
      addTearDown(capture.dispose);

      final previousPhysicalSize = tester.view.physicalSize;
      final previousDevicePixelRatio = tester.view.devicePixelRatio;
      addTearDown(() {
        tester.view.physicalSize = previousPhysicalSize;
        tester.view.devicePixelRatio = previousDevicePixelRatio;
      });
      tester.view.physicalSize = const Size(320, 812);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp.router(
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
                builder: (context, state) => const Scaffold(
                  body: LoggedOutActionButtons(scale: 1, verticalScale: 1),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expectNoRenderOverflows(capture.errors);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
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
