import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class CounterSyncQueueInspectorSheet extends StatelessWidget {
  const CounterSyncQueueInspectorSheet({
    required this.entries,
    required this.l10n,
    super.key,
  });

  final List<CounterSyncQueueEntry> entries;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: context.pagePadding,
        child: AppMessage(message: l10n.syncQueueInspectorEmpty),
      );
    }
    return SafeArea(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.syncQueueInspectorTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapM),
            Flexible(
              child: ListView.separated(
                itemBuilder: (itemContext, index) {
                  final CounterSyncQueueEntry entry = entries[index];
                  final String subtitle = l10n.syncQueueInspectorOperation(
                    entry.entityType,
                    entry.retryCount,
                  );
                  return KeyedSubtree(
                    key: ValueKey<String>('sync-op-${entry.id}'),
                    child: PlatformAdaptive.listTile(
                      context: itemContext,
                      title: Text(entry.id),
                      subtitle: Text(subtitle),
                    ),
                  );
                },
                separatorBuilder: (
                  itemContext,
                  _,
                ) => SizedBox(height: context.responsiveGapS),
                itemCount: entries.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
