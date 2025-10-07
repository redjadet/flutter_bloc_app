// coverage:ignore-file - integrates tightly with FirebaseUI widgets.
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// High-level profile page backed by FirebaseUI's [ProfileScreen].
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ProfileScreen(
      appBar: AppBar(title: Text(l10n.profilePageTitle)),
      actions: <FirebaseUIAction>[
        SignedOutAction((context) => context.go(AppRoutes.authPath)),
      ],
    );
  }
}
