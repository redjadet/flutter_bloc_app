import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_freshness.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NativeShowcaseTelemetryFreshnessTracker', () {
    late Duration elapsed;
    late NativeShowcaseTelemetryFreshnessTracker tracker;

    NativeShowcaseTelemetrySnapshot snapshot({
      required int sequence,
      required int acceptedCount,
    }) {
      return NativeShowcaseTelemetrySnapshot(
        status: NativeShowcaseTelemetryStatus.streaming,
        schemaVersion: 1,
        sessionId: 'session',
        sequence: sequence,
        acceptedCount: acceptedCount,
        sourceReceivedCount: 10,
        averageValue: 1.5,
        sourceRateHz: 60,
        deliveredRateHz: 4,
        droppedBeforeBridgeCount: 0,
        windowStartedAt: DateTime(2026),
        emittedAt: DateTime(2026),
      );
    }

    setUp(() {
      elapsed = Duration.zero;
      tracker = NativeShowcaseTelemetryFreshnessTracker(
        readElapsed: () => elapsed,
        valueFreshnessDeadline: const Duration(milliseconds: 1500),
        sourceLivenessDeadline: const Duration(milliseconds: 750),
      );
    });

    test('value update starts with zero ages and fresh/live flags', () {
      final NativeShowcaseTelemetryFreshness? freshness = tracker.onSnapshot(
        snapshot(sequence: 1, acceptedCount: 4),
      );

      expect(
        freshness,
        const NativeShowcaseTelemetryFreshness(
          isValueStale: false,
          isSourceLive: true,
          receiptAge: Duration.zero,
          valueAge: Duration.zero,
        ),
      );
    });

    test('liveness tick refreshes receipt age only', () {
      tracker.onSnapshot(snapshot(sequence: 1, acceptedCount: 4));

      elapsed = const Duration(milliseconds: 400);
      final NativeShowcaseTelemetryFreshness? afterLiveness = tracker
          .onSnapshot(snapshot(sequence: 2, acceptedCount: 0));

      expect(afterLiveness?.isValueStale, isFalse);
      expect(afterLiveness?.isSourceLive, isTrue);
      expect(afterLiveness?.valueAge, const Duration(milliseconds: 400));
      expect(afterLiveness?.receiptAge, Duration.zero);
    });

    test('deadline check marks stale without a new event', () {
      tracker.onSnapshot(snapshot(sequence: 1, acceptedCount: 2));

      expect(
        tracker.evaluateAt(const Duration(milliseconds: 1499))?.isValueStale,
        isFalse,
      );
      expect(
        tracker.evaluateAt(const Duration(milliseconds: 1501))?.isValueStale,
        isTrue,
      );
      expect(
        tracker.evaluateAt(const Duration(milliseconds: 1501))?.isSourceLive,
        isFalse,
      );
    });

    test('source stays live on recent receipt while value can be stale', () {
      tracker.onSnapshot(snapshot(sequence: 1, acceptedCount: 3));

      elapsed = const Duration(milliseconds: 1600);
      final NativeShowcaseTelemetryFreshness? afterLiveness = tracker
          .onSnapshot(snapshot(sequence: 2, acceptedCount: 0));

      expect(afterLiveness?.isValueStale, isTrue);
      expect(afterLiveness?.isSourceLive, isTrue);
      expect(afterLiveness?.valueAge, const Duration(milliseconds: 1600));
      expect(afterLiveness?.receiptAge, Duration.zero);
    });
  });
}
