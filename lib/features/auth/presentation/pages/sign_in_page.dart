import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as firebase_ui_google;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
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

    final bool canUseFirebaseUISignIn = Firebase.apps.isNotEmpty;

    late final List<firebase_ui.AuthProvider> providers;
    if (canUseFirebaseUISignIn) {
      providers = List<firebase_ui.AuthProvider>.from(
        firebase_ui.FirebaseUIAuth.providersFor(auth.app),
      );

      if (!providers.any(
        (firebase_ui.AuthProvider provider) =>
            provider is firebase_ui.EmailAuthProvider,
      )) {
        providers.insert(0, firebase_ui.EmailAuthProvider());
      }

      if (providers.isEmpty) {
        providers.add(firebase_ui.EmailAuthProvider());
      }

      final bool hasGoogleProvider = providers.any(
        (firebase_ui.AuthProvider provider) =>
            provider is firebase_ui_google.GoogleProvider,
      );

      if (!hasGoogleProvider) {
        final firebase_ui_google.GoogleProvider? googleProvider =
            _maybeCreateGoogleProvider();
        if (googleProvider != null) {
          providers.add(googleProvider);
        }
      }
    } else {
      providers = <firebase_ui.AuthProvider>[];
    }

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
      } on Exception {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.anonymousSignInFailed)));
      }
    }

    if (!canUseFirebaseUISignIn) {
      return _FallbackSignInContent(
        l10n: l10n,
        theme: theme,
        upgradingAnonymous: upgradingAnonymous,
        signInAnonymously: signInAnonymously,
      );
    }

    return firebase_ui.SignInScreen(
      auth: auth,
      providers: providers,
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
      actions: <firebase_ui.FirebaseUIAction>[
        firebase_ui.AuthStateChangeAction<firebase_ui.SignedIn>((
          context,
          state,
        ) {
          context.go(AppRoutes.counterPath);
        }),
        firebase_ui.AuthStateChangeAction<firebase_ui.UserCreated>((
          context,
          state,
        ) {
          context.go(AppRoutes.counterPath);
        }),
        firebase_ui.AuthStateChangeAction<firebase_ui.CredentialLinked>((
          context,
          state,
        ) {
          context.go(AppRoutes.counterPath);
        }),
        firebase_ui.AuthStateChangeAction<firebase_ui.AuthFailed>((
          context,
          state,
        ) {
          showAuthError(state.exception);
        }),
      ],
    );
  }
}

class _FallbackSignInContent extends StatelessWidget {
  const _FallbackSignInContent({
    required this.l10n,
    required this.theme,
    required this.upgradingAnonymous,
    required this.signInAnonymously,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final bool upgradingAnonymous;
  final Future<void> Function() signInAnonymously;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (upgradingAnonymous)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      l10n.anonymousUpgradeHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                Text(
                  l10n.anonymousSignInDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  key: signInGuestButtonKey,
                  onPressed: signInAnonymously,
                  child: Text(l10n.anonymousSignInButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

firebase_ui_google.GoogleProvider? _maybeCreateGoogleProvider() {
  if (kIsWeb) {
    return null;
  }

  if (Firebase.apps.isEmpty) {
    return null;
  }

  try {
    final FirebaseApp app = Firebase.app();
    final FirebaseOptions options = app.options;
    final TargetPlatform platform = defaultTargetPlatform;
    if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
      return null;
    }

    final bool isIOS = platform == TargetPlatform.iOS;
    final String? platformClientId = isIOS
        ? options.iosClientId
        : options.androidClientId;
    final bool preferPlist =
        isIOS && (platformClientId?.trim().isEmpty ?? true);

    final String resolvedClientId =
        (platformClientId?.trim().isNotEmpty ?? false)
        ? platformClientId!.trim()
        : options.appId;

    return firebase_ui_google.GoogleProvider(
      clientId: resolvedClientId,
      iOSPreferPlist: preferPlist,
    );
  } on FirebaseException {
    return null;
  } on Exception {
    return null;
  }
}
