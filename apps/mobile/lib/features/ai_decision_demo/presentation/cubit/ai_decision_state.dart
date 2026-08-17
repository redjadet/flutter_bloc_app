import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_failure.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_decision_state.freezed.dart';

@freezed
sealed class AiDecisionState with _$AiDecisionState {
  const factory AiDecisionState({
    @Default(true) bool isLoadingQueue,
    @Default(<AiDecisionCaseSummary>[]) List<AiDecisionCaseSummary> queue,
    String? selectedCaseId,
    AiDecisionCaseDetail? caseDetail,
    AiDecisionDecisionResult? decision,
    AiDecisionFailure? failure,
    @Default(false) bool isRunningDecision,
    @Default(false) bool isSavingAction,
  }) = _AiDecisionState;

  factory AiDecisionState.initial() => const AiDecisionState();
}
