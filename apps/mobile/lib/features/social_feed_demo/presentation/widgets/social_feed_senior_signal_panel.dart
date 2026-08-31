import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SocialFeedSeniorSignalPanel extends StatelessWidget {
  const SocialFeedSeniorSignalPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> steps = <String>[
      l10n.socialFeedDemoSignalStep1,
      l10n.socialFeedDemoSignalStep2,
      l10n.socialFeedDemoSignalStep3,
      l10n.socialFeedDemoSignalStep4,
      l10n.socialFeedDemoSignalStep5,
    ];
    return Card(
      key: const ValueKey('social-feed-senior-signal-panel'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.socialFeedDemoSeniorSignalTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('${i + 1}. ${steps[i]}'),
              ),
          ],
        ),
      ),
    );
  }
}
