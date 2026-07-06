import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/realtime_market/domain/market_feed_snapshot.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/connection_status_pill.dart';
import 'package:flutter_bloc_app/features/realtime_market/presentation/widgets/realtime_market_ui_tokens.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class MarketHeader extends StatelessWidget {
  const MarketHeader({
    required this.snapshot,
    required this.l10n,
    super.key,
  });

  final MarketFeedSnapshot snapshot;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String pairLabel = snapshot.pairId.replaceAll('_', '/').toUpperCase();
    final bool up = snapshot.changePct24h >= 0;
    final Color deltaColor = up
        ? RealtimeMarketUiTokens.bidAccent(scheme)
        : RealtimeMarketUiTokens.askAccent(scheme);
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final bool stackStatus = constraints.maxWidth < 430;
        final Widget priceBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pairLabel,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: context.responsiveGapXS),
            Text(
              l10n.realtimeMarketLastPrice,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                snapshot.lastPrice.toStringAsFixed(2),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(height: context.responsiveGapXS),
            DecoratedBox(
              decoration: BoxDecoration(
                color: deltaColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  '${up ? '+' : ''}'
                  '${snapshot.changePct24h.toStringAsFixed(2)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        );
        final Widget status = ConnectionStatusPill(
          status: snapshot.connection,
          l10n: l10n,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stackStatus) ...[
              priceBlock,
              SizedBox(height: context.responsiveGapS),
              status,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: priceBlock),
                  SizedBox(width: context.responsiveGapM),
                  Flexible(
                    child: Align(alignment: Alignment.topRight, child: status),
                  ),
                ],
              ),
            SizedBox(height: context.responsiveGapS),
            Text(
              l10n.realtimeMarketDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}
