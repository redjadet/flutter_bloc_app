import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_models.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';

class AiDecisionApiClient {
  AiDecisionApiClient({required final Dio dio}) : _dio = dio;

  final Dio _dio;

  static const String _configuredBaseUrl = String.fromEnvironment(
    'AI_DECISION_API_BASE_URL',
  );
  static const String _defaultBaseUrl =
      'https://ai-decision-api.fastapicloud.dev';

  static String get _baseUrl => resolveBaseUrlForPlatform();

  @visibleForTesting
  static String resolveBaseUrlForPlatform({
    final String configuredBaseUrl = _configuredBaseUrl,
  }) {
    final configured = configuredBaseUrl.trim();
    if (configured.isNotEmpty) {
      return configured;
    }
    return _defaultBaseUrl;
  }

  Future<List<AiDecisionCaseSummary>> getCases() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/cases',
    );
    _throwIfFailure(response);
    final cases = (response.data?['cases'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return cases.map(AiDecisionCaseSummary.fromJson).toList(growable: false);
  }

  Future<AiDecisionCaseDetail> getCaseDetail(final String caseId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/cases/$caseId',
    );
    _throwIfFailure(response);
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
    _throwIfFailure(response);
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
    _throwIfFailure(response);
    if (response.data == null) {
      // The API returns a response body; treat an empty body as an error so the
      // UI doesn't falsely assume persistence succeeded.
      throw Exception('AI Decision API returned empty action response.');
    }
  }

  static void _throwIfFailure(final Response<dynamic> response) {
    final statusCode = response.statusCode;
    if (statusCode == null || (statusCode >= 200 && statusCode < 300)) {
      return;
    }
    throw HttpRequestFailure(statusCode, _failureMessage(response));
  }

  static String _failureMessage(final Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    final statusMessage = response.statusMessage;
    if (statusMessage != null && statusMessage.trim().isNotEmpty) {
      return statusMessage;
    }
    return 'AI Decision API request failed.';
  }
}
