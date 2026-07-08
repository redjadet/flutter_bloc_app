import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_dto.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/domain/ai_decision_models.dart';
import 'package:utilities/utilities.dart';

typedef _JsonMap = Map<String, dynamic>;
typedef _JsonMapper<T> = T Function(_JsonMap json);

class AiDecisionApiClient {
  AiDecisionApiClient({required this._dio});

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
    return _getJson<List<AiDecisionCaseSummary>>(
      '/cases',
      emptyResponseMessage:
          'AI Decision API returned empty case queue response.',
      mapper: (final json) {
        final cases = (json['cases'] as List<dynamic>? ?? <dynamic>[])
            .cast<_JsonMap>();
        return cases
            .map(AiDecisionCaseSummaryDto.fromJson)
            .map((final dto) => dto.toDomain())
            .toList(growable: false);
      },
    );
  }

  Future<AiDecisionCaseDetail> getCaseDetail(final String caseId) async {
    return _getJson<AiDecisionCaseDetail>(
      '/cases/$caseId',
      emptyResponseMessage:
          'AI Decision API returned empty case detail response.',
      mapper: (final json) => AiDecisionCaseDetailDto.fromJson(json).toDomain(),
    );
  }

  Future<AiDecisionDecisionResult> runDecisionSupport({
    required final String caseId,
    required final String operatorNote,
  }) async {
    return _postJson<AiDecisionDecisionResult>(
      '/cases/$caseId/decision',
      data: <String, dynamic>{'operator_note': operatorNote},
      emptyResponseMessage: 'AI Decision API returned empty decision response.',
      mapper: (final json) =>
          AiDecisionDecisionResultDto.fromJson(json).toDomain(),
    );
  }

  Future<void> createAction({
    required final String caseId,
    required final String actionType,
    required final String note,
  }) async {
    await _postJson<void>(
      '/cases/$caseId/actions',
      data: <String, dynamic>{
        'action_type': actionType,
        'note': note,
      },
      emptyResponseMessage: 'AI Decision API returned empty action response.',
      mapper: (_) {},
    );
  }

  Future<T> _getJson<T>(
    final String path, {
    required final String emptyResponseMessage,
    required final _JsonMapper<T> mapper,
  }) {
    return _sendJson<T>(
      () => _dio.get<_JsonMap>('$_baseUrl$path'),
      emptyResponseMessage: emptyResponseMessage,
      mapper: mapper,
    );
  }

  Future<T> _postJson<T>(
    final String path, {
    required final Map<String, dynamic> data,
    required final String emptyResponseMessage,
    required final _JsonMapper<T> mapper,
  }) {
    return _sendJson<T>(
      () => _dio.post<_JsonMap>('$_baseUrl$path', data: data),
      emptyResponseMessage: emptyResponseMessage,
      mapper: mapper,
    );
  }

  Future<T> _sendJson<T>(
    final Future<Response<_JsonMap>> Function() request, {
    required final String emptyResponseMessage,
    required final _JsonMapper<T> mapper,
  }) async {
    final response = await request();
    _throwIfFailure(response);
    final data = response.data;
    if (data == null) {
      throw Exception(emptyResponseMessage);
    }
    return mapper(data);
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
