import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_api_client.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
import 'package:flutter_test/flutter_test.dart';

Dio _mockDio({
  required final Map<String, dynamic> body,
  required final int statusCode,
}) {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (final options, final handler) {
        handler.resolve(
          Response<Map<String, dynamic>>(
            data: body,
            statusCode: statusCode,
            requestOptions: options,
          ),
        );
      },
    ),
  );
  return dio;
}

void main() {
  group('AiDecisionApiClient', () {
    test('defaults to the FastAPI Cloud backend', () {
      expect(
        AiDecisionApiClient.resolveBaseUrlForPlatform(),
        'https://ai-decision-api.fastapicloud.dev',
      );
    });

    test('uses explicit dart-define backend URL on every platform', () {
      expect(
        AiDecisionApiClient.resolveBaseUrlForPlatform(
          configuredBaseUrl: ' https://custom.example.dev ',
        ),
        'https://custom.example.dev',
      );
    });

    test('throws HttpRequestFailure for non-success case queue responses', () {
      final client = AiDecisionApiClient(
        dio: _mockDio(
          body: const {'detail': 'backend_unavailable'},
          statusCode: 503,
        ),
      );

      expect(
        client.getCases(),
        throwsA(
          isA<HttpRequestFailure>()
              .having((final e) => e.statusCode, 'statusCode', 503)
              .having((final e) => e.message, 'message', 'backend_unavailable'),
        ),
      );
    });
  });
}
