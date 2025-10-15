import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String authErrorMessage(AppLocalizations l10n, FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return l10n.authErrorInvalidEmail;
    case 'user-disabled':
      return l10n.authErrorUserDisabled;
    case 'user-not-found':
      return l10n.authErrorUserNotFound;
    case 'wrong-password':
      return l10n.authErrorWrongPassword;
    case 'email-already-in-use':
      return l10n.authErrorEmailInUse;
    case 'operation-not-allowed':
      return l10n.authErrorOperationNotAllowed;
    case 'weak-password':
      return l10n.authErrorWeakPassword;
    case 'requires-recent-login':
      return l10n.authErrorRequiresRecentLogin;
    case 'credential-already-in-use':
    case 'account-exists-with-different-credential':
      return l10n.authErrorCredentialInUse;
    case 'invalid-credential':
    case 'invalid-verification-code':
    case 'invalid-verification-id':
      return l10n.authErrorInvalidCredential;
    default:
      return l10n.authErrorGeneric;
  }
}
