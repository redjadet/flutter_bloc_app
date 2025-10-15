import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
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
