import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_stream_config.dart';

class WatchNativeShowcaseTelemetryUseCase {
  WatchNativeShowcaseTelemetryUseCase(this._service);

  final NativeShowcaseTelemetryService _service;

  Stream<NativeShowcaseTelemetrySnapshot> call({
    required final NativeShowcaseTelemetryStreamConfig config,
  }) => _service.watchTelemetry(config: config);
}
