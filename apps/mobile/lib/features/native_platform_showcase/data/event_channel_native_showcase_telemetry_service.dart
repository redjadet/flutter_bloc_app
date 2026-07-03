import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';

const String kNativeShowcaseTelemetryChannel =
    'com.example.flutter_bloc_app/native_showcase/telemetry';

/// EventChannel implementation of [NativeShowcaseTelemetryService].
///
/// Maps compact aggregate maps from native into [NativeShowcaseTelemetrySnapshot].
/// Tests inject a custom event stream factory via the constructor; production
/// uses the default EventChannel broadcast stream.
class EventChannelNativeShowcaseTelemetryService
    implements NativeShowcaseTelemetryService {
  EventChannelNativeShowcaseTelemetryService({
    final Stream<Object?> Function()? events,
  }) : _events =
           events ??
           (() => const EventChannel(
             kNativeShowcaseTelemetryChannel,
           ).receiveBroadcastStream());

  final Stream<Object?> Function() _events;

  static final NativeShowcaseTelemetrySnapshot _unavailableSnapshot =
      NativeShowcaseTelemetrySnapshot(
        status: NativeShowcaseTelemetryStatus.unavailable,
        sequence: 0,
        sampleCount: 0,
        averageValue: 0,
        sourceRateHz: 0,
        deliveredRateHz: 0,
        droppedCount: 0,
        emittedAt: DateTime.fromMillisecondsSinceEpoch(0),
        message: 'Native telemetry stream unavailable on this platform.',
      );

  @override
  Stream<NativeShowcaseTelemetrySnapshot> watchTelemetry() async* {
    if (_isUnsupportedTarget) {
      yield _unavailableSnapshot;
      return;
    }

    try {
      await for (final Object? event in _events()) {
        final NativeShowcaseTelemetrySnapshot? snapshot = _mapEvent(event);
        if (snapshot != null) {
          yield snapshot;
        }
      }
    } on MissingPluginException {
      yield _unavailableSnapshot;
    }
  }

  static bool get _isUnsupportedTarget =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static NativeShowcaseTelemetrySnapshot? _mapEvent(final Object? event) {
    if (event is! Map) {
      return null;
    }

    final int? sequence = _readInt(event['sequence']);
    final int? sampleCount = _readInt(event['sampleCount']);
    final double? averageValue = _readDouble(event['averageValue']);
    final int? sourceRateHz = _readInt(event['sourceRateHz']);
    final int? deliveredRateHz = _readInt(event['deliveredRateHz']);
    final int? droppedCount = _readInt(event['droppedCount']);
    final int? emittedAtMillis = _readInt(event['emittedAtMillis']);

    if (sequence == null ||
        sampleCount == null ||
        averageValue == null ||
        sourceRateHz == null ||
        deliveredRateHz == null ||
        droppedCount == null ||
        emittedAtMillis == null) {
      return null;
    }

    return NativeShowcaseTelemetrySnapshot(
      status: NativeShowcaseTelemetryStatus.streaming,
      sequence: sequence,
      sampleCount: sampleCount,
      averageValue: averageValue,
      sourceRateHz: sourceRateHz,
      deliveredRateHz: deliveredRateHz,
      droppedCount: droppedCount,
      emittedAt: DateTime.fromMillisecondsSinceEpoch(
        emittedAtMillis,
        isUtc: true,
      ).toLocal(),
    );
  }

  static int? _readInt(final Object? value) {
    if (value is int) {
      return value;
    }
    return null;
  }

  static double? _readDouble(final Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
