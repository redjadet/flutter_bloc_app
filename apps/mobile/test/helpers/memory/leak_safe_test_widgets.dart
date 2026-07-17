import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

/// Tag selector for the Wave A memory-leak gate.
///
/// Run with: `bash tool/run_memory_leak_tests.sh`
const String memoryLeakTag = 'memory_leak';

/// Widget test that opts into leak tracking despite the global ignore in
/// `flutter_test_config.dart`.
///
/// Untagged tests stay ignored; this helper opts tagged tests back in via
/// [LeakTesting.settings.withTrackedAll].
void leakSafeTestWidgets(
  final String description,
  final WidgetTesterCallback callback, {
  final bool? skip,
}) {
  testWidgets(
    description,
    callback,
    skip: skip,
    tags: <String>[memoryLeakTag],
    experimentalLeakTesting: LeakTesting.settings.withTrackedAll(),
  );
}
