import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/ai_decision_demo/data/ai_decision_api_client.dart';
import 'package:utilities/utilities.dart';
import 'package:flutter_test/flutter_test.dart';

Dio _mockDio({
  required final Map<String, dynamic>? body,
  required final int statusCode,
  void Function(RequestOptions options)? onRequest,
}) {
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (final options, final handler) {
        onRequest?.call(options);
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

    test(
      'maps case queue response through typed generic request helper',
      () async {
        late RequestOptions request;
        final client = AiDecisionApiClient(
          dio: _mockDio(
            body: const {
              'cases': [
                {
                  'id': 'case-1',
                  'applicant_name': 'Ada Lovelace',
                  'business_name': 'Analytical Engines',
                  'amount': 12000,
                  'status': 'review',
                  'last_decision_band': 'medium',
                },
              ],
            },
            statusCode: 200,
            onRequest: (final options) => request = options,
          ),
        );

        final cases = await client.getCases();

        expect(request.method, 'GET');
        expect(request.uri.path, '/cases');
        expect(cases, hasLength(1));
        expect(cases.single.id, 'case-1');
        expect(cases.single.amount, 12000);
      },
    );

    test('posts action payload and rejects empty success body', () async {
      late RequestOptions request;
      final client = AiDecisionApiClient(
        dio: _mockDio(
          body: null,
          statusCode: 200,
          onRequest: (final options) => request = options,
        ),
      );

      await expectLater(
        client.createAction(
          caseId: 'case-1',
          actionType: 'call',
          note: 'Follow up',
        ),
        throwsA(
          isA<Exception>().having(
            (final e) => e.toString(),
            'message',
            contains('AI Decision API returned empty action response.'),
          ),
        ),
      );
      expect(request.method, 'POST');
      expect(request.uri.path, '/cases/case-1/actions');
      expect(request.data, <String, dynamic>{
        'action_type': 'call',
        'note': 'Follow up',
      });
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
