import 'package:design_system/responsive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class MarketChartPanel extends StatelessWidget {
  const MarketChartPanel({
    required this.closes,
    required this.l10n,
    super.key,
  });

  final List<double> closes;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<double> series = closes.isEmpty
        ? <double>[0, 0]
        : (closes.length == 1
              ? <double>[closes.single, closes.single]
              : closes);
    final double minY = series.reduce((a, b) => a < b ? a : b);
    final double maxY = series.reduce((a, b) => a > b ? a : b);
    final double pad = (maxY - minY).abs() < 1e-6 ? 1 : (maxY - minY) * 0.08;
    final List<FlSpot> spots = List<FlSpot>.generate(
      series.length,
      (final i) => FlSpot(i.toDouble(), series[i]),
      growable: false,
    );

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.realtimeMarketChartTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.responsiveGapS),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY - pad,
                maxY: maxY + pad,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (final _) => FlLine(
                    color: scheme.outlineVariant.withValues(alpha: 0.35),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => scheme.surfaceContainerHigh,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (final touched) {
                      return touched.map((final spot) {
                        return LineTooltipItem(
                          spot.y.toStringAsFixed(2),
                          TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: scheme.primary,
                    barWidth: 2.2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: scheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
