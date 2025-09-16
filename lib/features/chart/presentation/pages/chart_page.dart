import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/chart.dart';
import 'package:flutter_bloc_app/features/chart/data/delayed_chart_repository.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    _repository = DelayedChartRepository();
    _future = _repository.fetchTrendingCounts();
  }

  Future<void> _handleRefresh() {
    final next = _repository.fetchTrendingCounts();
    setState(() {
      _future = next;
    });
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chartPageTitle)),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<ChartPoint>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return _buildLoadingList();
            }
            if (snapshot.hasError) {
              return _buildMessageList(context, l10n.chartPageError);
            }
            final points = snapshot.data ?? const [];
            if (points.isEmpty) {
              return _buildMessageList(context, l10n.chartPageEmpty);
            }
            final locale = Localizations.localeOf(context).toString();
            final dateFormat = DateFormat.Md(locale);
            return _buildContentList(context, l10n, points, dateFormat);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;
    final chartHeight = MediaQuery.of(context).size.height * 0.28;
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: theme.colorScheme.surfaceContainerHigh,
        highlightColor: theme.colorScheme.surface,
      ),
      child: _scrollable([
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
      ]),
    );
  }

  Widget _buildMessageList(BuildContext context, String message) {
    final theme = Theme.of(context);
    return _scrollable([
      SizedBox(height: UI.gapL * 2),
      Center(child: Text(message, style: theme.textTheme.bodyLarge)),
    ]);
  }

  Widget _buildContentList(
    BuildContext context,
    AppLocalizations l10n,
    List<ChartPoint> points,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);
    final chartHeight = MediaQuery.of(context).size.height * 0.45;
    return _scrollable([
      Text(
        l10n.chartPageDescription,
        style: theme.textTheme.titleMedium,
      ),
      SizedBox(height: UI.gapL),
      SwitchListTile.adaptive(
        value: _zoomEnabled,
        onChanged: (value) => setState(() => _zoomEnabled = value),
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.chartZoomToggleLabel),
      ),
      SizedBox(height: UI.gapS),
      SizedBox(height: chartHeight, child: _buildChart(points, dateFormat)),
      SizedBox(height: UI.gapL),
    ]);
  }

  Widget _buildChart(List<ChartPoint> points, DateFormat dateFormat) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final tooltipTextStyle = theme.textTheme.bodyMedium?.copyWith(
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
            // ignore: avoid_redundant_argument_values
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withValues(alpha: 0.15),
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

  ListView _scrollable(List<Widget> children) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(UI.gapL),
        children: children,
      );
}
