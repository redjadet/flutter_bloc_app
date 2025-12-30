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
  void _recordRebuild() {
    if (!PerformanceProfiler.enabled) {
      return;
    }
    PerformanceProfiler.recordRebuild(widget.name, Duration.zero);
  }

  @override
  void initState() {
    super.initState();
    _recordRebuild();
  }

  @override
  void didUpdateWidget(final TrackedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recordRebuild();
  }

  @override
  Widget build(final BuildContext context) => widget.child;
}
