import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class SocialFeedScenarioControls extends StatelessWidget {
  const SocialFeedScenarioControls({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SocialFeedCubit cubit = context.read<SocialFeedCubit>();
    final scenario = cubit.scenarioController;
    return Card(
      key: const ValueKey('social-feed-scenario-controls'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.socialFeedDemoScenarioTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SwitchListTile(
              title: Text(l10n.socialFeedDemoSimulatedOnline),
              value: scenario.isSimulatedOnline,
              onChanged: (value) {
                // side_effects_build - user gesture (switch).
                scenario.setSimulatedOnline(online: value);
                // check-ignore: side_effects_build - user gesture callback.
                unawaited(cubit.refresh());
              },
            ),
            FilledButton(
              onPressed: cubit.emitThreeNewPosts,
              child: Text(l10n.socialFeedDemoEmitNewPosts),
            ),
            OutlinedButton(
              onPressed: () async {
                final String displayName = cubit.viewer.displayName;
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.socialFeedDemoResetTitle),
                    content: Text(l10n.socialFeedDemoResetBody(displayName)),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(l10n.socialFeedDemoCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(l10n.socialFeedDemoConfirm),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) {
                  return;
                }
                if (confirmed == true) {
                  await cubit.resetCurrentViewerDemo();
                }
              },
              child: Text(l10n.socialFeedDemoReset),
            ),
          ],
        ),
      ),
    );
  }
}
