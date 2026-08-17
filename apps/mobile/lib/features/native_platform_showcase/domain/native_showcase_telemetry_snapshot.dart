import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_showcase_telemetry_snapshot.freezed.dart';

@freezed
abstract class NativeShowcaseTelemetrySnapshot
    with _$NativeShowcaseTelemetrySnapshot {
  const factory NativeShowcaseTelemetrySnapshot({
    required NativeShowcaseTelemetryStatus status,
    required int schemaVersion,
    required String sessionId,
    required int sequence,
    required int acceptedCount,
    required int sourceReceivedCount,
    required double averageValue,
    required int sourceRateHz,
    required int deliveredRateHz,
    required int droppedBeforeBridgeCount,
    required DateTime windowStartedAt,
    required DateTime emittedAt,
    String? message,
  }) = _NativeShowcaseTelemetrySnapshot;
}
