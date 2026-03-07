import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_cubit.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';
import 'package:flutter_bloc_app/shared/widgets/common_form_field.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:flutter_bloc_app/shared/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/shared/widgets/type_safe_bloc_selector.dart';

/// Page for Supabase authentication (sign in, sign up, sign out).
///
/// Shown when Supabase is not configured: a message and no forms.
/// Otherwise shows auth state and email/password forms.
class SupabaseAuthPage extends StatefulWidget {
  const SupabaseAuthPage({super.key});

  @override
  State<SupabaseAuthPage> createState() => _SupabaseAuthPageState();
}

class _SupabaseAuthPageState extends State<SupabaseAuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  static const int _minPasswordLength = 6;

  bool get _canSubmitCredentials {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    return email.isNotEmpty &&
        password.isNotEmpty &&
        password.length >= _minPasswordLength;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.supabaseAuthTitle,
      body: TypeSafeBlocBuilder<SupabaseAuthCubit, SupabaseAuthState>(
        builder: (final context, final state) {
          return SingleChildScrollView(
            padding: context.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.responsiveGapL),
                _buildContent(context, state, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    final BuildContext context,
    final SupabaseAuthState state,
    final AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => Center(
        child: Padding(
          padding: context.responsiveCardPaddingInsets,
          child: const CommonLoadingWidget(),
        ),
      ),
      authenticated: (final user) => _buildAuthenticated(
        context,
        user,
        theme,
        colors,
        l10n,
      ),
      unauthenticated: () => _buildUnauthenticated(
        context,
        theme,
        colors,
        l10n,
      ),
      error: (final message) => _buildError(
        context,
        message,
        theme,
        colors,
        l10n,
      ),
      notConfigured: () => _buildNotConfigured(context, theme, colors, l10n),
    );
  }

  Widget _buildNotConfigured(
    final BuildContext context,
    final ThemeData theme,
    final ColorScheme colors,
    final AppLocalizations l10n,
  ) {
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

  Widget _buildError(
    final BuildContext context,
    final String message,
    final ThemeData theme,
    final ColorScheme colors,
    final AppLocalizations l10n,
  ) {
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
                size: context.responsiveIconSize,
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
                  size: context.responsiveIconSize,
                ),
                onPressed: () =>
                    context.cubit<SupabaseAuthCubit>().clearError(),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveGapM),
        _buildUnauthenticated(context, theme, colors, l10n),
      ],
    );
  }

  Widget _buildAuthenticated(
    final BuildContext context,
    final AuthUser user,
    final ThemeData theme,
    final ColorScheme colors,
    final AppLocalizations l10n,
  ) {
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
                size: context.responsiveIconSize,
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
          onPressed: () =>
              unawaited(context.cubit<SupabaseAuthCubit>().signOut()),
          child: Text(l10n.supabaseAuthSignOut),
        ),
      ],
    );
  }

  Widget _buildUnauthenticated(
    final BuildContext context,
    final ThemeData theme,
    final ColorScheme colors,
    final AppLocalizations l10n,
  ) {
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
          controller: _emailController,
          labelText: l10n.supabaseAuthEmailLabel,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: context.responsiveGapM),
        CommonFormField(
          controller: _passwordController,
          labelText: l10n.supabaseAuthPasswordLabel,
          helperText: l10n.supabaseAuthPasswordMinLength,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: context.responsiveGapL),
        Row(
          children: [
            Expanded(
              child: PlatformAdaptive.filledButton(
                context: context,
                onPressed: _canSubmitCredentials
                    ? () {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;
                        unawaited(
                          context.cubit<SupabaseAuthCubit>().signIn(
                            email: email,
                            password: password,
                          ),
                        );
                      }
                    : null,
                child: Text(l10n.supabaseAuthSignIn),
              ),
            ),
            SizedBox(width: context.responsiveHorizontalGapM),
            Expanded(
              child: PlatformAdaptive.outlinedButton(
                context: context,
                onPressed: _canSubmitCredentials
                    ? () {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;
                        final displayName =
                            _displayNameController.text.trim().isEmpty
                            ? null
                            : _displayNameController.text.trim();
                        unawaited(
                          context.cubit<SupabaseAuthCubit>().signUp(
                            email: email,
                            password: password,
                            displayName: displayName,
                          ),
                        );
                      }
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
          controller: _displayNameController,
          labelText: l10n.supabaseAuthDisplayNameLabel,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
