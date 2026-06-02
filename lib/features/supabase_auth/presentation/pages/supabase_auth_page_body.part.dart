part of 'supabase_auth_page.dart';

class _SupabaseAuthBody extends StatelessWidget {
  const _SupabaseAuthBody({
    required this.state,
    required this.emailController,
    required this.passwordController,
    required this.displayNameController,
    required this.canSubmit,
    required this.onFieldsChanged,
    required this.onSignIn,
    required this.onSignUp,
    required this.onSignOut,
  });

  final SupabaseAuthState state;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController displayNameController;
  final bool canSubmit;
  final VoidCallback onFieldsChanged;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final VoidCallback onSignOut;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: context.responsiveGapL),
        state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => Center(
            child: Padding(
              padding: context.responsiveCardPaddingInsets,
              child: const CommonLoadingWidget(),
            ),
          ),
          authenticated: (final user) => SupabaseAuthAuthenticatedSection(
            user: user,
            theme: theme,
            colors: colors,
            l10n: l10n,
            onSignOut: onSignOut,
          ),
          unauthenticated: () => _SupabaseAuthCredentialsSection(
            emailController: emailController,
            passwordController: passwordController,
            displayNameController: displayNameController,
            canSubmit: canSubmit,
            onFieldsChanged: onFieldsChanged,
            onSignIn: onSignIn,
            onSignUp: onSignUp,
            theme: theme,
            colors: colors,
            l10n: l10n,
          ),
          error: (final message) => _SupabaseAuthCredentialsSection(
            errorMessage: message,
            onDismissError: context.cubit<SupabaseAuthCubit>().clearError,
            emailController: emailController,
            passwordController: passwordController,
            displayNameController: displayNameController,
            canSubmit: canSubmit,
            onFieldsChanged: onFieldsChanged,
            onSignIn: onSignIn,
            onSignUp: onSignUp,
            theme: theme,
            colors: colors,
            l10n: l10n,
          ),
          notConfigured: () => SupabaseAuthNotConfiguredCard(
            theme: theme,
            colors: colors,
            l10n: l10n,
          ),
        ),
      ],
    );
  }
}

class _SupabaseAuthCredentialsSection extends StatelessWidget {
  const _SupabaseAuthCredentialsSection({
    required this.emailController,
    required this.passwordController,
    required this.displayNameController,
    required this.canSubmit,
    required this.onFieldsChanged,
    required this.onSignIn,
    required this.onSignUp,
    required this.theme,
    required this.colors,
    required this.l10n,
    this.errorMessage,
    this.onDismissError,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController displayNameController;
  final bool canSubmit;
  final VoidCallback onFieldsChanged;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final ThemeData theme;
  final ColorScheme colors;
  final AppLocalizations l10n;
  final String? errorMessage;
  final VoidCallback? onDismissError;

  @override
  Widget build(final BuildContext context) {
    final Widget form = SupabaseAuthSignInForm(
      emailController: emailController,
      passwordController: passwordController,
      displayNameController: displayNameController,
      canSubmit: canSubmit,
      onFieldsChanged: onFieldsChanged,
      onSignIn: (_, _) => onSignIn(),
      onSignUp: (_, _, final _) => onSignUp(),
      theme: theme,
      colors: colors,
      l10n: l10n,
    );

    if (errorMessage case final message?) {
      return SupabaseAuthErrorSection(
        message: message,
        theme: theme,
        colors: colors,
        onDismiss: onDismissError ?? () {},
        child: form,
      );
    }

    return form;
  }
}
