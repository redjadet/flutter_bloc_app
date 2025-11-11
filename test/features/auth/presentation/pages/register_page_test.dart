import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const RegisterPage(),
  );

  testWidgets('shows validation errors when submitting empty form', (
    final tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    final BuildContext pageContext = tester.element(find.byType(RegisterPage));
    final AppLocalizations l10n = AppLocalizations.of(pageContext);

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-submit-button')),
    );
    await tester.tap(find.byKey(const ValueKey('register-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.registerFullNameEmptyError), findsOneWidget);
    expect(find.text(l10n.registerEmailEmptyError), findsOneWidget);
    expect(find.text(l10n.registerPasswordEmptyError), findsOneWidget);
    expect(find.text(l10n.registerConfirmPasswordEmptyError), findsOneWidget);
    expect(find.text(l10n.registerPhoneEmptyError), findsOneWidget);
    expect(find.text(l10n.registerTermsError), findsOneWidget);
  });

  testWidgets('shows success dialog when inputs are valid', (
    final tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    final BuildContext pageContext = tester.element(find.byType(RegisterPage));
    final AppLocalizations l10n = AppLocalizations.of(pageContext);

    await tester.enterText(
      find.byKey(const ValueKey('register-full-name-field')),
      'Jane Doe',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-email-field')),
      'jane.doe@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-phone-field')),
      '5551234567',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'Password1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'Password1',
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-terms-link')),
    );
    await tester.tap(find.byKey(const ValueKey('register-terms-link')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.registerTermsAcceptButton));
    await tester.pumpAndSettle();

    final Checkbox checkbox = tester.widget<Checkbox>(
      find.byKey(const ValueKey('register-terms-checkbox')),
    );
    expect(checkbox.value, isTrue);

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-submit-button')),
    );
    await tester.tap(find.byKey(const ValueKey('register-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.registerDialogTitle), findsOneWidget);
    expect(find.text(l10n.registerDialogMessage('Jane Doe')), findsOneWidget);

    await tester.tap(find.text(l10n.registerDialogOk));
    await tester.pumpAndSettle();

    expect(find.text(l10n.registerDialogTitle), findsNothing);
  });

  testWidgets('terms dialog must be accepted from checkbox', (
    final tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    final BuildContext pageContext = tester.element(find.byType(RegisterPage));
    final AppLocalizations l10n = AppLocalizations.of(pageContext);

    final Finder checkboxFinder = find.byKey(
      const ValueKey('register-terms-checkbox'),
    );

    await tester.ensureVisible(checkboxFinder);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text(l10n.registerTermsRejectButton));
    await tester.pumpAndSettle();

    final Checkbox checkbox = tester.widget<Checkbox>(
      find.byKey(const ValueKey('register-terms-checkbox')),
    );
    expect(checkbox.value, isFalse);

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-terms-link')),
    );
    await tester.tap(find.byKey(const ValueKey('register-terms-link')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.registerTermsAcceptButton));
    await tester.pumpAndSettle();

    final Checkbox acceptedCheckbox = tester.widget<Checkbox>(
      find.byKey(const ValueKey('register-terms-checkbox')),
    );
    expect(acceptedCheckbox.value, isTrue);
  });
}
