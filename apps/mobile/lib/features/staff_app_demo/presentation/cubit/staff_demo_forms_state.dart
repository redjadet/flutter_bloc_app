import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_forms_state.freezed.dart';

enum StaffDemoFormsStatus { initial, submitting, success, error }

/// Fixed validation/auth errors from StaffDemoFormsCubit; resolved in UI via l10n.
enum StaffDemoFormsKnownError { notSignedIn, siteIdRequired }

/// Which form action succeeded; resolved in UI via l10n.
enum StaffDemoFormsSuccessKind { availabilitySubmitted, managerReportSubmitted }

@freezed
abstract class StaffDemoFormsState with _$StaffDemoFormsState {
  const factory StaffDemoFormsState({
    @Default(StaffDemoFormsStatus.initial) StaffDemoFormsStatus status,
    String? errorMessage,
    StaffDemoFormsKnownError? knownError,
    StaffDemoFormsSuccessKind? lastSuccessKind,
  }) = _StaffDemoFormsState;
}
