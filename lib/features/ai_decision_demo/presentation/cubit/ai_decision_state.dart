import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_models.dart';

class AiDecisionState {
  const AiDecisionState({
    required this.isLoadingQueue,
    required this.queue,
    required this.selectedCaseId,
    required this.caseDetail,
    required this.decision,
    required this.errorMessage,
    required this.isRunningDecision,
    required this.isSavingAction,
  });

  factory AiDecisionState.initial() => const AiDecisionState(
    isLoadingQueue: true,
    queue: <AiDecisionCaseSummary>[],
    selectedCaseId: null,
    caseDetail: null,
    decision: null,
    errorMessage: null,
    isRunningDecision: false,
    isSavingAction: false,
  );

  final bool isLoadingQueue;
  final List<AiDecisionCaseSummary> queue;
  final String? selectedCaseId;
  final AiDecisionCaseDetail? caseDetail;
  final AiDecisionDecisionResult? decision;
  final String? errorMessage;
  final bool isRunningDecision;
  final bool isSavingAction;

  AiDecisionState copyWith({
    final bool? isLoadingQueue,
    final List<AiDecisionCaseSummary>? queue,
    final String? selectedCaseId,
    final AiDecisionCaseDetail? caseDetail,
    final AiDecisionDecisionResult? decision,
    final String? errorMessage,
    final bool? isRunningDecision,
    final bool? isSavingAction,
    final bool clearError = false,
    final bool clearCaseDetail = false,
    final bool clearDecision = false,
  }) => AiDecisionState(
    isLoadingQueue: isLoadingQueue ?? this.isLoadingQueue,
    queue: queue ?? this.queue,
    selectedCaseId: selectedCaseId ?? this.selectedCaseId,
    caseDetail: clearCaseDetail ? null : (caseDetail ?? this.caseDetail),
    decision: clearDecision ? null : (decision ?? this.decision),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    isRunningDecision: isRunningDecision ?? this.isRunningDecision,
    isSavingAction: isSavingAction ?? this.isSavingAction,
  );
}
