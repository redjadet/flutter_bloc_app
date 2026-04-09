import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_time_entry_summary.dart';

enum StaffDemoAdminStatus { initial, loading, ready, error }

class StaffDemoAdminState extends Equatable {
  const StaffDemoAdminState({
    this.status = StaffDemoAdminStatus.initial,
    this.recentEntries = const <StaffDemoTimeEntrySummary>[],
    this.errorMessage,
  });

  final StaffDemoAdminStatus status;
  final List<StaffDemoTimeEntrySummary> recentEntries;
  final String? errorMessage;

  static const Object _unset = Object();

  StaffDemoAdminState copyWith({
    final StaffDemoAdminStatus? status,
    final List<StaffDemoTimeEntrySummary>? recentEntries,
    final Object? errorMessage = _unset,
  }) => StaffDemoAdminState(
    status: status ?? this.status,
    recentEntries: recentEntries ?? this.recentEntries,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
  );

  @override
  List<Object?> get props => <Object?>[status, recentEntries, errorMessage];
}
