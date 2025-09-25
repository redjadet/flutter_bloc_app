import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignInPage', () {
    Future<void> pumpSignInPage(
      WidgetTester tester, {
      required FirebaseAuth auth,
    }) async {
      final router = GoRouter(
        initialLocation: AppRoutes.authPath,
        routes: [
          GoRoute(
            path: AppRoutes.authPath,
            builder: (context, state) => SignInPage(auth: auth),
          ),
          GoRoute(
            path: AppRoutes.counterPath,
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pump();
      addTearDown(router.dispose);
    }

    testWidgets('navigates to counter after anonymous sign-in', (tester) async {
      final mockAuth = MockFirebaseAuth();
      await pumpSignInPage(tester, auth: mockAuth);

      await tester.tap(find.byKey(signInGuestButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.isAnonymous, isTrue);
    });

    testWidgets('shows friendly message when anonymous sign-in fails', (
      tester,
    ) async {
      final mockAuth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInAnonymously, null))
          .on(mockAuth)
          .thenThrow(FirebaseAuthException(code: 'operation-not-allowed'));

      await pumpSignInPage(tester, auth: mockAuth);

      await tester.tap(find.byKey(signInGuestButtonKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(AppLocalizationsEn().authErrorOperationNotAllowed),
        findsOneWidget,
      );
      expect(mockAuth.currentUser, isNull);
    });
  });

  group('authErrorMessage', () {
    final l10n = AppLocalizationsEn();

    test('returns specific message for known code', () {
      final error = FirebaseAuthException(code: 'invalid-email');
      expect(authErrorMessage(l10n, error), l10n.authErrorInvalidEmail);
    });

    test('falls back to generic message for unknown code', () {
      final error = FirebaseAuthException(code: 'some-new-code');
      expect(authErrorMessage(l10n, error), l10n.authErrorGeneric);
    });
  });
}
