import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_loading_widget.dart';
import 'package:go_router/go_router.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key, final FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final bool firebaseReady = Firebase.apps.isNotEmpty || _auth != null;
    final FirebaseAuth? auth = firebaseReady
        ? (_auth ?? FirebaseAuth.instance)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.accountSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: context.responsiveGapS),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveCardPadding,
              vertical: context.responsiveGapL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!firebaseReady)
                  Text(l10n.accountSignedOutLabel)
                else if (auth case final FirebaseAuth effectiveAuth)
                  StreamBuilder<User?>(
                    initialData: effectiveAuth.currentUser,
                    stream: effectiveAuth.authStateChanges(),
                    builder: (final context, final snapshot) {
                      final User? user =
                          snapshot.data ?? effectiveAuth.currentUser;
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

                      final bool isGuest = user.isAnonymous;
                      final String? trimmedName = user.displayName?.trim();
                      String displayName = user.email ?? user.uid;
                      if (trimmedName != null && trimmedName.isNotEmpty) {
                        displayName = trimmedName;
                      }

                      final String? email = user.email?.trim();

                      if (isGuest) {
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
                                onPressed: () => context.go(AppRoutes.authPath),
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
                  )
                else
                  Text(l10n.accountSignedOutLabel),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
