# App Startup Time Profiling Guide

This guide explains how to measure and profile Flutter app startup time to track performance improvements from lazy loading and deferred imports.

## Overview

Startup time profiling helps measure the impact of performance optimizations like:

- Deferred imports
- Lazy initialization of services
- Route-level cubit creation
- Gated background sync startup

## Methods

### 1. Flutter DevTools Timeline

**Best for:** Detailed analysis of startup phases

**Steps:**

1. Start Flutter app with timeline recording:

   ```bash
   flutter run --profile --trace-startup
   ```

2. Open Flutter DevTools:

   ```text
   Open Flutter DevTools: http://localhost:9100?uri=...
   ```

3. Navigate to **Performance** tab → **Timeline**

4. Look for:
   - **Frame rendering time** - should be < 16ms for 60fps
   - **Widget build time** - identify slow widgets
   - **Dart VM startup** - baseline VM initialization
   - **First frame rendered** - time to first visual content

**Key Metrics:**

- Time to First Frame (TTFF)
- Time to Interactive (TTI)
- Time to Full Render

### 2. Command Line Startup Trace

**Best for:** Quick measurements and CI/CD

**Steps:**

1. Run app with startup trace:

   ```bash
   flutter run --profile --trace-startup > startup_trace.json
   ```

2. Parse the trace:

   ```bash
   dart tools/analyze_startup_trace.dart startup_trace.json
   ```

3. Extract key metrics:
   - Time from app start to first frame
   - Time from app start to app ready

**Automation Script:**

Create `tool/profile_startup.sh`:

```bash
#!/usr/bin/env bash
flutter run --profile --trace-startup --device-id=<device-id> > startup_$(date +%Y%m%d_%H%M%S).json
```

### 3. Code Instrumentation

**Best for:** Custom measurements and specific optimization tracking

Add timing markers in `lib/core/bootstrap/bootstrap_coordinator.dart`:

```dart
class BootstrapCoordinator {
  static Future<void> bootstrapApp(final Flavor flavor) async {
    final stopwatch = Stopwatch()..start();

    WidgetsFlutterBinding.ensureInitialized();
    _logTiming('WidgetsBinding', stopwatch.elapsed);

    await PlatformInit.initialize();
    _logTiming('PlatformInit', stopwatch.elapsed);

    await _loadSecrets();
    _logTiming('SecretsLoaded', stopwatch.elapsed);

    await AppVersionService.loadAppVersion();
    _logTiming('AppVersionLoaded', stopwatch.elapsed);

    final firebaseReady = await FirebaseBootstrapService.initializeFirebase();
    _logTiming('FirebaseInit', stopwatch.elapsed);

    await configureDependencies();
    _logTiming('DIConfigured', stopwatch.elapsed);

    await InitializationGuard.executeSafely(
      () => getIt<SharedPreferencesMigrationService>().migrateIfNeeded(),
      context: 'bootstrapApp',
      failureMessage: 'Migration failed during app startup.',
    );
    _logTiming('MigrationComplete', stopwatch.elapsed);

    runApp(const MyApp());
    _logTiming('AppStarted', stopwatch.elapsed);
  }

  static void _logTiming(String phase, Duration elapsed) {
    if (kDebugMode) {
      AppLogger.debug('Bootstrap: $phase at ${elapsed.inMilliseconds}ms');
    }
  }
}
```

### 4. Performance Profiler (Existing Tool)

The codebase already includes `PerformanceProfiler` for runtime performance tracking.

**Location:** `lib/shared/utils/performance_profiler.dart`

**Usage:**

```dart
// Track frame rendering time
PerformanceProfiler.trackFrame(() {
  // Expensive operation
});

// Track async operations
await PerformanceProfiler.trackFrameAsync(() async {
  // Async operation
});

// Get statistics
final stats = PerformanceProfiler.getFrameStats();
PerformanceProfiler.printReport();
```

## Baseline Measurements

Before making optimizations, establish a baseline:

### Baseline Checklist

- [ ] Measure cold start time (app killed, fresh launch)
- [ ] Measure warm start time (app in background)
- [ ] Measure time to first frame (TTFF)
- [ ] Measure time to interactive (TTI)
- [ ] Measure bundle size (see `tool/check_bundle_size.sh`)
- [ ] Document device/OS version
- [ ] Document Flutter version
- [ ] Record measurements in `analysis/startup_metrics.md`

### Target Metrics

Based on Flutter best practices:

- **Cold Start TTFF:** < 2 seconds (mobile)
- **Warm Start TTFF:** < 500ms (mobile)
- **Time to Interactive:** < 3 seconds (mobile)
- **Bundle Size:** See budgets in `tool/check_bundle_size.sh`

## After Optimization Measurements

After implementing lazy loading optimizations:

1. **Re-measure** using the same method
2. **Compare** to baseline
3. **Document** improvements in `analysis/startup_metrics.md`
4. **Track** over time to prevent regressions

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Profile Startup Time
  run: |
    flutter run --profile --trace-startup > startup_trace.json
    # Parse and store metrics
    # Compare to baseline
    # Fail if significant regression
```

### Automated Regression Detection

Create `tool/check_startup_performance.sh` that:

1. Runs startup trace
2. Extracts key metrics
3. Compares to baseline
4. Fails if metrics exceed thresholds

## Common Issues

### Slow Startup Causes

1. **Eager initialization** - Services starting before needed
2. **Large bundle size** - Too much code in initial load
3. **Heavy widgets** - Complex UI rendering on first frame
4. **Network calls** - Blocking API calls during startup
5. **Synchronous file I/O** - Reading large files synchronously

### Optimization Strategies

1. **Deferred imports** - Load heavy features on-demand (Google Maps, Markdown Editor, Charts, WebSocket - already implemented)
2. **Lazy DI** - Use lazy singletons (already implemented - all services use `registerLazySingletonIfAbsent`)
3. **Route-level initialization** - Create cubits at route level (already implemented for most features)
4. **Gated service startup** - Start services on first use (BackgroundSyncCoordinator, RemoteConfigCubit - already implemented)
5. **Async initialization** - Use `async` for non-critical startup tasks (BlocProviderHelpers.withAsyncInit pattern)

**Current Implementation Status:**

- ✅ Deferred imports for 4 heavy features
- ✅ All DI registrations use lazy singletons
- ✅ BackgroundSyncCoordinator starts on-demand via `ensureStarted()`
- ✅ RemoteConfigCubit initializes on-demand via `ensureInitialized()`
- ✅ Most feature cubits created at route level

## Related Documentation

- [Lazy Loading Review](lazy_loading_review.md) - Comprehensive analysis of lazy loading patterns, `late` keyword usage, deferred imports explanation, and performance optimization opportunities
- [Bundle Size Monitoring](BUNDLE_SIZE_MONITORING.md) - Monitoring and optimizing app bundle size
- [Architecture Details](architecture_details.md)

## Tools Reference

- **Flutter DevTools:** `flutter pub global activate devtools && flutter pub global run devtools`
- **Startup Trace:** `flutter run --profile --trace-startup`
- **Performance Profiler:** `lib/shared/utils/performance_profiler.dart`
- **Bundle Size Check:** `tool/check_bundle_size.sh`
