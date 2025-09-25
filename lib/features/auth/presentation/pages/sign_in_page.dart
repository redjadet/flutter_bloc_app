import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

@visibleForTesting
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

@visibleForTesting
const Key signInGuestButtonKey = Key('sign_in_guest_button');

/// Sign-in page that hosts the FirebaseUI Auth drop-in experience.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key, FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final FirebaseAuth auth = _auth ?? FirebaseAuth.instance;
    final bool upgradingAnonymous = auth.currentUser?.isAnonymous ?? false;

    void showAuthError(Object error) {
      if (!context.mounted) return;
      if (error is FirebaseAuthException) {
        final String message = authErrorMessage(l10n, error);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    }

    Future<void> signInAnonymously() async {
      try {
        await auth.signInAnonymously();
        if (!context.mounted) return;
        context.go(AppRoutes.counterPath);
      } on FirebaseAuthException catch (error) {
        showAuthError(error);
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.anonymousSignInFailed)));
      }
    }

    return SignInScreen(
      auth: auth,
      headerBuilder: (context, constraints, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 16),
          child: Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
        );
      },
      subtitleBuilder: upgradingAnonymous
          ? (context, action) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                l10n.anonymousUpgradeHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            )
          : null,
      footerBuilder: (context, action) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 24),
            Text(
              l10n.anonymousSignInDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                key: signInGuestButtonKey,
                onPressed: signInAnonymously,
                child: Text(l10n.anonymousSignInButton),
              ),
            ),
          ],
        );
      },
      actions: <FirebaseUIAction>[
        AuthStateChangeAction<SignedIn>((context, state) {
          context.go(AppRoutes.counterPath);
        }),
        AuthStateChangeAction<UserCreated>((context, state) {
          context.go(AppRoutes.counterPath);
        }),
        AuthStateChangeAction<CredentialLinked>((context, state) {
          context.go(AppRoutes.counterPath);
        }),
        AuthStateChangeAction<AuthFailed>((context, state) {
          showAuthError(state.exception);
        }),
      ],
    );
  }
}
