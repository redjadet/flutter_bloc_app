import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_connection_status.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/icon_label_row.dart';

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
    final (Color bg, Color fg, String label) = switch (status) {
      MarketConnectionStatus.live => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        l10n.realtimeMarketConnectionLive,
      ),
      MarketConnectionStatus.reconnecting => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        l10n.realtimeMarketConnectionReconnecting,
      ),
      MarketConnectionStatus.offline => (
        colors.errorContainer,
        colors.onErrorContainer,
        l10n.realtimeMarketConnectionOffline,
      ),
    };
    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: IconLabelRow(
            label: label,
            icon: status == MarketConnectionStatus.reconnecting
                ? Icons.sync_rounded
                : null,
            iconSize: 16,
            iconColor: fg,
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
