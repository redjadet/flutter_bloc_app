import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:intl/intl.dart';

class ChartLineGraph extends StatefulWidget {
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
  State<ChartLineGraph> createState() => _ChartLineGraphState();
}

class _ChartLineGraphState extends State<ChartLineGraph> {
  late List<FlSpot> _spots;
  late List<String> _bottomLabels;
  late final TransformationController _transformationController;
  _ChartRenderKey? _renderKey;
  LineChartData? _cachedZoomEnabledData;
  LineChartData? _cachedZoomDisabledData;
  static const int _maxBottomLabels = 7;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _recomputeCaches();
  }

  @override
  void didUpdateWidget(final ChartLineGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points ||
        oldWidget.dateFormat != widget.dateFormat) {
      _recomputeCaches();
      _invalidateChartDataCache();
    }
    if (oldWidget.zoomEnabled && !widget.zoomEnabled) {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _recomputeCaches() {
    final List<ChartPoint> points = widget.points;
    _spots = List<FlSpot>.generate(
      points.length,
      (final i) => FlSpot(i.toDouble(), points[i].value),
      growable: false,
    );
    _bottomLabels = List<String>.generate(
      points.length,
      (final i) => widget.dateFormat.format(points[i].date),
      growable: false,
    );
  }

  void _invalidateChartDataCache() {
    _renderKey = null;
    _cachedZoomEnabledData = null;
    _cachedZoomDisabledData = null;
  }

  LineChartData _getOrBuildChartData(
    final BuildContext context, {
    required final bool zoomEnabled,
  }) {
    final theme = Theme.of(context);

    final renderKey = _ChartRenderKey(
      primaryColor: theme.colorScheme.primary,
      onSurface: theme.colorScheme.onSurface,
      reservedSize: context.responsiveGapL * 3,
      titleSpace: context.responsiveGapS,
      simplifyChart: _spots.length >= 160,
      labelEvery: (_bottomLabels.length <= _maxBottomLabels)
          ? 1
          : (_bottomLabels.length / _maxBottomLabels).ceil(),
      // Cache invalidated when points/dateFormat change; reuse otherwise.
      spotCount: _spots.length,
      labelCount: _bottomLabels.length,
    );

    if (_renderKey != renderKey) {
      _renderKey = renderKey;
      _cachedZoomEnabledData = null;
      _cachedZoomDisabledData = null;
    }

    final existing = zoomEnabled
        ? _cachedZoomEnabledData
        : _cachedZoomDisabledData;
    if (existing != null) {
      return existing;
    }

    final tooltipTextStyle =
        theme.textTheme.bodyMedium?.copyWith(
          color: renderKey.onSurface,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          color: renderKey.onSurface,
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

    final data = LineChartData(
      lineTouchData: lineTouchData,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: renderKey.reservedSize,
            getTitlesWidget: (final value, final meta) {
              final index = value.toInt();
              Widget child = const SizedBox.shrink();
              if (index >= 0 &&
                  index < _bottomLabels.length &&
                  (renderKey.labelEvery <= 1 ||
                      index % renderKey.labelEvery == 0)) {
                child = Text(_bottomLabels[index]);
              }
              return SideTitleWidget(
                meta: meta,
                space: renderKey.titleSpace,
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
          spots: _spots,
          isCurved: !renderKey.simplifyChart,
          color: renderKey.primaryColor,
          belowBarData: BarAreaData(
            show: !renderKey.simplifyChart,
            color: renderKey.primaryColor.withValues(alpha: 0.15),
          ),
        ),
      ],
    );

    if (zoomEnabled) {
      _cachedZoomEnabledData = data;
    } else {
      _cachedZoomDisabledData = data;
    }
    return data;
  }

  @override
  Widget build(final BuildContext context) {
    final chart = LineChart(
      _getOrBuildChartData(
        context,
        zoomEnabled: widget.zoomEnabled,
      ),
    );

    return InteractiveViewer(
      panEnabled: widget.zoomEnabled,
      scaleEnabled: widget.zoomEnabled,
      maxScale: 6,
      boundaryMargin: context.allGapL,
      transformationController: _transformationController,
      child: chart,
    );
  }
}

@immutable
class _ChartRenderKey {
  const _ChartRenderKey({
    required this.primaryColor,
    required this.onSurface,
    required this.reservedSize,
    required this.titleSpace,
    required this.simplifyChart,
    required this.labelEvery,
    required this.spotCount,
    required this.labelCount,
  });

  final Color primaryColor;
  final Color onSurface;
  final double reservedSize;
  final double titleSpace;
  final bool simplifyChart;
  final int labelEvery;
  final int spotCount;
  final int labelCount;

  @override
  bool operator ==(final Object other) =>
      other is _ChartRenderKey &&
      other.primaryColor == primaryColor &&
      other.onSurface == onSurface &&
      other.reservedSize == reservedSize &&
      other.titleSpace == titleSpace &&
      other.simplifyChart == simplifyChart &&
      other.labelEvery == labelEvery &&
      other.spotCount == spotCount &&
      other.labelCount == labelCount;

  @override
  int get hashCode => Object.hash(
    primaryColor,
    onSurface,
    reservedSize,
    titleSpace,
    simplifyChart,
    labelEvery,
    spotCount,
    labelCount,
  );
}
