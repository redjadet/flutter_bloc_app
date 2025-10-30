// coverage:ignore-file - integrates tightly with FirebaseUI widgets.
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/widgets/root_aware_back_button.dart';
import 'package:go_router/go_router.dart';

/// High-level profile page backed by FirebaseUI's [ProfileScreen].
class AuthProfilePage extends StatelessWidget {
  const AuthProfilePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    return ProfileScreen(
      appBar: AppBar(
        leading: RootAwareBackButton(homeTooltip: l10n.homeTitle),
        title: Text(l10n.profilePageTitle),
      ),
      actions: <FirebaseUIAction>[
        SignedOutAction((final context) => context.go(AppRoutes.authPath)),
      ],
    );
  }
}
