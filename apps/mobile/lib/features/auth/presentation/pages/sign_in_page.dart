import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as firebase_ui_google;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/utils/context_utils.dart';
import 'package:flutter_bloc_app/app/utils/error_handling.dart';
import 'package:flutter_bloc_app/features/auth/auth.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

export 'package:flutter_bloc_app/features/auth/presentation/widgets/auth_error_message.dart';

part 'sign_in_page.part.dart';

@visibleForTesting
const Key signInGuestButtonKey = Key('sign_in_guest_button');

/// Sign-in page that hosts the FirebaseUI Auth drop-in experience.
class SignInPage extends StatelessWidget {
  const SignInPage({
    super.key,
    this._auth,
    this.authRepository,
    this.redirectAfterLogin,
    this.providersOverride,
    firebase_ui_google.GoogleProvider? Function()? googleProviderFactory,
  }) : _googleProviderFactory =
           googleProviderFactory ?? maybeCreateGoogleProvider;

  final FirebaseAuth? _auth;
  final AuthRepository? authRepository;
  final String? redirectAfterLogin;
  @visibleForTesting
  final List<firebase_ui.AuthProvider>? providersOverride;
  final firebase_ui_google.GoogleProvider? Function() _googleProviderFactory;

  @visibleForTesting
  static List<firebase_ui.AuthProvider> prepareProviders({
    required FirebaseAuth auth,
    required firebase_ui_google.GoogleProvider? Function()
    googleProviderFactory,
    List<firebase_ui.AuthProvider>? override,
  }) => buildAuthProviders(
    auth: auth,
    override: override,
    googleProviderFactory: googleProviderFactory,
  );

  @visibleForTesting
  static bool get shouldUseMacOsDebugGuestOnlyAuth =>
      !kIsWeb && !kReleaseMode && defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final FirebaseAuth? auth = switch (_auth) {
      final FirebaseAuth injectedAuth => injectedAuth,
      _ when Firebase.apps.isNotEmpty => FirebaseAuth.instance,
      _ => null,
    };
    final bool upgradingAnonymous = auth?.currentUser?.isAnonymous ?? false;

    final bool canUseFirebaseUISignIn =
        !shouldUseMacOsDebugGuestOnlyAuth &&
        auth != null &&
        (providersOverride != null || Firebase.apps.isNotEmpty);

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

    void showAuthError(Object error) =>
        _showAuthError(context: context, l10n: l10n, error: error);

    String postAuthPath() =>
        _postAuthPath(redirectAfterLogin: redirectAfterLogin);

    Future<void> signInAnonymously() => _signInAnonymously(
      context: context,
      l10n: l10n,
      auth: auth,
      repository: authRepository,
      showAuthError: showAuthError,
      postAuthPath: postAuthPath,
    );

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
      headerBuilder: (context, constraints, _) => Padding(
        padding: EdgeInsets.only(
          top: context.responsiveGapL * 2,
          bottom: context.responsiveGapL,
        ),
        child: Text(
          l10n.appTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
      ),
      subtitleBuilder: upgradingAnonymous
          ? (context, action) => Padding(
              padding: EdgeInsets.only(bottom: context.responsiveGapL),
              child: Text(
                l10n.anonymousUpgradeHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            )
          : null,
      footerBuilder: (context, action) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: context.responsiveGapL),
          Text(
            l10n.anonymousSignInDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: context.responsiveGapM),
          SizedBox(
            width: double.infinity,
            child: PlatformAdaptive.filledButton(
              key: signInGuestButtonKey,
              context: context,
              onPressed: signInAnonymously,
              child: Text(l10n.anonymousSignInButton),
            ),
          ),
        ],
      ),
      actions: <firebase_ui.FirebaseUIAction>[
        firebase_ui.AuthStateChangeAction<firebase_ui.SignedIn>((
          context,
          state,
        ) {
          context.go(postAuthPath());
        }),
        firebase_ui.AuthStateChangeAction<firebase_ui.UserCreated>((
          context,
          state,
        ) {
          context.go(postAuthPath());
        }),
        firebase_ui.AuthStateChangeAction<firebase_ui.CredentialLinked>((
          context,
          state,
        ) {
          context.go(postAuthPath());
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
