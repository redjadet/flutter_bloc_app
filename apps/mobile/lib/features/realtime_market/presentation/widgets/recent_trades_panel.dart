import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/recent_trade.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/realtime_market_ui_tokens.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class RecentTradesPanel extends StatelessWidget {
  const RecentTradesPanel({
    required this.trades,
    required this.l10n,
    super.key,
  });

  final List<RecentTrade> trades;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<RecentTrade> shown = trades.length > 12
        ? trades.sublist(0, 12)
        : trades;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.realtimeMarketTradesTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.responsiveGapS),
        if (shown.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.responsiveGapM),
            child: Row(
              children: [
                Icon(
                  Icons.hourglass_empty_rounded,
                  size: 22,
                  color: scheme.onSurfaceVariant,
                ),
                SizedBox(width: context.responsiveGapS),
                Expanded(
                  child: Text(
                    l10n.realtimeMarketTradesEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...shown.map(
            (final t) {
              final Color accent = t.isBuy
                  ? RealtimeMarketUiTokens.bidAccent(scheme)
                  : RealtimeMarketUiTokens.askAccent(scheme);
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.responsiveGapXS / 2,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: context.responsiveGapXS),
                    child: Row(
                      children: [
                        Icon(
                          t.isBuy ? Icons.trending_up : Icons.trending_down,
                          size: 18,
                          color: accent,
                          semanticLabel: t.isBuy
                              ? l10n.realtimeMarketSideBuy
                              : l10n.realtimeMarketSideSell,
                        ),
                        SizedBox(width: context.responsiveGapS),
                        Expanded(
                          child: Text(
                            '${t.price.toStringAsFixed(2)} × ${t.quantity.toStringAsFixed(4)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
