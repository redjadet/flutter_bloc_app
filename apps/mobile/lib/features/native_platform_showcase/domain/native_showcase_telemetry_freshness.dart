import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:meta/meta.dart';

/// Presentation-safe freshness signals for the native telemetry demo.
///
/// [receiptAge] is how long ago Dart last heard from the host (any bridge
/// event, including liveness ticks). [valueAge] is how long ago an accepted
/// sample updated the displayed value. Those ages are separate: duplicate
/// filtering can keep the channel quiet or emit liveness-only events while
/// the displayed reading grows older.
///
/// Ages are derived from a monotonic elapsed reader (normally a [Stopwatch]),
/// not wall-clock `DateTime.now()`, so the local freshness deadline is not
/// skewed by clock adjustments. Native `emittedAt` / `windowStartedAt` remain
/// host-relative timing and are not compared to Dart wall time for this
/// deadline.
@immutable
class NativeShowcaseTelemetryFreshness {
  const NativeShowcaseTelemetryFreshness({
    required this.isValueStale,
    required this.isSourceLive,
    required this.receiptAge,
    required this.valueAge,
  });

  final bool isValueStale;
  final bool isSourceLive;
  final Duration receiptAge;
  final Duration valueAge;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is NativeShowcaseTelemetryFreshness &&
            other.isValueStale == isValueStale &&
            other.isSourceLive == isSourceLive &&
            other.receiptAge == receiptAge &&
            other.valueAge == valueAge);
  }

  @override
  int get hashCode =>
      Object.hash(isValueStale, isSourceLive, receiptAge, valueAge);

  @override
  String toString() {
    return 'NativeShowcaseTelemetryFreshness('
        'isValueStale: $isValueStale, '
        'isSourceLive: $isSourceLive, '
        'receiptAge: $receiptAge, '
        'valueAge: $valueAge)';
  }
}

/// Monotonic tracker that separates receipt liveness from displayed-value age.
class NativeShowcaseTelemetryFreshnessTracker {
  NativeShowcaseTelemetryFreshnessTracker({
    Duration Function()? readElapsed,
    this.valueFreshnessDeadline = defaultValueFreshnessDeadline,
    this.sourceLivenessDeadline = defaultSourceLivenessDeadline,
  }) : _readElapsed = readElapsed ?? _ownedStopwatchReader(_ownedStopwatch());

  /// Default local deadline for marking the displayed value stale.
  ///
  /// At the demo's 4 Hz render budget this is about six delivery windows —
  /// long enough that quiet duplicate filtering is visible as staleness
  /// without flapping on every skipped window.
  static const Duration defaultValueFreshnessDeadline = Duration(
    milliseconds: 1500,
  );

  /// Default deadline for treating the native source as live.
  ///
  /// Hosts emit explicit liveness ticks when a window received source samples
  /// but accepted none (all filtered as duplicates), so a healthy quiet
  /// channel still refreshes [receiptAge].
  static const Duration defaultSourceLivenessDeadline = Duration(
    milliseconds: 750,
  );

  /// How often the Cubit re-evaluates freshness without waiting for an event.
  static const Duration tickInterval = Duration(milliseconds: 250);

  final Duration Function() _readElapsed;
  final Duration valueFreshnessDeadline;
  final Duration sourceLivenessDeadline;

  Duration? _lastReceiptElapsed;
  Duration? _lastValueAcceptedElapsed;

  static Stopwatch _ownedStopwatch() => Stopwatch()..start();

  static Duration Function() _ownedStopwatchReader(Stopwatch stopwatch) {
    return () => stopwatch.elapsed;
  }

  /// Records a validated bridge snapshot using monotonic elapsed time.
  ///
  /// Any streaming event updates receipt time. Only events with
  /// [NativeShowcaseTelemetrySnapshot.acceptedCount] `> 0` refresh the
  /// displayed-value age.
  ///
  /// Returns the freshness **at receipt** (both ages are zero when this event
  /// also refreshed the value; liveness-only events keep the prior value age).
  NativeShowcaseTelemetryFreshness? onSnapshot(
    NativeShowcaseTelemetrySnapshot snapshot,
  ) {
    final Duration elapsed = _readElapsed();
    _lastReceiptElapsed = elapsed;
    if (snapshot.acceptedCount > 0) {
      _lastValueAcceptedElapsed = elapsed;
    }
    return evaluateAt(elapsed);
  }

  /// Evaluates freshness at the current monotonic elapsed time.
  ///
  /// Call from a periodic timer so a paused or interrupted stream can flip to
  /// stale without a new event arriving.
  NativeShowcaseTelemetryFreshness? evaluate() => evaluateAt(_readElapsed());

  /// Pure evaluation seam used by unit tests and by [evaluate].
  @visibleForTesting
  NativeShowcaseTelemetryFreshness? evaluateAt(Duration elapsed) {
    final Duration? lastReceipt = _lastReceiptElapsed;
    final Duration? lastValueAccepted = _lastValueAcceptedElapsed;
    if (lastReceipt == null || lastValueAccepted == null) {
      return null;
    }

    final Duration receiptAge = _nonNegative(elapsed - lastReceipt);
    final Duration valueAge = _nonNegative(elapsed - lastValueAccepted);

    return NativeShowcaseTelemetryFreshness(
      isValueStale: valueAge > valueFreshnessDeadline,
      isSourceLive: receiptAge <= sourceLivenessDeadline,
      receiptAge: receiptAge,
      valueAge: valueAge,
    );
  }

  static Duration _nonNegative(Duration value) =>
      value < Duration.zero ? Duration.zero : value;
}
