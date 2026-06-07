import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';

abstract interface class AiDecisionRepository {
  Future<List<AiDecisionCaseSummary>> getCases();

  Future<AiDecisionCaseDetail> getCaseDetail(final String caseId);

  Future<AiDecisionDecisionResult> runDecisionSupport({
    required final String caseId,
    required final String operatorNote,
  });

  Future<void> createAction({
    required final String caseId,
    required final String actionType,
    required final String note,
  });
}
