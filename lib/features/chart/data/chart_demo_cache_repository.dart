import 'package:flutter_bloc_app/features/chart/domain/chart_cache_repository.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChartDemoCacheRepository extends HiveRepositoryBase
    implements ChartCacheRepository {
  ChartDemoCacheRepository({required super.hiveService});

  static const String _boxName = 'chart_cache';
  static const String _trendingKey = 'trending_points';
  static const String _updatedAtKey = 'updatedAt';
  static const String _itemsKey = 'items';

  @override
  String get boxName => _boxName;

  @override
  Future<List<ChartPoint>> readTrendingCounts({
    final Duration? maxAge,
  }) async => StorageGuard.run<List<ChartPoint>>(
    logContext: 'ChartDemoCacheRepository.readTrendingCounts',
    action: () async {
      final Box<dynamic> box = await getBox();
      final dynamic stored = box.get(_trendingKey);
      if (stored is! Map<dynamic, dynamic>) {
        return const <ChartPoint>[];
      }
      final DateTime? updatedAt = _parseUpdatedAt(stored);
      if (_isStale(updatedAt, maxAge)) {
        return const <ChartPoint>[];
      }
      final dynamic items = stored[_itemsKey];
      if (items is! List<dynamic>) {
        return const <ChartPoint>[];
      }
      final List<ChartPoint> result = <ChartPoint>[];
      for (final dynamic item in items) {
        if (item is! Map<dynamic, dynamic>) continue;
        final Map<String, dynamic> typed = _convertMapToTyped(item);
        try {
          result.add(ChartPoint.fromJson(typed));
        } on Object catch (error, stackTrace) {
          AppLogger.warning(
            'ChartDemoCacheRepository skipped invalid cached chart point',
          );
          AppLogger.error(
            'ChartDemoCacheRepository.readTrendingCounts',
            error,
            stackTrace,
          );
          continue;
        }
      }
      return result;
    },
    fallback: () => const <ChartPoint>[],
  );

  @override
  Future<void> writeTrendingCounts(final List<ChartPoint> points) async {
    await StorageGuard.run<void>(
      logContext: 'ChartDemoCacheRepository.writeTrendingCounts',
      action: () async {
        final Box<dynamic> box = await getBox();
        await box.put(
          _trendingKey,
          <String, dynamic>{
            _updatedAtKey: DateTime.now().toUtc().toIso8601String(),
            _itemsKey: points.map(_pointToJson).toList(),
          },
        );
      },
    );
  }

  Map<String, dynamic> _pointToJson(final ChartPoint point) =>
      <String, dynamic>{
        'date': point.date.toUtc().toIso8601String(),
        'value': point.value,
      };

  DateTime? _parseUpdatedAt(final Map<dynamic, dynamic> stored) {
    final Object? raw = stored[_updatedAtKey];
    if (raw is! String) return null;
    return DateTime.tryParse(raw);
  }

  bool _isStale(final DateTime? updatedAt, final Duration? maxAge) {
    if (updatedAt == null || maxAge == null) return false;
    return updatedAt.isBefore(DateTime.now().toUtc().subtract(maxAge));
  }

  Map<String, dynamic> _convertMapToTyped(final Map<dynamic, dynamic> source) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<dynamic, dynamic> entry in source.entries) {
      if (entry.key is! String) continue;
      result[entry.key as String] = entry.value;
    }
    return result;
  }
}
