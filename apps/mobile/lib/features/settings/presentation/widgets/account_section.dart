import 'package:auth/auth.dart';
import 'package:design_system/design_system.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:go_router/go_router.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AuthRepository? auth = authRepository;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.accountSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: context.responsiveGapS),
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (auth == null)
                Text(l10n.accountSignedOutLabel)
              else
                StreamBuilder<AuthUser?>(
                  initialData: auth.currentUser,
                  stream: auth.authStateChanges,
                  builder: (final context, final snapshot) {
                    final AuthUser? user = snapshot.data ?? auth.currentUser;
                    final bool waitingForFirstAuthEvent =
                        snapshot.connectionState == ConnectionState.waiting &&
                        user == null;

                    if (waitingForFirstAuthEvent) {
                      return const CommonLoadingWidget();
                    }

                    if (user == null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(l10n.accountSignedOutLabel),
                          SizedBox(height: context.responsiveGapM),
                          SizedBox(
                            width: double.infinity,
                            child: PlatformAdaptive.filledButton(
                              context: context,
                              onPressed: () => context.go(AppRoutes.authPath),
                              child: Text(l10n.accountSignInButton),
                            ),
                          ),
                        ],
                      );
                    }

                    final String displayName = _resolveDisplayName(user);
                    final String? email = user.email?.trim();

                    if (user.isAnonymous) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.accountGuestLabel,
                            style: theme.textTheme.bodyMedium,
                          ),
                          SizedBox(height: context.responsiveGapS),
                          Text(
                            l10n.accountGuestDescription,
                            style: theme.textTheme.bodySmall,
                          ),
                          SizedBox(height: context.responsiveGapM),
                          SizedBox(
                            width: double.infinity,
                            child: PlatformAdaptive.filledButton(
                              context: context,
                              onPressed: () =>
                                  context.go(AppRoutes.authUpgradePath()),
                              child: Text(l10n.accountUpgradeButton),
                            ),
                          ),
                          SizedBox(height: context.responsiveGapS),
                          const SizedBox(
                            width: double.infinity,
                            child: SignOutButton(
                              variant: ButtonVariant.outlined,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.accountSignedInAs(displayName),
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (email != null && email.isNotEmpty) ...<Widget>[
                          SizedBox(height: context.responsiveGapS),
                          Text(email, style: theme.textTheme.bodySmall),
                        ],
                        SizedBox(height: context.responsiveGapM),
                        SizedBox(
                          width: double.infinity,
                          child: PlatformAdaptive.filledButton(
                            context: context,
                            onPressed: () =>
                                context.push(AppRoutes.manageAccountPath),
                            child: Text(l10n.accountManageButton),
                          ),
                        ),
                        SizedBox(height: context.responsiveGapS),
                        const SizedBox(
                          width: double.infinity,
                          child: SignOutButton(
                            variant: ButtonVariant.outlined,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _resolveDisplayName(final AuthUser user) {
    final String? trimmedName = user.displayName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }
    return user.email ?? user.id;
  }
}
