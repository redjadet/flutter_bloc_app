import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';

/// Logs location capture failures and returns nullable location for clock flows.
StaffDemoCapturedLocation? unwrapStaffDemoLocationResult(
  final Result<StaffDemoCapturedLocation> result,
  final String context,
) {
  final failure = result.failureOrNull;
  if (failure != null) {
    AppLogger.info(
      '$context: location capture failed (${failure.runtimeType})',
    );
  }
  return result.getOrNull();
}
