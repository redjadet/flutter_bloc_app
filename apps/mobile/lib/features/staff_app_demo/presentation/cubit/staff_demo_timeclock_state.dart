import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_timeclock_state.freezed.dart';

enum StaffDemoTimeclockStatus {
  initial,
  ready,
  clockedIn,
  busy,
  error,
}

@freezed
abstract class StaffDemoTimeclockState with _$StaffDemoTimeclockState {
  const factory StaffDemoTimeclockState({
    @Default(StaffDemoTimeclockStatus.initial) StaffDemoTimeclockStatus status,
    String? openEntryId,
    StaffDemoClockResult? lastResult,
    String? errorMessage,
  }) = _StaffDemoTimeclockState;
}
