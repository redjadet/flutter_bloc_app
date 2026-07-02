import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventChannelNativeShowcaseTelemetryService', () {
    test('maps valid payload', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(events: () => controller.stream);

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry()
          .toList();
      controller.add(<String, Object>{
        'sequence': 1,
        'sampleCount': 12,
        'averageValue': 42.5,
        'sourceRateHz': 60,
        'deliveredRateHz': 4,
        'droppedCount': 3,
        'emittedAtMillis': 1_700_000_000_000,
      });
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      final snapshot = snapshots.single;
      expect(snapshot.status, NativeShowcaseTelemetryStatus.streaming);
      expect(snapshot.sequence, 1);
      expect(snapshot.sampleCount, 12);
      expect(snapshot.averageValue, 42.5);
      expect(snapshot.sourceRateHz, 60);
      expect(snapshot.deliveredRateHz, 4);
      expect(snapshot.droppedCount, 3);
    });

    test('ignores non-map event', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(events: () => controller.stream);

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry()
          .toList();
      controller
        ..add('not-a-map')
        ..add(<String, Object>{
          'sequence': 2,
          'sampleCount': 1,
          'averageValue': 1.0,
          'sourceRateHz': 60,
          'deliveredRateHz': 4,
          'droppedCount': 0,
          'emittedAtMillis': 1_700_000_000_001,
        });
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 2);
    });

    test('ignores invalid numeric payload', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(events: () => controller.stream);

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry()
          .toList();
      controller
        ..add(<String, Object?>{
          'sequence': 'bad',
          'sampleCount': 1,
          'averageValue': 1.0,
          'sourceRateHz': 60,
          'deliveredRateHz': 4,
          'droppedCount': 0,
          'emittedAtMillis': 1,
        })
        ..add(<String, Object>{
          'sequence': 3,
          'sampleCount': 1,
          'averageValue': 2.0,
          'sourceRateHz': 60,
          'deliveredRateHz': 4,
          'droppedCount': 0,
          'emittedAtMillis': 2,
        });
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 3);
    });

    test('ignores fractional integer fields in payload', () async {
      final StreamController<Object?> controller = StreamController<Object?>();
      final service = EventChannelNativeShowcaseTelemetryService(events: () => controller.stream);

      final Future<List<NativeShowcaseTelemetrySnapshot>> values = service
          .watchTelemetry()
          .toList();
      controller
        ..add(<String, Object>{
          'sequence': 1.9,
          'sampleCount': 1,
          'averageValue': 1.0,
          'sourceRateHz': 60,
          'deliveredRateHz': 4,
          'droppedCount': 0,
          'emittedAtMillis': 1,
        })
        ..add(<String, Object>{
          'sequence': 2,
          'sampleCount': 1,
          'averageValue': 2.0,
          'sourceRateHz': 60,
          'deliveredRateHz': 4,
          'droppedCount': 0,
          'emittedAtMillis': 2,
        });
      await controller.close();

      final snapshots = await values;
      expect(snapshots, hasLength(1));
      expect(snapshots.single.sequence, 2);
    });

    test(
      'emits unavailable snapshot when injected event stream throws MissingPluginException',
      () async {
        final service = EventChannelNativeShowcaseTelemetryService(
          events: () => Stream<Object?>.error(MissingPluginException('no handler')),
        );

        final snapshots = await service.watchTelemetry().toList();

        expect(snapshots, hasLength(1));
        expect(snapshots.single.status, NativeShowcaseTelemetryStatus.unavailable);
      },
    );
  });
}
