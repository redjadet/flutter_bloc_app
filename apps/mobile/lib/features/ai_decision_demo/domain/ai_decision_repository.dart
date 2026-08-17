import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';

abstract interface class AiDecisionRepository {
  Future<List<AiDecisionCaseSummary>> getCases();

  Future<AiDecisionCaseDetail> getCaseDetail(String caseId);

  Future<AiDecisionDecisionResult> runDecisionSupport({
    required String caseId,
    required String operatorNote,
  });

  Future<void> createAction({
    required String caseId,
    required String actionType,
    required String note,
  });
}
