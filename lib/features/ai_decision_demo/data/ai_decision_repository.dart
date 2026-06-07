import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_api_client.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_repository.dart';

class AiDecisionRepositoryImpl implements AiDecisionRepository {
  AiDecisionRepositoryImpl({required this.api});

  final AiDecisionApiClient api;

  @override
  Future<List<AiDecisionCaseSummary>> getCases() => api.getCases();

  @override
  Future<AiDecisionCaseDetail> getCaseDetail(final String caseId) =>
      api.getCaseDetail(caseId);

  @override
  Future<AiDecisionDecisionResult> runDecisionSupport({
    required final String caseId,
    required final String operatorNote,
  }) => api.runDecisionSupport(caseId: caseId, operatorNote: operatorNote);

  @override
  Future<void> createAction({
    required final String caseId,
    required final String actionType,
    required final String note,
  }) => api.createAction(caseId: caseId, actionType: actionType, note: note);
}
