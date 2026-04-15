part of 'supabase_auth_page.dart';

/// Shown when Supabase is not configured.
class SupabaseAuthNotConfiguredCard extends StatelessWidget {
  const SupabaseAuthNotConfiguredCard({
    required this.theme,
    required this.colors,
    required this.l10n,
    super.key,
  });

  final ThemeData theme;
  final ColorScheme colors;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    return CommonCard(
      color: colors.surfaceContainerHighest,
      elevation: 0,
      margin: EdgeInsets.zero,
      padding: context.responsiveCardPaddingInsets,
      child: Text(
        l10n.supabaseAuthNotConfigured,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Error message card with dismiss and optional child content below.
class SupabaseAuthErrorSection extends StatelessWidget {
  const SupabaseAuthErrorSection({
    required this.message,
    required this.theme,
    required this.colors,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  final String message;
  final ThemeData theme;
  final ColorScheme colors;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final double iconSize = math.min(context.responsiveIconSize, 28);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonCard(
          color: colors.errorContainer,
          elevation: 0,
          margin: EdgeInsets.zero,
          padding: context.responsiveCardPaddingInsets,
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: colors.onErrorContainer,
                size: iconSize,
              ),
              SizedBox(width: context.responsiveHorizontalGapM),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: colors.onErrorContainer,
                  size: iconSize,
                ),
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveGapM),
        child,
      ],
    );
  }
}

/// Signed-in state: user info and sign-out button.
class SupabaseAuthAuthenticatedSection extends StatelessWidget {
  const SupabaseAuthAuthenticatedSection({
    required this.user,
    required this.theme,
    required this.colors,
    required this.l10n,
    required this.onSignOut,
    super.key,
  });

  final AuthUser user;
  final ThemeData theme;
  final ColorScheme colors;
  final AppLocalizations l10n;
  final VoidCallback onSignOut;

  @override
  Widget build(final BuildContext context) {
    final double iconSize = math.min(context.responsiveIconSize, 28);
    final displayEmail = user.email ?? user.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonCard(
          color: colors.primaryContainer,
          elevation: 0,
          margin: EdgeInsets.zero,
          padding: context.responsiveCardPaddingInsets,
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: colors.onPrimaryContainer,
                size: iconSize,
              ),
              SizedBox(width: context.responsiveHorizontalGapM),
              Expanded(
                child: Text(
                  l10n.supabaseAuthSignedInAs(displayEmail),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveGapL),
        PlatformAdaptive.filledButton(
          context: context,
          onPressed: onSignOut,
          child: Text(l10n.supabaseAuthSignOut),
        ),
      ],
    );
  }
}

/// Sign-in/sign-up form: email, password, actions, optional display name.
class SupabaseAuthSignInForm extends StatelessWidget {
  const SupabaseAuthSignInForm({
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
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController displayNameController;
  final bool canSubmit;
  final VoidCallback onFieldsChanged;
  final void Function(String email, String password) onSignIn;
  final void Function(
    String email,
    String password,
    String? displayName,
  )
  onSignUp;
  final ThemeData theme;
  final ColorScheme colors;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.supabaseAuthSignIn,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveGapM),
        CommonFormField(
          controller: emailController,
          labelText: l10n.supabaseAuthEmailLabel,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onFieldsChanged(),
        ),
        SizedBox(height: context.responsiveGapM),
        CommonFormField(
          controller: passwordController,
          labelText: l10n.supabaseAuthPasswordLabel,
          helperText: l10n.supabaseAuthPasswordMinLength,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => onFieldsChanged(),
        ),
        SizedBox(height: context.responsiveGapL),
        Row(
          children: [
            Expanded(
              child: PlatformAdaptive.filledButton(
                context: context,
                onPressed: canSubmit
                    ? () => onSignIn(
                        emailController.text.trim(),
                        passwordController.text,
                      )
                    : null,
                child: Text(l10n.supabaseAuthSignIn),
              ),
            ),
            SizedBox(width: context.responsiveHorizontalGapM),
            Expanded(
              child: PlatformAdaptive.outlinedButton(
                context: context,
                onPressed: canSubmit
                    ? () => onSignUp(
                        emailController.text.trim(),
                        passwordController.text,
                        displayNameController.text.trim().isEmpty
                            ? null
                            : displayNameController.text.trim(),
                      )
                    : null,
                child: Text(l10n.supabaseAuthSignUp),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveGapL),
        Text(
          l10n.supabaseAuthDisplayNameLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: context.responsiveGapS),
        CommonFormField(
          controller: displayNameController,
          labelText: l10n.supabaseAuthDisplayNameLabel,
          textInputAction: TextInputAction.done,
          onChanged: (_) => onFieldsChanged(),
        ),
      ],
    );
  }
}
