import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('SignInPage guest flow works without Firebase initialization', (
    WidgetTester tester,
  ) async {
    expect(Firebase.apps, isEmpty);

    final GoRouter router = GoRouter(
      initialLocation: '/sign-in',
      routes: <GoRoute>[
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: AppRoutes.counterPath,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(signInGuestButtonKey));
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.fullPath,
      AppRoutes.counterPath,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'SignInPage renders fallback content when Firebase is unavailable',
    (WidgetTester tester) async {
      final MockFirebaseAuth mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInPage(auth: mockAuth),
        ),
      );
      await tester.pump();

      expect(
        find.text(AppLocalizationsEn().anonymousSignInButton),
        findsOneWidget,
      );
      expect(
        find.text(AppLocalizationsEn().anonymousSignInDescription),
        findsOneWidget,
      );
    },
  );

  testWidgets('SignInPage anonymous sign-in navigates to counter', (
    WidgetTester tester,
  ) async {
    final MockFirebaseAuth mockAuth = MockFirebaseAuth();
    final GoRouter router = GoRouter(
      initialLocation: '/sign-in',
      routes: <GoRoute>[
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => SignInPage(auth: mockAuth),
        ),
        GoRoute(
          path: AppRoutes.counterPath,
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(signInGuestButtonKey));
    await tester.pumpAndSettle();

    expect(mockAuth.currentUser, isNotNull);
    expect(mockAuth.currentUser!.isAnonymous, isTrue);
  });

  testWidgets('SignInPage anonymous sign-in honors redirect path', (
    WidgetTester tester,
  ) async {
    final MockFirebaseAuth mockAuth = MockFirebaseAuth();
    final GoRouter router = GoRouter(
      initialLocation: '/sign-in?redirect=%2Fprofile',
      routes: <GoRoute>[
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => SignInPage(
            auth: mockAuth,
            redirectAfterLogin: state.uri.queryParameters['redirect'],
          ),
        ),
        GoRoute(
          path: AppRoutes.counterPath,
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: AppRoutes.profilePath,
          builder: (context, state) => const Scaffold(body: Text('Profile')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(signInGuestButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(mockAuth.currentUser, isNotNull);
  });

  testWidgets('SignInPage shows friendly error when anonymous sign-in fails', (
    WidgetTester tester,
  ) async {
    final _ThrowingFirebaseAuth mockAuth = _ThrowingFirebaseAuth(
      FirebaseAuthException(code: 'operation-not-allowed'),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SignInPage(auth: mockAuth)),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(signInGuestButtonKey));
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().authErrorOperationNotAllowed),
      findsOneWidget,
    );
  });

  testWidgets('SignInPage surfaces generic message for unknown errors', (
    WidgetTester tester,
  ) async {
    final _ThrowingFirebaseAuth mockAuth = _ThrowingFirebaseAuth(
      Exception('network down'),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SignInPage(auth: mockAuth)),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(signInGuestButtonKey));
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().anonymousSignInFailed),
      findsOneWidget,
    );
  });

  testWidgets(
    'SignInPage anonymous sign-in error does not throw without outer Scaffold',
    (WidgetTester tester) async {
      final _ThrowingFirebaseAuth mockAuth = _ThrowingFirebaseAuth(
        Exception('network down'),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SignInPage(auth: mockAuth),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(signInGuestButtonKey));
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}

class _ThrowingFirebaseAuth extends MockFirebaseAuth {
  _ThrowingFirebaseAuth(this.error);

  final Object error;

  @override
  Future<UserCredential> signInAnonymously() {
    if (error is FirebaseAuthException) {
      throw error as FirebaseAuthException;
    }
    throw error;
  }
}
