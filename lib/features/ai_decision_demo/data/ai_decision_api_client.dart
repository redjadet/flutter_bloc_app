import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_models.dart';

class AiDecisionApiClient {
  AiDecisionApiClient({required final Dio dio}) : _dio = dio;

  final Dio _dio;

  static const String _baseUrl = String.fromEnvironment(
    'AI_DECISION_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8008',
  );

  Future<List<AiDecisionCaseSummary>> getCases() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/cases',
    );
    final cases = (response.data?['cases'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return cases.map(AiDecisionCaseSummary.fromJson).toList(growable: false);
  }

  Future<AiDecisionCaseDetail> getCaseDetail(final String caseId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/cases/$caseId',
    );
    final data = response.data;
    if (data == null) {
      throw Exception('AI Decision API returned empty case detail response.');
    }
    return AiDecisionCaseDetail.fromJson(data);
  }

  Future<AiDecisionDecisionResult> runDecisionSupport({
    required final String caseId,
    required final String operatorNote,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/cases/$caseId/decision',
      data: <String, dynamic>{'operator_note': operatorNote},
    );
    final data = response.data;
    if (data == null) {
      throw Exception('AI Decision API returned empty decision response.');
    }
    return AiDecisionDecisionResult.fromJson(data);
  }

  Future<void> createAction({
    required final String caseId,
    required final String actionType,
    required final String note,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/cases/$caseId/actions',
      data: <String, dynamic>{
        'action_type': actionType,
        'note': note,
      },
    );
    if (response.data == null) {
      // The API returns a response body; treat an empty body as an error so the
      // UI doesn't falsely assume persistence succeeded.
      throw Exception('AI Decision API returned empty action response.');
    }
  }
}
