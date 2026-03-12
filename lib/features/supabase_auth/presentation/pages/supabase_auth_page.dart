import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
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
import 'package:go_router/go_router.dart';

part 'supabase_auth_page_sections.dart';

/// Page for Supabase authentication (sign in, sign up, sign out).
///
/// Shown when Supabase is not configured: a message and no forms.
/// Otherwise shows auth state and email/password forms.
/// [redirectAfterLogin] if set, navigates to that path after successful sign-in.
class SupabaseAuthPage extends StatefulWidget {
  const SupabaseAuthPage({super.key, this.redirectAfterLogin});

  /// Path to navigate to after successful sign-in (e.g. from auth-gated routes).
  final String? redirectAfterLogin;

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
    final redirectAfterLogin = widget.redirectAfterLogin;
    return CommonPageLayout(
      title: l10n.supabaseAuthTitle,
      body: TypeSafeBlocListener<SupabaseAuthCubit, SupabaseAuthState>(
        listenWhen: (final prev, final curr) =>
            curr.mapOrNull(authenticated: (_) => true) == true &&
            prev.mapOrNull(authenticated: (_) => true) != true,
        listener: (final context, final state) {
          if (redirectAfterLogin case final String redirectPath
              when AppRoutes.isSafeRedirectPath(redirectPath)) {
            if (!context.mounted) return;
            context.go(redirectPath);
          }
        },
        child: TypeSafeBlocBuilder<SupabaseAuthCubit, SupabaseAuthState>(
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
    final cubit = context.cubit<SupabaseAuthCubit>();

    return state.when(
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
        onSignOut: () => unawaited(cubit.signOut()),
      ),
      unauthenticated: () => SupabaseAuthSignInForm(
        emailController: _emailController,
        passwordController: _passwordController,
        displayNameController: _displayNameController,
        canSubmit: _canSubmitCredentials,
        onFieldsChanged: () => setState(() {}),
        onSignIn: (final email, final password) =>
            unawaited(cubit.signIn(email: email, password: password)),
        onSignUp: (final email, final password, final displayName) => unawaited(
          cubit.signUp(
            email: email,
            password: password,
            displayName: displayName,
          ),
        ),
        theme: theme,
        colors: colors,
        l10n: l10n,
      ),
      error: (final message) => SupabaseAuthErrorSection(
        message: message,
        theme: theme,
        colors: colors,
        onDismiss: cubit.clearError,
        child: SupabaseAuthSignInForm(
          emailController: _emailController,
          passwordController: _passwordController,
          displayNameController: _displayNameController,
          canSubmit: _canSubmitCredentials,
          onFieldsChanged: () => setState(() {}),
          onSignIn: (final email, final password) =>
              unawaited(cubit.signIn(email: email, password: password)),
          onSignUp: (final email, final password, final displayName) =>
              unawaited(
                cubit.signUp(
                  email: email,
                  password: password,
                  displayName: displayName,
                ),
              ),
          theme: theme,
          colors: colors,
          l10n: l10n,
        ),
      ),
      notConfigured: () => SupabaseAuthNotConfiguredCard(
        theme: theme,
        colors: colors,
        l10n: l10n,
      ),
    );
  }
}
