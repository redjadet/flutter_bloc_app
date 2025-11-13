# Performance Profiling Guide

This document explains how to profile and optimize performance in the Flutter BLoC app.

## Overview

The app includes several performance profiling tools and techniques:

1. **Performance Profiler Utility** - Tracks widget rebuilds and frame times
2. **Performance Overlay** - Visual frame rendering performance (dev mode only)
3. **RepaintBoundary Widgets** - Isolates expensive repaints
4. **BlocSelector** - Reduces unnecessary widget rebuilds
5. **Flutter DevTools** - Comprehensive performance analysis

## Performance Profiler Utility

The `PerformanceProfiler` utility (`lib/shared/utils/performance_profiler.dart`) tracks widget rebuilds and frame rendering times.

### Enabling Performance Profiling

Performance profiling is enabled by default in debug mode. You can control it programmatically:

```dart
// Enable profiling
PerformanceProfiler.setEnabled(enabled: true);

// Disable profiling
PerformanceProfiler.setEnabled(enabled: false);
```

### Tracking Widget Rebuilds

Wrap widgets you want to track:

```dart
// Track a specific widget
PerformanceProfiler.trackWidget('CounterDisplay', () => CounterDisplay());

// In your widget tree
Column(
  children: [
    PerformanceProfiler.trackWidget('MyExpensiveWidget', () => MyExpensiveWidget()),
    // Other widgets...
  ],
)
```

### Tracking Frame Performance

Measure how long operations take:

```dart
// Synchronous operations
final result = PerformanceProfiler.trackFrame(() {
  // Expensive operation
  return computeExpensiveValue();
});

// Async operations
final result = await PerformanceProfiler.trackFrameAsync(() async {
  // Async operation
  return await fetchData();
});
```

### Viewing Performance Reports

Print a performance report to the console:

```dart
// Print report
PerformanceProfiler.printReport();

// Get rebuild statistics
final stats = PerformanceProfiler.getAllRebuildStats();
for (final entry in stats.entries) {
  print('${entry.key}: ${entry.value.rebuildCount} rebuilds');
}

// Get frame statistics
final frameStats = PerformanceProfiler.getFrameStats();
print('Average frame time: ${frameStats.averageFrameTime}ms');
```

### Example Output

```text
Performance Report

Widget Rebuild Statistics:
  CounterDisplay: 15 rebuilds (last: 2.34ms)
  CountdownBar: 8 rebuilds (last: 1.12ms)
  SearchResultsGrid: 3 rebuilds (last: 5.67ms)

Frame Performance Statistics:
  Average: 16.23ms
  Max: 45.67ms
  Min: 8.12ms
  Total frames tracked: 100
```

## Performance Overlay

The performance overlay is **disabled by default** but can be enabled via configuration. When enabled, it shows a visual indicator with:

- **Frame rendering time** - Green bars indicate smooth 60fps, yellow/red indicate jank
- **GPU vs CPU time** - Helps identify rendering bottlenecks
- **Frame drops** - Visual indication of performance issues

### Enabling

The `PerformanceOverlay` is **disabled by default** but can be enabled via the `ENABLE_PERFORMANCE_OVERLAY` environment variable.

**To enable the performance overlay:**

```bash
# Run with performance overlay enabled
flutter run --dart-define=ENABLE_PERFORMANCE_OVERLAY=true

# Or for a specific flavor
flutter run --dart-define=ENABLE_PERFORMANCE_OVERLAY=true -t dev
```

**Configuration:**

The overlay is configured in `lib/core/app_config.dart`:

```dart
// lib/core/app_config.dart
static bool get _isPerformanceOverlayEnabled =>
    const bool.fromEnvironment(
      'ENABLE_PERFORMANCE_OVERLAY',
      defaultValue: false, // Default is disabled
    );

// In MaterialApp.router builder:
if (_isPerformanceOverlayEnabled && !_isTestEnvironment()) {
  result = Stack(
    children: [
      result,
      // Center the overlay and allow click-through
      Center(
        child: IgnorePointer(
          // Allow clicks to pass through to widgets behind
          child: ColoredBox(
            // Semi-transparent dark background (70% opacity) for better visibility
            color: Colors.black.withValues(alpha: 0.7),
            child: PerformanceOverlay.allEnabled(),
          ),
        ),
      ),
    ],
  );
}
```

**Note:**

- The overlay has a semi-transparent dark background (70% opacity) to improve visibility of the performance graphs.
- The overlay is centered on the screen and allows click-through, so you can interact with widgets behind it while monitoring performance.

## RepaintBoundary Optimization

Several widgets are wrapped with `RepaintBoundary` to isolate expensive repaints:

- `ChatMessageList` - List of chat messages
- `WebsocketMessageList` - List of WebSocket messages
- `GraphqlDemoPage` - GraphQL demo page list
- `ProfilePage` - Profile page scroll view
- `SearchResultsGrid` - Search results grid
- `MapSampleMapView` - Google Maps widget

These boundaries prevent unnecessary repaints of parent widgets when child widgets update.

## BlocSelector Optimization

Several pages use `BlocSelector` instead of `BlocBuilder` to reduce rebuilds:

- `GraphqlDemoPage` - Separate selectors for progress bar, filter bar, and body
- `SearchPage` - Selector for body content
- `ProfilePage` - Selector for body content
- `CountdownBar` - Selector for countdown display

This ensures widgets only rebuild when specific parts of the state change.

## Using Flutter DevTools

Flutter DevTools provides comprehensive performance analysis:

### 1. Launch DevTools

```bash
# Start the app with observatory enabled
flutter run --profile

# Or attach to a running app
flutter pub global activate devtools
flutter pub global run devtools
```

### 2. Performance Tab

The Performance tab shows:

- **Frame rendering timeline** - Visual representation of frame rendering
- **CPU profiler** - Function call stack and execution time
- **Memory profiler** - Memory usage over time
- **Widget rebuild inspector** - Which widgets rebuild and why

### 3. Widget Inspector

The Widget Inspector shows:

- **Widget tree** - Visual representation of the widget hierarchy
- **Rebuild reasons** - Why widgets rebuild
- **Render object tree** - Layout and painting information

### 4. Memory Tab

The Memory tab shows:

- **Memory usage** - Heap size and allocations
- **Memory leaks** - Objects that aren't garbage collected
- **Snapshot comparison** - Compare memory states

## Performance Best Practices

### 1. Minimize Widget Rebuilds

- Use `const` constructors where possible
- Use `BlocSelector` instead of `BlocBuilder` when only specific state changes matter
- Extract expensive widgets into separate widgets with `RepaintBoundary`

### 2. Optimize List Rendering

- Use `ListView.builder` instead of `ListView` for long lists
- Implement `itemExtent` for fixed-height items
- Use `cacheExtent` to control off-screen item caching

### 3. Reduce Build Method Complexity

- Extract complex logic into separate methods
- Use `Builder` widgets to create new build contexts
- Avoid heavy computations in `build()` methods

### 4. Optimize Images

- Use `FancyShimmerImage` for loading states
- Implement image caching
- Use appropriate image sizes (don't load full-resolution images for thumbnails)

### 5. Profile Regularly

- Run performance profiling in debug mode during development
- Use Flutter DevTools for detailed analysis
- Test on real devices, not just simulators
- Profile release builds (`flutter run --release`) for accurate performance

## Common Performance Issues

### Issue: Widget Rebuilds Too Often

**Symptoms:** Widget rebuilds on every frame or state change

**Solutions:**

- Use `BlocSelector` to only rebuild when specific state changes
- Wrap widget in `RepaintBoundary` to isolate repaints
- Check if parent widgets are rebuilding unnecessarily

### Issue: Janky Scrolling

**Symptoms:** List scrolling is not smooth, frames drop

**Solutions:**

- Use `ListView.builder` with `itemExtent`
- Implement `RepaintBoundary` around list items
- Reduce widget tree complexity in list items
- Profile with Performance Overlay to identify bottlenecks

### Issue: Slow Initial Load

**Symptoms:** App takes a long time to show initial content

**Solutions:**

- Use skeleton loaders (`skeletonizer` package)
- Implement progressive loading
- Lazy load non-critical data
- Profile startup time with DevTools

### Issue: Memory Leaks

**Symptoms:** Memory usage increases over time

**Solutions:**

- Use Memory profiler in DevTools
- Check for unclosed streams or subscriptions
- Ensure proper disposal of resources
- Review repository lifecycle management

## Performance Checklist

Before releasing, ensure:

- [ ] Performance profiling enabled and reviewed
- [ ] No excessive widget rebuilds (check with `PerformanceProfiler`)
- [ ] Frame rate is smooth (60fps) - check Performance Overlay
- [ ] Memory usage is stable - check Memory profiler
- [ ] List scrolling is smooth - test on real devices
- [ ] Images are optimized - appropriate sizes and caching
- [ ] Expensive operations are offloaded - use isolates or async
- [ ] `RepaintBoundary` used around expensive widgets
- [ ] `BlocSelector` used instead of `BlocBuilder` where appropriate

## Additional Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools Documentation](https://docs.flutter.dev/tools/devtools)
- [Widget Performance](https://docs.flutter.dev/perf/rendering)
- [Memory Profiling](https://docs.flutter.dev/tools/devtools/memory)
