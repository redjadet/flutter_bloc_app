import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_timeclock_repository.dart';

enum StaffDemoTimeclockStatus {
  initial,
  ready,
  clockedIn,
  busy,
  error,
}

class StaffDemoTimeclockState extends Equatable {
  const StaffDemoTimeclockState({
    this.status = StaffDemoTimeclockStatus.initial,
    this.openEntryId,
    this.lastResult,
    this.errorMessage,
  });

  final StaffDemoTimeclockStatus status;
  final String? openEntryId;
  final StaffDemoClockResult? lastResult;
  final String? errorMessage;

  static const Object _unset = Object();

  StaffDemoTimeclockState copyWith({
    final StaffDemoTimeclockStatus? status,
    final Object? openEntryId = _unset,
    final Object? lastResult = _unset,
    final Object? errorMessage = _unset,
  }) => StaffDemoTimeclockState(
    status: status ?? this.status,
    openEntryId: identical(openEntryId, _unset)
        ? this.openEntryId
        : openEntryId as String?,
    lastResult: identical(lastResult, _unset)
        ? this.lastResult
        : lastResult as StaffDemoClockResult?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    openEntryId,
    lastResult,
    errorMessage,
  ];
}
