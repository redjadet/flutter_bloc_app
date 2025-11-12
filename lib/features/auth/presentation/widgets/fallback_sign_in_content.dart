import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class FallbackSignInContent extends StatelessWidget {
  const FallbackSignInContent({
    required this.l10n,
    required this.theme,
    required this.upgradingAnonymous,
    required this.signInGuestButtonKey,
    required this.signInAnonymously,
    super.key,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final bool upgradingAnonymous;
  final Key signInGuestButtonKey;
  final Future<void> Function() signInAnonymously;

  @override
  Widget build(final BuildContext context) {
    final bool useCupertino =
        Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS;
    final Widget content = Center(
      child: Padding(
        padding: context.responsiveStatePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.appTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: context.responsiveGapL),
            if (upgradingAnonymous)
              Padding(
                padding: EdgeInsets.only(bottom: context.responsiveGapL),
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
            SizedBox(height: context.responsiveGapM),
            PlatformAdaptive.filledButton(
              key: signInGuestButtonKey,
              context: context,
              onPressed: signInAnonymously,
              child: Text(l10n.anonymousSignInButton),
            ),
          ],
        ),
      ),
    );

    final Widget safeContent = SafeArea(child: content);

    if (useCupertino) {
      return CupertinoPageScaffold(
        backgroundColor: theme.colorScheme.surface,
        child: safeContent,
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: safeContent,
    );
  }
}
