import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String authErrorMessage(
  final AppLocalizations l10n,
  final FirebaseAuthException error,
) => switch (error.code) {
  'invalid-email' => l10n.authErrorInvalidEmail,
  'user-disabled' => l10n.authErrorUserDisabled,
  'user-not-found' => l10n.authErrorUserNotFound,
  'wrong-password' => l10n.authErrorWrongPassword,
  'email-already-in-use' => l10n.authErrorEmailInUse,
  'operation-not-allowed' => l10n.authErrorOperationNotAllowed,
  'weak-password' => l10n.authErrorWeakPassword,
  'requires-recent-login' => l10n.authErrorRequiresRecentLogin,
  'credential-already-in-use' ||
  'account-exists-with-different-credential' => l10n.authErrorCredentialInUse,
  'invalid-credential' ||
  'invalid-verification-code' ||
  'invalid-verification-id' => l10n.authErrorInvalidCredential,
  'network-request-failed' => l10n.authErrorNetworkRequestFailed,
  'too-many-requests' => l10n.authErrorTooManyRequests,
  _ => l10n.authErrorGeneric,
};
