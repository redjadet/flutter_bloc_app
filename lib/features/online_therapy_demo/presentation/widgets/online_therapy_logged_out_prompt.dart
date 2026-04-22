import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class OnlineTherapyLoggedOutPrompt extends StatelessWidget {
  const OnlineTherapyLoggedOutPrompt({super.key});

  @override
  Widget build(final BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'You are logged out.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text('Go back to the landing screen to sign in.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.goNamed(AppRoutes.onlineTherapyDemo),
            child: const Text('Go to landing'),
          ),
        ],
      ),
    ),
  );
}

// eof
// end
//
