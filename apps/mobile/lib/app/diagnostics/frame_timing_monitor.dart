import 'dart:collection';

import 'package:flutter/scheduler.dart';

/// Aggregated frame timing metrics for diagnostics cards.
class FrameTimingSummary {
  const FrameTimingSummary({
    required this.sampleCount,
    required this.p90Ms,
    required this.p99Ms,
    required this.missedOver16_7Ms,
  });

  static const FrameTimingSummary empty = FrameTimingSummary(
    sampleCount: 0,
    p90Ms: 0,
    p99Ms: 0,
    missedOver16_7Ms: 0,
  );

  final int sampleCount;
  final double p90Ms;
  final double p99Ms;
  final int missedOver16_7Ms;
}

/// Pure percentile math for unit tests and monitor updates.
FrameTimingSummary frameTimingSummaryFromDurationsMs(
  final List<double> samples, {
  final int maxSamples = 120,
}) {
  if (samples.isEmpty) {
    return FrameTimingSummary.empty;
  }

  final List<double> bounded = samples.length <= maxSamples
      ? List<double>.from(samples)
      : samples.sublist(samples.length - maxSamples);
  final List<double> sorted = List<double>.from(bounded)..sort();

  double percentile(final double p) {
    if (sorted.length == 1) {
      return sorted.first;
    }
    final double index = p * (sorted.length - 1);
    final int lower = index.floor();
    final int upper = index.ceil();
    if (lower == upper) {
      return sorted[lower];
    }
    final double weight = index - lower;
    return sorted[lower] * (1 - weight) + sorted[upper] * weight;
  }

  final int missed = bounded.where((final ms) => ms > 16.7).length;

  return FrameTimingSummary(
    sampleCount: bounded.length,
    p90Ms: percentile(0.9),
    p99Ms: percentile(0.99),
    missedOver16_7Ms: missed,
  );
}

/// Observes [SchedulerBinding] frame timings and exposes rolling summaries.
abstract interface class FrameTimingMonitor {
  void start({void Function(FrameTimingSummary summary)? onSummary});

  void stop();

  FrameTimingSummary get currentSummary;
}

class SchedulerFrameTimingMonitor implements FrameTimingMonitor {
  SchedulerFrameTimingMonitor({this.maxSamples = 120});

  final int maxSamples;
  final ListQueue<double> _durationsMs = ListQueue<double>();
  void Function(FrameTimingSummary summary)? _onSummary;
  bool _started = false;

  void _timingsCallback(final List<FrameTiming> timings) {
    for (final FrameTiming timing in timings) {
      final double ms = timing.totalSpan.inMicroseconds / 1000;
      _durationsMs.addLast(ms);
      while (_durationsMs.length > maxSamples) {
        _durationsMs.removeFirst();
      }
    }
    _onSummary?.call(currentSummary);
  }

  @override
  FrameTimingSummary get currentSummary => frameTimingSummaryFromDurationsMs(
    _durationsMs.toList(growable: false),
    maxSamples: maxSamples,
  );

  @override
  void start({void Function(FrameTimingSummary summary)? onSummary}) {
    if (_started) {
      _onSummary = onSummary;
      onSummary?.call(currentSummary);
      return;
    }
    _started = true;
    _onSummary = onSummary;
    SchedulerBinding.instance.addTimingsCallback(_timingsCallback);
    onSummary?.call(currentSummary);
  }

  @override
  void stop() {
    if (!_started) {
      return;
    }
    SchedulerBinding.instance.removeTimingsCallback(_timingsCallback);
    _started = false;
    _onSummary = null;
  }
}
