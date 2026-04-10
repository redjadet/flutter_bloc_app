import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_forms_state.freezed.dart';

enum StaffDemoFormsStatus { initial, submitting, success, error }

@freezed
abstract class StaffDemoFormsState with _$StaffDemoFormsState {
  const factory StaffDemoFormsState({
    @Default(StaffDemoFormsStatus.initial) final StaffDemoFormsStatus status,
    final String? errorMessage,
    final String? lastSubmitLabel,
  }) = _StaffDemoFormsState;
}
