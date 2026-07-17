import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Tag selector for the memory-leak gate.
///
/// Run with: `bash tool/run_memory_leak_tests.sh`
const String memoryLeakTag = 'memory_leak';

/// Framework / compositor classes that often appear as notDisposed noise during
/// route replacement under `leak_tracker` (Wave B0/B1). Product disposables
/// (controllers, GoRouter delegates, streams) must stay tracked.
const List<String> memoryLeakHarnessLayerClasses = <String>[
  'OpacityLayer',
  'OffsetLayer',
  'TransformLayer',
  'PictureLayer',
  '_NativePicture',
  'ClipRectLayer',
  'ClipRRectLayer',
  'ClipPathLayer',
  'PhysicalModelLayer',
  'AnnotatedRegionLayer',
  'LeaderLayer',
  'FollowerLayer',
];

/// Widget test that opts into leak tracking despite the global ignore in
/// `flutter_test_config.dart`.
///
/// Untagged tests stay ignored; this helper opts tagged tests back in via
/// [LeakTesting.settings.withTrackedAll].
///
/// Pass [ignoredNotDisposedClasses] only for proven harness noise (e.g. layer
/// classes during `go` route replacement). Never ignore product owners.
void leakSafeTestWidgets(
  final String description,
  final WidgetTesterCallback callback, {
  final bool? skip,
  final List<String> ignoredNotDisposedClasses = const <String>[],
}) {
  LeakTesting settings = LeakTesting.settings.withTrackedAll();
  if (ignoredNotDisposedClasses.isNotEmpty) {
    settings = settings.withIgnored(
      notDisposed: <String, int?>{
        for (final String className in ignoredNotDisposedClasses)
          className: null,
      },
    );
  }
  testWidgets(
    description,
    callback,
    skip: skip,
    tags: <String>[memoryLeakTag],
    experimentalLeakTesting: settings,
  );
}
