import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_demo_proof_state.freezed.dart';

enum StaffDemoProofStatus {
  initial,
  editing,
  submitting,
  success,
  offlineQueued,
  error,
}

@freezed
abstract class StaffDemoProofState with _$StaffDemoProofState {
  const factory StaffDemoProofState({
    @Default(StaffDemoProofStatus.initial) StaffDemoProofStatus status,
    @Default(<String>[]) List<String> photoPaths,
    String? signaturePath,
    String? errorMessage,
    String? lastProofId,
  }) = _StaffDemoProofState;
}
