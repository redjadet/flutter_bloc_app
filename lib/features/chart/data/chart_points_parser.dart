import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

List<ChartPoint> parseChartPointsResilient(
  final List<dynamic> raw, {
  final String dateKey = 'date_utc',
  final String valueKey = 'value',
}) {
  final List<ChartPoint> out = <ChartPoint>[];
  for (final dynamic item in raw) {
    final Map<String, dynamic>? map = mapFromDynamic(item);
    if (map == null) continue;
    final String? dateUtc = map[dateKey] as String?;
    final Object? valueObj = map[valueKey];
    if (dateUtc == null || dateUtc.isEmpty) continue;
    final DateTime? date = DateTime.tryParse(dateUtc);
    if (date == null) continue;
    final double? value = valueObj is num
        ? valueObj.toDouble()
        : double.tryParse(valueObj?.toString() ?? '');
    if (value == null) continue;
    try {
      out.add(ChartPoint(date: date.toUtc(), value: value));
    } on Object catch (error, stackTrace) {
      AppLogger.warning('parseChartPointsResilient skip invalid point row');
      AppLogger.error('parseChartPointsResilient', error, stackTrace);
    }
  }
  out.sort((final a, final b) => a.date.compareTo(b.date));
  return List<ChartPoint>.unmodifiable(out);
}
