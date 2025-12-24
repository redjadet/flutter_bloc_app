import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/performance_profiler_internal.dart';
import 'package:flutter_bloc_app/shared/utils/performance_profiler_stats.dart';

/// Performance report printing utilities.
///
/// Extracted from the main profiler to keep file size manageable.

/// Prints a performance report to the console.
void printPerformanceReport({
  required final Map<String, WidgetRebuildInfoInternal> rebuildCounts,
  required final FrameStats frameStats,
}) {
  AppLogger.info('Performance Report');

  // Widget rebuild stats
  if (rebuildCounts.isNotEmpty) {
    AppLogger.info('Widget Rebuild Statistics:');
    final sorted = rebuildCounts.entries.toList()
      ..sort(
        (final a, final b) =>
            b.value.rebuildCount.compareTo(a.value.rebuildCount),
      );

    for (final entry in sorted) {
      final info = entry.value;
      AppLogger.info(
        '  ${entry.key}: ${info.rebuildCount} rebuilds '
        '(last: ${info.lastRebuildTime.toStringAsFixed(2)}ms)',
      );
    }
  }

  // Frame performance stats
  if (frameStats.frameCount > 0) {
    AppLogger.info('Frame Performance Statistics:');
    AppLogger.info(
      '  Average: ${(frameStats.averageFrameTime / 1000).toStringAsFixed(2)}ms',
    );
    AppLogger.info(
      '  Max: ${(frameStats.maxFrameTime / 1000).toStringAsFixed(2)}ms',
    );
    AppLogger.info(
      '  Min: ${(frameStats.minFrameTime / 1000).toStringAsFixed(2)}ms',
    );
    AppLogger.info('  Total frames tracked: ${frameStats.frameCount}');
  }
}
