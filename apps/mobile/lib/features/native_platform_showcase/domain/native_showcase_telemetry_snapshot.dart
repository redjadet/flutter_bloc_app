import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_showcase_telemetry_snapshot.freezed.dart';

@freezed
abstract class NativeShowcaseTelemetrySnapshot
    with _$NativeShowcaseTelemetrySnapshot {
  const factory NativeShowcaseTelemetrySnapshot({
    required final NativeShowcaseTelemetryStatus status,
    required final int sequence,
    required final int sampleCount,
    required final double averageValue,
    required final int sourceRateHz,
    required final int deliveredRateHz,
    required final int droppedCount,
    required final DateTime emittedAt,
    final String? message,
  }) = _NativeShowcaseTelemetrySnapshot;
}
