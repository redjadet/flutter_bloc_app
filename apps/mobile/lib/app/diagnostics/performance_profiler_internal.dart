/// Internal classes for performance profiler.
///
/// These classes are shared between performance_profiler.dart and
/// performance_profiler_report.dart to avoid duplication.
library;

/// Internal widget rebuild info class.
class WidgetRebuildInfoInternal {
  WidgetRebuildInfoInternal({required this.name});

  final String name;
  int rebuildCount = 0;
  double lastRebuildTime = 0;
}
