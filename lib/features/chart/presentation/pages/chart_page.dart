import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/chart.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late final ChartRepository _repository;
  late Future<List<ChartPoint>> _future;
  bool _zoomEnabled = false;

  @override
  void initState() {
    super.initState();
    _repository = ChartRepository();
    _future = _repository.fetchTrendingCounts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chartPageTitle)),
      body: FutureBuilder<List<ChartPoint>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                l10n.chartPageError,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          final points = snapshot.data ?? const [];
          if (points.isEmpty) {
            return Center(
              child: Text(
                l10n.chartPageEmpty,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          final locale = Localizations.localeOf(context).toString();
          final dateFormat = DateFormat.Md(locale);
          return Padding(
            padding: EdgeInsets.all(UI.gapL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.chartPageDescription,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: UI.gapL),
                SwitchListTile.adaptive(
                  value: _zoomEnabled,
                  onChanged: (value) {
                    setState(() => _zoomEnabled = value);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.chartZoomToggleLabel),
                ),
                SizedBox(height: UI.gapS),
                Expanded(child: _buildChart(points, dateFormat)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(List<ChartPoint> points, DateFormat dateFormat) {
    final theme = Theme.of(context);
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

    final lineTouchData = _zoomEnabled
        ? const LineTouchData(enabled: false)
        : LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map<LineTooltipItem?>(
                    (spot) => LineTooltipItem(
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
            color: Theme.of(context).colorScheme.primary,
            // ignore: avoid_redundant_argument_values
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );

    if (!_zoomEnabled) {
      return chart;
    }

    return InteractiveViewer(
      maxScale: 6,
      boundaryMargin: const EdgeInsets.all(24),
      child: chart,
    );
  }
}
