import 'package:flutter_bloc_app/core/domain/result.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/data/staff_demo_location_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

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
