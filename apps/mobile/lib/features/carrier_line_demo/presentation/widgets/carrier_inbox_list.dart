import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_inbox_item.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class CarrierInboxList extends StatelessWidget {
  const new({required this.items, required this.onMarkRead, super.key});

  final List<CarrierInboxItem> items;
  final ValueChanged<String> onMarkRead;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            l10n.carrierLineInboxEmpty,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey<String>('carrier-line-inbox-list'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final CarrierInboxItem item = items[index];
        final IconData icon = switch (item.kind) {
          CarrierInboxKind.call => Icons.call_outlined,
          CarrierInboxKind.message => Icons.sms_outlined,
        };
        final String kindLabel = switch (item.kind) {
          CarrierInboxKind.call => l10n.carrierLineInboxKindCall,
          CarrierInboxKind.message => l10n.carrierLineInboxKindMessage,
        };
        return ListTile(
          key: ValueKey<String>('carrier-line-inbox-${item.id}'),
          leading: Icon(icon, semanticLabel: kindLabel),
          title: Text(
            item.peerLabel,
            style: item.isUnread
                ? Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)
                : null,
          ),
          subtitle: Text(
            item.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: item.isUnread
              ? IconButton(
                  key: ValueKey<String>('carrier-line-mark-read-${item.id}'),
                  tooltip: l10n.carrierLineMarkReadTooltip,
                  onPressed: () => onMarkRead(item.id),
                  icon: const Icon(Icons.mark_email_read_outlined),
                )
              : null,
        );
      },
    );
  }
}
