import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/account_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AccountSection shows signed out label when auth unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(const AccountSection()));
    expect(
      find.text(AppLocalizationsEn().accountSignedOutLabel),
      findsOneWidget,
    );
  });

  testWidgets('AccountSection shows sign-in button when no user', (
    WidgetTester tester,
  ) async {
    final AuthRepository authRepository = _FakeAuthRepository(
      authStateChanges: Stream<AuthUser?>.value(null),
    );
    await tester.pumpWidget(
      _wrap(AccountSection(authRepository: authRepository)),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().accountSignInButton), findsOneWidget);
  });

  testWidgets(
    'AccountSection waits for first auth event before showing signed-out UI',
    (WidgetTester tester) async {
      final StreamController<AuthUser?> authStreamController =
          StreamController<AuthUser?>();
      addTearDown(authStreamController.close);
      final AuthRepository authRepository = _DelayedAuthRepository(
        authStreamController,
      );

      await tester.pumpWidget(
        _wrap(AccountSection(authRepository: authRepository)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(AppLocalizationsEn().accountSignInButton), findsNothing);

      authStreamController.add(
        const AuthUser(
          id: 'delayed-user',
          email: 'delayed@example.com',
          displayName: 'Delayed User',
          isAnonymous: false,
        ),
      );
      await tester.pump();

      expect(
        find.text(AppLocalizationsEn().accountSignedInAs('Delayed User')),
        findsOneWidget,
      );
    },
  );

  testWidgets('AccountSection handles guest users', (
    WidgetTester tester,
  ) async {
    final AuthRepository authRepository = _FakeAuthRepository(
      currentUser: const AuthUser(id: 'guest', isAnonymous: true),
      authStateChanges: Stream<AuthUser?>.value(
        const AuthUser(id: 'guest', isAnonymous: true),
      ),
    );
    await tester.pumpWidget(
      _wrap(AccountSection(authRepository: authRepository)),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().accountGuestLabel), findsOneWidget);
    expect(
      find.text(AppLocalizationsEn().accountUpgradeButton),
      findsOneWidget,
    );
  });

  testWidgets('AccountSection shows manage buttons for signed in users', (
    WidgetTester tester,
  ) async {
    final AuthRepository authRepository = _FakeAuthRepository(
      currentUser: const AuthUser(
        id: 'abc',
        email: 'user@example.com',
        displayName: 'Test User',
        isAnonymous: false,
      ),
      authStateChanges: Stream<AuthUser?>.value(
        const AuthUser(
          id: 'abc',
          email: 'user@example.com',
          displayName: 'Test User',
          isAnonymous: false,
        ),
      ),
    );
    await tester.pumpWidget(
      _wrap(AccountSection(authRepository: authRepository)),
    );
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().accountSignedInAs('Test User')),
      findsOneWidget,
    );
    expect(find.text(AppLocalizationsEn().accountManageButton), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.currentUser, required this.authStateChanges});

  @override
  final AuthUser? currentUser;

  @override
  final Stream<AuthUser?> authStateChanges;
}

class _DelayedAuthRepository implements AuthRepository {
  _DelayedAuthRepository(this._controller);

  final StreamController<AuthUser?> _controller;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;
}
