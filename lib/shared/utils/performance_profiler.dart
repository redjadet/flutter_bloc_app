import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/performance_profiler_internal.dart';
import 'package:flutter_bloc_app/shared/utils/performance_profiler_report.dart';
import 'package:flutter_bloc_app/shared/utils/performance_profiler_stats.dart';
import 'package:flutter_bloc_app/shared/utils/performance_profiler_widget.dart';

/// Performance profiler for tracking widget rebuilds and frame performance.
///
/// **Usage:**
/// ```dart
/// // Wrap widgets you want to track
/// PerformanceProfiler.trackWidget('MyWidget', () => MyWidget());
///
/// // Track frame performance
/// PerformanceProfiler.trackFrame(() {
///   // Expensive operation
/// });
///
/// // Enable/disable profiling
/// PerformanceProfiler.enabled = true;
/// ```
class PerformanceProfiler {
  PerformanceProfiler._();

  static bool _enabled = kDebugMode;
  static final Map<String, WidgetRebuildInfoInternal> _rebuildCounts = {};
  static final List<_FrameInfo> _frameTimes = [];
  static const int _maxFrameHistory = 100;

  /// Whether performance profiling is enabled.
  static bool get enabled => _enabled;

  /// Enable or disable performance profiling.
  static void setEnabled({required final bool enabled}) {
    _enabled = enabled;
    if (!enabled) {
      _rebuildCounts.clear();
      _frameTimes.clear();
    }
  }

  /// Track widget rebuilds.
  ///
  /// Wrap widgets with this to track how many times they rebuild:
  /// ```dart
  /// PerformanceProfiler.trackWidget('CounterDisplay', () => CounterDisplay());
  /// ```
  static Widget trackWidget(
    final String name,
    final Widget Function() builder,
  ) {
    if (!_enabled) {
      return builder();
    }

    return TrackedWidget(
      name: name,
      child: builder(),
    );
  }

  /// Track frame rendering time.
  ///
  /// Use this to measure how long expensive operations take:
  /// ```dart
  /// PerformanceProfiler.trackFrame(() {
  ///   // Expensive operation
  /// });
  /// ```
  static T trackFrame<T>(final T Function() operation) {
    if (!_enabled) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      _recordFrameTime(stopwatch.elapsedMicroseconds);
    }
  }

  /// Track async frame rendering time.
  ///
  /// Use this to measure async operations:
  /// ```dart
  /// await PerformanceProfiler.trackFrameAsync(() async {
  ///   // Async operation
  /// });
  /// ```
  static Future<T> trackFrameAsync<T>(
    final Future<T> Function() operation,
  ) async {
    if (!_enabled) {
      return operation();
    }

    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _recordFrameTime(stopwatch.elapsedMicroseconds);
    }
  }

  /// Get rebuild statistics for a widget.
  static WidgetRebuildInfo? getRebuildInfo(final String name) {
    if (_rebuildCounts[name] case final info?) {
      return WidgetRebuildInfo(
        name: info.name,
        rebuildCount: info.rebuildCount,
        lastRebuildTime: info.lastRebuildTime,
      );
    }
    return null;
  }

  /// Get all rebuild statistics.
  static Map<String, WidgetRebuildInfo> getAllRebuildStats() =>
      _rebuildCounts.map(
        (final key, final value) => MapEntry(
          key,
          WidgetRebuildInfo(
            name: value.name,
            rebuildCount: value.rebuildCount,
            lastRebuildTime: value.lastRebuildTime,
          ),
        ),
      );

  /// Get frame performance statistics.
  static FrameStats getFrameStats() {
    if (_frameTimes.isEmpty) {
      return FrameStats(
        averageFrameTime: 0,
        maxFrameTime: 0,
        minFrameTime: 0,
        frameCount: 0,
      );
    }

    final times = _frameTimes.map((final f) => f.microseconds).toList();
    final average = times.reduce((final a, final b) => a + b) / times.length;
    final max = times.reduce((final a, final b) => a > b ? a : b);
    final min = times.reduce((final a, final b) => a < b ? a : b);

    return FrameStats(
      averageFrameTime: average,
      maxFrameTime: max,
      minFrameTime: min,
      frameCount: times.length,
    );
  }

  /// Print performance report to console.
  static void printReport() {
    if (!_enabled) {
      return;
    }

    final frameStats = getFrameStats();
    printPerformanceReport(
      rebuildCounts: _rebuildCounts,
      frameStats: frameStats,
    );
  }

  /// Clear all performance data.
  static void clear() {
    _rebuildCounts.clear();
    _frameTimes.clear();
  }

  /// Records a widget rebuild (internal use only).
  static void recordRebuild(final String name, final Duration duration) {
    final info = _rebuildCounts.putIfAbsent(
      name,
      () => WidgetRebuildInfoInternal(name: name),
    );
    info.rebuildCount++;
    info.lastRebuildTime = duration.inMicroseconds / 1000;
  }

  static void _recordFrameTime(final int microseconds) {
    _frameTimes.add(
      _FrameInfo(
        microseconds: microseconds,
        timestamp: DateTime.now(),
      ),
    );

    // Keep only recent frames
    if (_frameTimes.length > _maxFrameHistory) {
      _frameTimes.removeAt(0);
    }
  }
}

class _FrameInfo {
  _FrameInfo({
    required this.microseconds,
    required this.timestamp,
  });

  final int microseconds;
  final DateTime timestamp;
}
