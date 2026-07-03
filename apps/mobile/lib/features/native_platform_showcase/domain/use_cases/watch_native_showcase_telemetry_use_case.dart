import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';

class WatchNativeShowcaseTelemetryUseCase {
  WatchNativeShowcaseTelemetryUseCase(this._service);

  final NativeShowcaseTelemetryService _service;

  Stream<NativeShowcaseTelemetrySnapshot> call() => _service.watchTelemetry();
}
