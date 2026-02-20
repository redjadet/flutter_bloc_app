import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:intl/intl.dart';

class ChartLineGraph extends StatelessWidget {
  const ChartLineGraph({
    required this.points,
    required this.dateFormat,
    required this.zoomEnabled,
    super.key,
  });

  final List<ChartPoint> points;
  final DateFormat dateFormat;
  final bool zoomEnabled;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final tooltipTextStyle =
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        );

    final lineTouchData = zoomEnabled
        ? const LineTouchData(enabled: false)
        : LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (final touchedSpots) => touchedSpots
                  .map<LineTooltipItem?>(
                    (final spot) => LineTooltipItem(
                      spot.y.toStringAsFixed(3),
                      tooltipTextStyle,
                    ),
                  )
                  .toList(),
            ),
          );

    final chart = LineChart(
      LineChartData(
        lineTouchData: lineTouchData,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: context.responsiveGapL * 3,
              getTitlesWidget: (final value, final meta) {
                final index = value.toInt();
                Widget child = const SizedBox.shrink();
                if (index >= 0 && index < points.length) {
                  child = Text(dateFormat.format(points[index].date));
                }
                return SideTitleWidget(
                  meta: meta,
                  space: context.responsiveGapS,
                  child: child,
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
            ],
            isCurved: true,
            color: primaryColor,
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );

    if (!zoomEnabled) {
      return chart;
    }

    return InteractiveViewer(
      maxScale: 6,
      boundaryMargin: context.allGapL,
      child: chart,
    );
  }
}
