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
    @Default(StaffDemoProofStatus.initial) final StaffDemoProofStatus status,
    @Default(<String>[]) final List<String> photoPaths,
    final String? signaturePath,
    final String? errorMessage,
    final String? lastProofId,
  }) = _StaffDemoProofState;
}
