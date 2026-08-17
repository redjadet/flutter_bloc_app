// coverage:ignore-file - integrates tightly with FirebaseUI widgets.
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart' as sdk;
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/widgets/root_aware_back_button.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// High-level profile page backed by FirebaseUI's [ProfileScreen].
class AuthProfilePage extends StatelessWidget {
  const AuthProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ProfileScreen(
      appBar: sdk.AppBar(
        leading: RootAwareBackButton(homeTooltip: l10n.homeTitle),
        title: Text(l10n.profilePageTitle),
      ),
      actions: <FirebaseUIAction>[
        SignedOutAction((context) => context.go(AppRoutes.authPath)),
      ],
    );
  }
}
