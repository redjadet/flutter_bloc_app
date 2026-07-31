import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/diagnostics/frame_timing_monitor.dart';

/// Diagnostics bindings used by production readiness and related demos.
void registerProductionReadinessServices() {
  // Factory: each route visit gets its own monitor; cubit.stop() on close.
  registerFactoryIfAbsent<FrameTimingMonitor>(
    SchedulerFrameTimingMonitor.new,
  );
}
