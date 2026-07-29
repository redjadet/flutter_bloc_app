import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_stream_config.dart';

abstract interface class NativeShowcaseTelemetryService {
  Stream<NativeShowcaseTelemetrySnapshot> watchTelemetry({
    required final NativeShowcaseTelemetryStreamConfig config,
  });
}
