import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_stream_config.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object> _validPayload({
  final int sequence = 1,
  final String sessionId = 'session-a',
  final int schemaVersion = 1,
}) {
  return <String, Object>{
    'schemaVersion': schemaVersion,
    'sessionId': sessionId,
    'bridgeEventSequence': sequence,
    'acceptedCount': 12,
    'sourceReceivedCount': 15,
    'averageValue': 42.5,
    'sourceRateHz': 60,
    'deliveredRateHz': 4,
    'droppedBeforeBridgeCount': 3,
    'nativeWindowStartedAtMillis': 1_700_000_000_000,
    'nativeEmittedAtMillis': 1_700_000_000_100,
  };
}

NativeShowcaseTelemetryStreamConfig _config({
  final String sessionId = 'session-a',
}) {
  return NativeShowcaseTelemetryStreamConfig.renderDefault(
    sessionId: sessionId,
  );
}

void main() {
  group('EventChannelNativeShowcaseTelemetryService', () {
    test('maps valid schema-v1 payload', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(
        events: (_) => controller.stream,
      );

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry(config: _config())
          .toList();
      controller.add(_validPayload());
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      final snapshot = snapshots.single;
      expect(snapshot.status, NativeShowcaseTelemetryStatus.streaming);
      expect(snapshot.schemaVersion, 1);
      expect(snapshot.sessionId, 'session-a');
      expect(snapshot.sequence, 1);
      expect(snapshot.acceptedCount, 12);
      expect(snapshot.sourceReceivedCount, 15);
      expect(snapshot.averageValue, 42.5);
      expect(snapshot.sourceRateHz, 60);
      expect(snapshot.deliveredRateHz, 4);
      expect(snapshot.droppedBeforeBridgeCount, 3);
    });

    test('serializes render config for channel arguments', () {
      final config = NativeShowcaseTelemetryStreamConfig(
        schemaVersion: 1,
        mode: NativeShowcaseTelemetryMode.render,
        maxDeliveryHz: 20,
        aggregation: NativeShowcaseTelemetryAggregation.latest,
        sessionId: 'abc',
      );

      expect(config.toChannelArguments(), <String, Object>{
        'schemaVersion': 1,
        'mode': 'render',
        'maxDeliveryHz': 15,
        'aggregation': 'latest',
        'sessionId': 'abc',
      });
    });

    test('ignores non-map event', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(
        events: (_) => controller.stream,
      );

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry(config: _config())
          .toList();
      controller
        ..add('not-a-map')
        ..add(_validPayload(sequence: 2));
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 2);
    });

    test('ignores invalid numeric payload', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(
        events: (_) => controller.stream,
      );

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry(config: _config())
          .toList();
      controller
        ..add(<String, Object?>{
          ..._validPayload(),
          'bridgeEventSequence': 'bad',
        })
        ..add(_validPayload(sequence: 3));
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 3);
    });

    test('ignores fractional integer fields in payload', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(
        events: (_) => controller.stream,
      );

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry(config: _config())
          .toList();
      controller
        ..add(<String, Object>{..._validPayload(), 'bridgeEventSequence': 1.9})
        ..add(_validPayload(sequence: 2));
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 2);
    });

    test('ignores wrong schema version', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(
        events: (_) => controller.stream,
      );

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry(config: _config())
          .toList();
      controller
        ..add(_validPayload(schemaVersion: 99))
        ..add(_validPayload(sequence: 2));
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 2);
    });

    test('ignores stale session id', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(
        events: (_) => controller.stream,
      );

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry(config: _config())
          .toList();
      controller
        ..add(_validPayload(sessionId: 'other-session'))
        ..add(_validPayload(sequence: 2));
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 2);
    });

    test('ignores sequence regression', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(
        events: (_) => controller.stream,
      );

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry(config: _config())
          .toList();
      controller
        ..add(_validPayload(sequence: 5))
        ..add(_validPayload(sequence: 4))
        ..add(_validPayload(sequence: 5))
        ..add(_validPayload(sequence: 6));
      await controller.close();

      final snapshots = await values;
      expect(snapshots.map((final s) => s.sequence), <int>[5, 6]);
    });

    test(
      'emits unavailable snapshot when injected event stream throws MissingPluginException',
      () async {
        final service = EventChannelNativeShowcaseTelemetryService(
          events: (_) =>
              Stream<Object?>.error(MissingPluginException('no handler')),
        );

        final snapshots = await service
            .watchTelemetry(config: _config())
            .toList();

        expect(snapshots, hasLength(1));
        expect(
          snapshots.single.status,
          NativeShowcaseTelemetryStatus.unavailable,
        );
        expect(snapshots.single.sessionId, 'session-a');
      },
    );
  });
}
