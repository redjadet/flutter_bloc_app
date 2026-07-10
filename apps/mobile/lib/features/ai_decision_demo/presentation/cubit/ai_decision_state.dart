import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_decision_state.freezed.dart';

@freezed
sealed class AiDecisionState with _$AiDecisionState {
  const factory AiDecisionState({
    @Default(true) final bool isLoadingQueue,
    @Default(<AiDecisionCaseSummary>[]) final List<AiDecisionCaseSummary> queue,
    final String? selectedCaseId,
    final AiDecisionCaseDetail? caseDetail,
    final AiDecisionDecisionResult? decision,
    final String? errorMessage,
    @Default(false) final bool isRunningDecision,
    @Default(false) final bool isSavingAction,
  }) = _AiDecisionState;

  factory AiDecisionState.initial() => const AiDecisionState();
}
