import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/data/render_chat_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapRenderChatFailure', () {
    test('parses stable error JSON from Dio response', () {
      final DioException e = DioException(
        requestOptions: RequestOptions(path: '/v1/chat/completions'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/v1/chat/completions'),
          statusCode: 503,
          data: <String, dynamic>{
            'code': 'upstream_unavailable',
            'message': 'Busy',
            'retryable': true,
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final ChatRemoteFailureException out = mapRenderChatFailure(e);
      expect(out.code, 'upstream_unavailable');
      expect(out.retryable, isTrue);
    });

    test('maps connection timeout to upstream_timeout', () {
      final DioException e = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      final ChatRemoteFailureException out = mapRenderChatFailure(e);
      expect(out.code, 'upstream_timeout');
      expect(out.retryable, isTrue);
    });
  });
}
