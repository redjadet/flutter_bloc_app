import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_stream_config.dart';

const String kNativeShowcaseTelemetryChannel =
    'com.example.flutter_bloc_app/native_showcase/telemetry';

/// EventChannel implementation of [NativeShowcaseTelemetryService].
///
/// Maps schema-v1 aggregate maps from native into
/// [NativeShowcaseTelemetrySnapshot]. Tests inject a custom event stream
/// factory via the constructor; production uses the default EventChannel
/// broadcast stream with [NativeShowcaseTelemetryStreamConfig] arguments.
class EventChannelNativeShowcaseTelemetryService
    implements NativeShowcaseTelemetryService {
  EventChannelNativeShowcaseTelemetryService({
    Stream<Object?> Function(NativeShowcaseTelemetryStreamConfig config)?
    events,
  }) : _events =
           events ??
           ((NativeShowcaseTelemetryStreamConfig config) => const EventChannel(
             kNativeShowcaseTelemetryChannel,
           ).receiveBroadcastStream(config.toChannelArguments()));

  final Stream<Object?> Function(NativeShowcaseTelemetryStreamConfig config)
  _events;

  @override
  Stream<NativeShowcaseTelemetrySnapshot> watchTelemetry({
    required NativeShowcaseTelemetryStreamConfig config,
  }) async* {
    if (_isUnsupportedTarget) {
      yield _unavailableSnapshot(config.sessionId);
      return;
    }

    var lastSequence = 0;

    try {
      await for (final Object? event in _events(config)) {
        final NativeShowcaseTelemetrySnapshot? snapshot = _mapEvent(
          event,
          expectedSessionId: config.sessionId,
          lastSequence: lastSequence,
        );
        if (snapshot != null) {
          lastSequence = snapshot.sequence;
          yield snapshot;
        }
      }
    } on MissingPluginException {
      yield _unavailableSnapshot(config.sessionId);
    }
  }

  static bool get _isUnsupportedTarget =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  static NativeShowcaseTelemetrySnapshot _unavailableSnapshot(
    String sessionId,
  ) {
    return NativeShowcaseTelemetrySnapshot(
      status: NativeShowcaseTelemetryStatus.unavailable,
      schemaVersion: NativeShowcaseTelemetryStreamConfig.supportedSchemaVersion,
      sessionId: sessionId,
      sequence: 0,
      acceptedCount: 0,
      sourceReceivedCount: 0,
      averageValue: 0,
      sourceRateHz: 0,
      deliveredRateHz: 0,
      droppedBeforeBridgeCount: 0,
      windowStartedAt: DateTime.fromMillisecondsSinceEpoch(0),
      emittedAt: DateTime.fromMillisecondsSinceEpoch(0),
      message: 'Native telemetry stream unavailable on this platform.',
    );
  }

  static NativeShowcaseTelemetrySnapshot? _mapEvent(
    Object? event, {
    required String expectedSessionId,
    required int lastSequence,
  }) {
    if (event is! Map) {
      return null;
    }

    final int? schemaVersion = _readInt(event['schemaVersion']);
    final String? sessionId = _readNonEmptyString(event['sessionId']);
    final int? sequence = _readInt(event['bridgeEventSequence']);
    final int? acceptedCount = _readInt(event['acceptedCount']);
    final int? sourceReceivedCount = _readInt(event['sourceReceivedCount']);
    final double? averageValue = _readDouble(event['averageValue']);
    final int? sourceRateHz = _readInt(event['sourceRateHz']);
    final int? deliveredRateHz = _readInt(event['deliveredRateHz']);
    final int? droppedBeforeBridgeCount = _readInt(
      event['droppedBeforeBridgeCount'],
    );
    final int? windowStartedAtMillis = _readInt(
      event['nativeWindowStartedAtMillis'],
    );
    final int? emittedAtMillis = _readInt(event['nativeEmittedAtMillis']);

    if (schemaVersion == null ||
        schemaVersion !=
            NativeShowcaseTelemetryStreamConfig.supportedSchemaVersion ||
        sessionId == null ||
        sessionId != expectedSessionId ||
        sequence == null ||
        acceptedCount == null ||
        sourceReceivedCount == null ||
        averageValue == null ||
        sourceRateHz == null ||
        deliveredRateHz == null ||
        droppedBeforeBridgeCount == null ||
        windowStartedAtMillis == null ||
        emittedAtMillis == null) {
      return null;
    }

    if (sequence <= lastSequence) {
      return null;
    }

    return NativeShowcaseTelemetrySnapshot(
      status: NativeShowcaseTelemetryStatus.streaming,
      schemaVersion: schemaVersion,
      sessionId: sessionId,
      sequence: sequence,
      acceptedCount: acceptedCount,
      sourceReceivedCount: sourceReceivedCount,
      averageValue: averageValue,
      sourceRateHz: sourceRateHz,
      deliveredRateHz: deliveredRateHz,
      droppedBeforeBridgeCount: droppedBeforeBridgeCount,
      windowStartedAt: DateTime.fromMillisecondsSinceEpoch(
        windowStartedAtMillis,
        isUtc: true,
      ).toLocal(),
      emittedAt: DateTime.fromMillisecondsSinceEpoch(
        emittedAtMillis,
        isUtc: true,
      ).toLocal(),
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    return null;
  }

  static double? _readDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static String? _readNonEmptyString(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}
