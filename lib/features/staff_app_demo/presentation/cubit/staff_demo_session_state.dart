import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_session_state.freezed.dart';

enum StaffDemoSessionStatus {
  initial,
  loading,
  ready,
  missingProfile,
  inactive,
  error,
}

@freezed
abstract class StaffDemoSessionState with _$StaffDemoSessionState {
  const factory StaffDemoSessionState({
    @Default(StaffDemoSessionStatus.initial)
    final StaffDemoSessionStatus status,
    final StaffDemoProfile? profile,
    final String? errorMessage,
  }) = _StaffDemoSessionState;
}
