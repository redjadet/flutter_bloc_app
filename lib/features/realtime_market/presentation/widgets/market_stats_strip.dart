import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/market_stats.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class MarketStatsStrip extends StatelessWidget {
  const MarketStatsStrip({
    required this.stats,
    required this.l10n,
    super.key,
  });

  final MarketStats stats;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    Widget cell(final String title, final String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.responsiveGapXS / 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.realtimeMarketStatsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveGapS),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.responsiveGapM),
            child: Row(
              children: [
                cell(
                  l10n.realtimeMarketStatsHigh24h,
                  stats.high24h.toStringAsFixed(2),
                ),
                cell(
                  l10n.realtimeMarketStatsLow24h,
                  stats.low24h.toStringAsFixed(2),
                ),
                cell(
                  l10n.realtimeMarketStatsVolume,
                  stats.volume24h.toStringAsFixed(0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
