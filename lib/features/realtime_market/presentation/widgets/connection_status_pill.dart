import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_connection_status.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class ConnectionStatusPill extends StatelessWidget {
  const ConnectionStatusPill({
    required this.status,
    required this.l10n,
    super.key,
  });

  final MarketConnectionStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case MarketConnectionStatus.live:
        bg = colors.primaryContainer;
        fg = colors.onPrimaryContainer;
        label = l10n.realtimeMarketConnectionLive;
      case MarketConnectionStatus.reconnecting:
        bg = colors.secondaryContainer;
        fg = colors.onSecondaryContainer;
        label = l10n.realtimeMarketConnectionReconnecting;
      case MarketConnectionStatus.offline:
        bg = colors.errorContainer;
        fg = colors.onErrorContainer;
        label = l10n.realtimeMarketConnectionOffline;
    }
    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status == MarketConnectionStatus.reconnecting) ...[
                Icon(Icons.sync_rounded, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
