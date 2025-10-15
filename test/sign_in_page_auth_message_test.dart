import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  String messageFor(String code) =>
      authErrorMessage(l10n, FirebaseAuthException(code: code));

  test('authErrorMessage returns friendly messages for known codes', () {
    expect(messageFor('invalid-email'), l10n.authErrorInvalidEmail);
    expect(messageFor('user-disabled'), l10n.authErrorUserDisabled);
    expect(messageFor('user-not-found'), l10n.authErrorUserNotFound);
    expect(messageFor('wrong-password'), l10n.authErrorWrongPassword);
    expect(messageFor('email-already-in-use'), l10n.authErrorEmailInUse);
    expect(
      messageFor('operation-not-allowed'),
      l10n.authErrorOperationNotAllowed,
    );
    expect(messageFor('weak-password'), l10n.authErrorWeakPassword);
    expect(
      messageFor('requires-recent-login'),
      l10n.authErrorRequiresRecentLogin,
    );
    expect(
      messageFor('credential-already-in-use'),
      l10n.authErrorCredentialInUse,
    );
    expect(
      messageFor('account-exists-with-different-credential'),
      l10n.authErrorCredentialInUse,
    );
    expect(messageFor('invalid-credential'), l10n.authErrorInvalidCredential);
    expect(
      messageFor('invalid-verification-code'),
      l10n.authErrorInvalidCredential,
    );
    expect(
      messageFor('invalid-verification-id'),
      l10n.authErrorInvalidCredential,
    );
  });

  test('authErrorMessage falls back to generic message', () {
    expect(messageFor('unknown-code'), l10n.authErrorGeneric);
  });
}
