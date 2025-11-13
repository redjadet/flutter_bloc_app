import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/utils/performance_profiler.dart';

/// Widget wrapper for tracking rebuilds.
///
/// Extracted from the main profiler to keep file size manageable.

class TrackedWidget extends StatefulWidget {
  const TrackedWidget({
    required this.name,
    required this.child,
    super.key,
  });

  final String name;
  final Widget child;

  @override
  State<TrackedWidget> createState() => _TrackedWidgetState();
}

class _TrackedWidgetState extends State<TrackedWidget> {
  @override
  void initState() {
    super.initState();
    if (PerformanceProfiler.enabled) {
      PerformanceProfiler.recordRebuild(widget.name, Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (PerformanceProfiler.enabled) {
      final stopwatch = Stopwatch()..start();
      final result = widget.child;
      stopwatch.stop();
      PerformanceProfiler.recordRebuild(widget.name, stopwatch.elapsed);
      return result;
    }
    return widget.child;
  }
}
