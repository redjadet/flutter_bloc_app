import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as firebase_ui_google;
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/auth.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

export 'package:flutter_bloc_app/features/auth/presentation/helpers/auth_error_message.dart';

@visibleForTesting
const Key signInGuestButtonKey = Key('sign_in_guest_button');

/// Sign-in page that hosts the FirebaseUI Auth drop-in experience.
class SignInPage extends StatelessWidget {
  const SignInPage({
    super.key,
    FirebaseAuth? auth,
    this.providersOverride,
    firebase_ui_google.GoogleProvider? Function()? googleProviderFactory,
  }) : _auth = auth,
       _googleProviderFactory =
           googleProviderFactory ?? maybeCreateGoogleProvider;

  final FirebaseAuth? _auth;
  @visibleForTesting
  final List<firebase_ui.AuthProvider>? providersOverride;
  final firebase_ui_google.GoogleProvider? Function() _googleProviderFactory;

  @visibleForTesting
  static List<firebase_ui.AuthProvider> prepareProviders({
    required FirebaseAuth auth,
    List<firebase_ui.AuthProvider>? override,
    required firebase_ui_google.GoogleProvider? Function()
    googleProviderFactory,
  }) => buildAuthProviders(
    auth: auth,
    override: override,
    googleProviderFactory: googleProviderFactory,
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final FirebaseAuth auth = _auth ?? FirebaseAuth.instance;
    final bool upgradingAnonymous = auth.currentUser?.isAnonymous ?? false;

    final bool canUseFirebaseUISignIn =
        providersOverride != null || Firebase.apps.isNotEmpty;

    late final List<firebase_ui.AuthProvider> providers;
    if (canUseFirebaseUISignIn) {
      providers = prepareProviders(
        auth: auth,
        override: providersOverride,
        googleProviderFactory: _googleProviderFactory,
      );
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
      return FallbackSignInContent(
        l10n: l10n,
        theme: theme,
        upgradingAnonymous: upgradingAnonymous,
        signInGuestButtonKey: signInGuestButtonKey,
        signInAnonymously: signInAnonymously,
      );
    }

    // Rendering relies on FirebaseUI internals; exclude from coverage to keep
    // unit tests focused on data-path logic.
    // coverage:ignore-start
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
    // coverage:ignore-end
  }
}
