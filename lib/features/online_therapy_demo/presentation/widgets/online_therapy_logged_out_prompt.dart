import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:go_router/go_router.dart';

class OnlineTherapyLoggedOutPrompt extends StatelessWidget {
  const OnlineTherapyLoggedOutPrompt({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.onlineTherapyDemoLoggedOutTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(l10n.onlineTherapyDemoLoggedOutMessage),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.onlineTherapyDemo),
              child: Text(l10n.onlineTherapyDemoGoToLandingButton),
            ),
          ],
        ),
      ),
    );
  }
}

// eof
// end
//
