import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChartLoadingList extends StatelessWidget {
  const ChartLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;
    final chartHeight = MediaQuery.of(context).size.height * 0.28;
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: theme.colorScheme.surfaceContainerHigh,
        highlightColor: theme.colorScheme.surface,
      ),
      child: ChartScrollable(
        children: [
          Container(
            height: chartHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UI.radiusM),
              color: skeletonColor,
            ),
          ),
          SizedBox(height: UI.gapL),
          Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UI.radiusM),
              color: skeletonColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartMessageList extends StatelessWidget {
  const ChartMessageList({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChartScrollable(
      children: [
        SizedBox(height: UI.gapL * 2),
        Center(child: Text(message, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}

class ChartContentList extends StatelessWidget {
  const ChartContentList({
    super.key,
    required this.l10n,
    required this.points,
    required this.dateFormat,
    required this.zoomEnabled,
    required this.onZoomChanged,
  });

  final AppLocalizations l10n;
  final List<ChartPoint> points;
  final DateFormat dateFormat;
  final bool zoomEnabled;
  final ValueChanged<bool> onZoomChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartHeight = MediaQuery.of(context).size.height * 0.45;
    return ChartScrollable(
      children: [
        Text(l10n.chartPageDescription, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapL),
        SwitchListTile.adaptive(
          value: zoomEnabled,
          onChanged: onZoomChanged,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.chartZoomToggleLabel),
        ),
        SizedBox(height: UI.gapS),
        SizedBox(
          height: chartHeight,
          child: ChartLineGraph(
            points: points,
            dateFormat: dateFormat,
            zoomEnabled: zoomEnabled,
          ),
        ),
        SizedBox(height: UI.gapL),
      ],
    );
  }
}

class ChartLineGraph extends StatelessWidget {
  const ChartLineGraph({
    super.key,
    required this.points,
    required this.dateFormat,
    required this.zoomEnabled,
  });

  final List<ChartPoint> points;
  final DateFormat dateFormat;
  final bool zoomEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final tooltipTextStyle =
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        );

    final lineTouchData = zoomEnabled
        ? const LineTouchData(enabled: false)
        : LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots
                    .map<LineTooltipItem?>(
                      (spot) => LineTooltipItem(
                        spot.y.toStringAsFixed(3),
                        tooltipTextStyle,
                      ),
                    )
                    .toList();
              },
            ),
          );

    final chart = LineChart(
      LineChartData(
        lineTouchData: lineTouchData,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: UI.gapL * 3,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                Widget child = const SizedBox.shrink();
                if (index >= 0 && index < points.length) {
                  child = Text(dateFormat.format(points[index].date));
                }
                return SideTitleWidget(
                  meta: meta,
                  space: UI.gapS,
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
      boundaryMargin: const EdgeInsets.all(24),
      child: chart,
    );
  }
}

class ChartScrollable extends StatelessWidget {
  const ChartScrollable({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(UI.gapL),
      children: children,
    );
  }
}
