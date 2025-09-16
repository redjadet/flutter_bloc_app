import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:go_router/go_router.dart';

/// Simple example page used to demonstrate GoRouter navigation
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.examplePageTitle),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(UI.gapL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore, size: 72, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: UI.gapL),
              Text(
                l10n.examplePageDescription,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: UI.gapL),
              FilledButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.goNamed(AppRoutes.counter);
                  }
                },
                child: Text(l10n.exampleBackButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
