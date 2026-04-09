import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';

enum StaffDemoSessionStatus {
  initial,
  loading,
  ready,
  missingProfile,
  inactive,
  error,
}

class StaffDemoSessionState extends Equatable {
  const StaffDemoSessionState({
    this.status = StaffDemoSessionStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final StaffDemoSessionStatus status;
  final StaffDemoProfile? profile;
  final String? errorMessage;

  static const Object _unset = Object();

  StaffDemoSessionState copyWith({
    final StaffDemoSessionStatus? status,
    final StaffDemoProfile? profile,
    final Object? errorMessage = _unset,
  }) => StaffDemoSessionState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
  );

  @override
  List<Object?> get props => <Object?>[status, profile, errorMessage];
}
