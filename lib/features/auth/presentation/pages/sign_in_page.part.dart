part of 'sign_in_page.dart';

void _showAuthError({
  required final BuildContext context,
  required final AppLocalizations l10n,
  required final Object error,
}) {
  if (!context.mounted) {
    ContextUtils.logNotMounted('SignInPage.showAuthError');
    return;
  }
  if (error is FirebaseAuthException) {
    if (kDebugMode) {
      AppLogger.warning(
        'Sign-in failed (${error.code}): ${error.message ?? 'no message'}',
      );
    }
    final String message = authErrorMessage(l10n, error);
    ErrorHandling.clearSnackBars(context);
    ErrorHandling.showErrorSnackBar(context, message);
  }
}

String _postAuthPath({required final String? redirectAfterLogin}) {
  final String? redirectPath = redirectAfterLogin;
  if (redirectPath case final String nonNullPath
      when AppRoutes.isSafeRedirectPath(nonNullPath)) {
    return nonNullPath;
  }
  return AppRoutes.counterPath;
}

Future<void> _signInAnonymously({
  required final BuildContext context,
  required final AppLocalizations l10n,
  required final FirebaseAuth? auth,
  required final AuthRepository? repository,
  required final void Function(Object error) showAuthError,
  required final String Function() postAuthPath,
}) async {
  if (auth == null) {
    try {
      if (repository == null) {
        if (!context.mounted) return;
        ErrorHandling.clearSnackBars(context);
        ErrorHandling.showErrorSnackBar(
          context,
          l10n.anonymousSignInFailed,
        );
        return;
      }
      await repository.signInAnonymously();
      if (!context.mounted) {
        ContextUtils.logNotMounted(
          'SignInPage.signInAnonymously.noFirebase',
        );
        return;
      }
      context.go(postAuthPath());
    } on FirebaseAuthException catch (error) {
      showAuthError(error);
    } on Exception {
      if (!context.mounted) {
        ContextUtils.logNotMounted('SignInPage.signInAnonymously.error');
        return;
      }
      ErrorHandling.clearSnackBars(context);
      ErrorHandling.showErrorSnackBar(context, l10n.anonymousSignInFailed);
    }
    return;
  }

  try {
    if (repository == null) {
      await auth.signInAnonymously();
    } else {
      await repository.signInAnonymously();
    }
    if (!context.mounted) {
      ContextUtils.logNotMounted('SignInPage.signInAnonymously');
      return;
    }
    context.go(postAuthPath());
  } on FirebaseAuthException catch (error) {
    showAuthError(error);
  } on Exception {
    if (!context.mounted) {
      ContextUtils.logNotMounted('SignInPage.signInAnonymously.error');
      return;
    }
    ErrorHandling.clearSnackBars(context);
    ErrorHandling.showErrorSnackBar(context, l10n.anonymousSignInFailed);
  }
}
