import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
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
      appBar: AppBar(title: Text(l10n.examplePageTitle)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(UI.gapL),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UI.radiusM),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: UI.cardPadH,
                vertical: UI.cardPadV,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(UI.radiusM),
                    child: FancyShimmerImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
                      height: 180,
                      width: double.infinity,
                      boxFit: BoxFit.cover,
                      shimmerBaseColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shimmerHighlightColor: Theme.of(
                        context,
                      ).colorScheme.surface,
                    ),
                  ),
                  SizedBox(height: UI.gapL),
                  Icon(
                    Icons.explore,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: UI.gapM),
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
        ),
      ),
    );
  }
}
