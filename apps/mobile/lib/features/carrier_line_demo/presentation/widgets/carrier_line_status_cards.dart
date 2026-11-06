import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/line_status.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class CarrierLineStatusCards extends StatelessWidget {
  const new({required this.snapshot, super.key});

  final LineStatusSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Column(
      key: const ValueKey<String>('carrier-line-status-cards'),
      children: <Widget>[
        _StatusCard(
          key: const ValueKey<String>('carrier-line-esim-card'),
          title: l10n.carrierLineEsimTitle,
          statusLabel: _statusLabel(l10n, snapshot.esim),
          detail: snapshot.esimDetail ?? l10n.carrierLineEsimDetailFallback,
          icon: Icons.sim_card_outlined,
        ),
        const SizedBox(height: 8),
        _StatusCard(
          key: const ValueKey<String>('carrier-line-porting-card'),
          title: l10n.carrierLinePortingTitle,
          statusLabel: _statusLabel(l10n, snapshot.porting),
          detail:
              snapshot.portingDetail ?? l10n.carrierLinePortingDetailFallback,
          icon: Icons.swap_horiz_outlined,
        ),
        const SizedBox(height: 8),
        _StatusCard(
          key: const ValueKey<String>('carrier-line-billing-card'),
          title: l10n.carrierLineBillingTitle,
          statusLabel: _statusLabel(l10n, snapshot.billing),
          detail:
              snapshot.billingDetail ?? l10n.carrierLineBillingDetailFallback,
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  String _statusLabel(AppLocalizations l10n, LineLifecycleStatus status) {
    return switch (status) {
      LineLifecycleStatus.unknown => l10n.carrierLineStatusUnknown,
      LineLifecycleStatus.pending => l10n.carrierLineStatusPending,
      LineLifecycleStatus.active => l10n.carrierLineStatusActive,
      LineLifecycleStatus.attention => l10n.carrierLineStatusAttention,
      LineLifecycleStatus.blocked => l10n.carrierLineStatusBlocked,
    };
  }
}

class _StatusCard extends StatelessWidget {
  const new({
    required this.title,
    required this.statusLabel,
    required this.detail,
    required this.icon,
    super.key,
  });

  final String title;
  final String statusLabel;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return CommonCard(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleSmall),
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(statusLabel),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(detail, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
