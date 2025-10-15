import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:go_router/go_router.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key, FirebaseAuth? auth}) : _auth = auth;

  final FirebaseAuth? _auth;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool firebaseReady = Firebase.apps.isNotEmpty || _auth != null;
    final FirebaseAuth? auth = firebaseReady
        ? (_auth ?? FirebaseAuth.instance)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.accountSectionTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapS),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UI.cardPadH,
              vertical: UI.cardPadV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!firebaseReady)
                  Text(l10n.accountSignedOutLabel)
                else
                  StreamBuilder<User?>(
                    stream: auth!.authStateChanges(),
                    builder: (context, snapshot) {
                      final User? user = snapshot.data;
                      if (user == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(l10n.accountSignedOutLabel),
                            SizedBox(height: UI.gapM),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
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
                            SizedBox(height: UI.gapS),
                            Text(
                              l10n.accountGuestDescription,
                              style: theme.textTheme.bodySmall,
                            ),
                            SizedBox(height: UI.gapM),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => context.go(AppRoutes.authPath),
                                child: Text(l10n.accountUpgradeButton),
                              ),
                            ),
                            SizedBox(height: UI.gapS),
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
                            SizedBox(height: UI.gapS),
                            Text(email, style: theme.textTheme.bodySmall),
                          ],
                          SizedBox(height: UI.gapM),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: () =>
                                  context.push(AppRoutes.profilePath),
                              child: Text(l10n.accountManageButton),
                            ),
                          ),
                          SizedBox(height: UI.gapS),
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
        ),
      ],
    );
  }
}
