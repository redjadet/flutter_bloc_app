import 'package:flutter_bloc_app/app/diagnostics/frame_timing_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('frameTimingSummaryFromDurationsMs', () {
    test('returns empty summary for no samples', () {
      final FrameTimingSummary summary = frameTimingSummaryFromDurationsMs(
        <double>[],
      );

      expect(summary.sampleCount, 0);
      expect(summary.p90Ms, 0);
      expect(summary.p99Ms, 0);
      expect(summary.missedOver16_7Ms, 0);
    });

    test('computes percentiles and missed frames', () {
      final FrameTimingSummary summary = frameTimingSummaryFromDurationsMs(
        <double>[10, 12, 16, 17, 20, 30, 40],
      );

      expect(summary.sampleCount, 7);
      expect(summary.p90Ms, greaterThan(16));
      expect(summary.p99Ms, greaterThan(summary.p90Ms));
      expect(summary.missedOver16_7Ms, 4);
    });

    test('bounds samples to maxSamples', () {
      final List<double> samples = List<double>.generate(150, (final int i) {
        return i.toDouble();
      });

      final FrameTimingSummary summary = frameTimingSummaryFromDurationsMs(
        samples,
        maxSamples: 120,
      );

      expect(summary.sampleCount, 120);
      expect(summary.p99Ms, closeTo(148, 2));
    });
  });
}
