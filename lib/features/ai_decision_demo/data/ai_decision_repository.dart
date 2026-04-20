import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_api_client.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_models.dart';

class AiDecisionRepository {
  AiDecisionRepository({required this.api});

  final AiDecisionApiClient api;

  Future<List<AiDecisionCaseSummary>> getCases() => api.getCases();

  Future<AiDecisionCaseDetail> getCaseDetail(final String caseId) =>
      api.getCaseDetail(caseId);

  Future<AiDecisionDecisionResult> runDecisionSupport({
    required final String caseId,
    required final String operatorNote,
  }) => api.runDecisionSupport(caseId: caseId, operatorNote: operatorNote);

  Future<void> createAction({
    required final String caseId,
    required final String actionType,
    required final String note,
  }) => api.createAction(caseId: caseId, actionType: actionType, note: note);
}
