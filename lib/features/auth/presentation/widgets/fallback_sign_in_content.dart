import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class FallbackSignInContent extends StatelessWidget {
  const FallbackSignInContent({
    super.key,
    required this.l10n,
    required this.theme,
    required this.upgradingAnonymous,
    required this.signInGuestButtonKey,
    required this.signInAnonymously,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final bool upgradingAnonymous;
  final Key signInGuestButtonKey;
  final Future<void> Function() signInAnonymously;

  @override
  Widget build(final BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (upgradingAnonymous)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    l10n.anonymousUpgradeHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              Text(
                l10n.anonymousSignInDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                key: signInGuestButtonKey,
                onPressed: signInAnonymously,
                child: Text(l10n.anonymousSignInButton),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
