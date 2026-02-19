import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/account_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('AccountSection shows signed out label when Firebase missing', (
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
    final mockAuth = MockFirebaseAuth();
    await tester.pumpWidget(_wrap(AccountSection(auth: mockAuth)));
    await tester.pump();

    expect(find.text(AppLocalizationsEn().accountSignInButton), findsOneWidget);
  });

  testWidgets(
    'AccountSection waits for first auth event before showing signed-out UI',
    (WidgetTester tester) async {
      final StreamController<User?> authStreamController =
          StreamController<User?>();
      addTearDown(authStreamController.close);
      final _DelayedStreamFirebaseAuth auth = _DelayedStreamFirebaseAuth();
      final MockUser signedInUser = MockUser(
        uid: 'delayed-user',
        email: 'delayed@example.com',
        displayName: 'Delayed User',
      );

      when(() => auth.currentUser).thenReturn(null);
      when(
        () => auth.authStateChanges(),
      ).thenAnswer((_) => authStreamController.stream);

      await tester.pumpWidget(_wrap(AccountSection(auth: auth)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(AppLocalizationsEn().accountSignInButton), findsNothing);

      authStreamController.add(signedInUser);
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
    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(isAnonymous: true),
    );
    await tester.pumpWidget(_wrap(AccountSection(auth: mockAuth)));
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
    final mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'abc',
        email: 'user@example.com',
        displayName: 'Test User',
      ),
    );
    await tester.pumpWidget(_wrap(AccountSection(auth: mockAuth)));
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().accountSignedInAs('Test User')),
      findsOneWidget,
    );
    expect(find.text(AppLocalizationsEn().accountManageButton), findsOneWidget);
  });
}

class _DelayedStreamFirebaseAuth extends Mock implements FirebaseAuth {}
