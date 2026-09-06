/// Performance statistics data classes.
///
/// These classes are exported separately to keep the main profiler file focused.
library;

/// Widget rebuild information.
class WidgetRebuildInfo {
  new({
    required this.name,
    required this.rebuildCount,
    required this.lastRebuildTime,
  });

  final String name;
  final int rebuildCount;
  final double lastRebuildTime;
}

/// Frame performance statistics.
class FrameStats {
  new({
    required this.averageFrameTime,
    required this.maxFrameTime,
    required this.minFrameTime,
    required this.frameCount,
  });

  final double averageFrameTime;
  final int maxFrameTime;
  final int minFrameTime;
  final int frameCount;
}
