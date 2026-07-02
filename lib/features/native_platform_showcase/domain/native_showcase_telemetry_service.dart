import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';

abstract interface class NativeShowcaseTelemetryService {
  Stream<NativeShowcaseTelemetrySnapshot> watchTelemetry();
}
