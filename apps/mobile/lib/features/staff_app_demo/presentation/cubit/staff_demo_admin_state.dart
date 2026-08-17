import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_admin_state.freezed.dart';

enum StaffDemoAdminStatus { initial, loading, ready, error }

@freezed
abstract class StaffDemoAdminState with _$StaffDemoAdminState {
  const factory StaffDemoAdminState({
    @Default(StaffDemoAdminStatus.initial) StaffDemoAdminStatus status,
    @Default(<StaffDemoTimeEntrySummary>[])
    List<StaffDemoTimeEntrySummary> recentEntries,
    String? errorMessage,
  }) = _StaffDemoAdminState;

  const StaffDemoAdminState._();
}
