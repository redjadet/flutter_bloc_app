import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/entities/order_book_level.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/cubit/realtime_market_state.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/realtime_market_ui_tokens.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class OrderBookPanel extends StatelessWidget {
  const OrderBookPanel({
    required this.bids,
    required this.asks,
    required this.l10n,
    required this.bidFlex,
    required this.askFlex,
    super.key,
    this.compactSide,
  });

  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;
  final AppLocalizations l10n;
  final int bidFlex;
  final int askFlex;
  final RealtimeMarketSideTab? compactSide;

  static double _maxQty(final List<OrderBookLevel> rows) {
    if (rows.isEmpty) {
      return 1;
    }
    return rows
        .map((final e) => e.quantity)
        .reduce((final a, final b) => a > b ? a : b);
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final double maxBid = _maxQty(bids);
    final double maxAsk = _maxQty(asks);
    final bool showCompactBid = compactSide == RealtimeMarketSideTab.bids;
    final bool compact = compactSide != null;

    Widget column(
      final String title,
      final List<OrderBookLevel> rows,
      final Color accent,
      final int flex,
      final double maxQty,
    ) {
      final Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.responsiveGapXS),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  l10n.realtimeMarketOrderBookColumnPrice,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  l10n.realtimeMarketOrderBookColumnAmount,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveGapXS / 2),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              itemCount: rows.length,
              itemBuilder: (final _, final i) {
                final OrderBookLevel r = rows[i];
                final double depth = maxQty > 0
                    ? (r.quantity / maxQty).clamp(0.0, 1.0)
                    : 0.0;
                return Padding(
                  key: ValueKey<String>(
                    'order_book_${i}_${r.side.name}_${r.price}',
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsiveGapXS / 2,
                  ),
                  child: SizedBox(
                    height: 22,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: depth,
                              alignment: Alignment.centerLeft,
                              child: ColoredBox(
                                color: accent.withValues(alpha: 0.14),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Text(
                                  r.price.toStringAsFixed(2),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  r.quantity.toStringAsFixed(4),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
      if (compact) {
        return content;
      }
      return Expanded(flex: flex, child: content);
    }

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.realtimeMarketOrderBookTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          SizedBox(
            height: compact ? 280 : 220,
            child: compact
                ? column(
                    showCompactBid
                        ? l10n.realtimeMarketSideBuy
                        : l10n.realtimeMarketSideSell,
                    showCompactBid ? bids : asks,
                    showCompactBid
                        ? RealtimeMarketUiTokens.bidAccent(scheme)
                        : RealtimeMarketUiTokens.askAccent(scheme),
                    1,
                    showCompactBid ? maxBid : maxAsk,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      column(
                        l10n.realtimeMarketSideBuy,
                        bids,
                        RealtimeMarketUiTokens.bidAccent(scheme),
                        bidFlex,
                        maxBid,
                      ),
                      SizedBox(width: context.responsiveGapM),
                      column(
                        l10n.realtimeMarketSideSell,
                        asks,
                        RealtimeMarketUiTokens.askAccent(scheme),
                        askFlex,
                        maxAsk,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
