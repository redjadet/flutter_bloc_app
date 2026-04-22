import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/render_caller_auth_header_provider.dart';
import 'package:flutter_bloc_app/features/chat/data/render_fastapi_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCaller implements RenderCallerAuthHeaderProvider {
  @override
  Future<String?> bearerIdToken({final bool forceRefresh = false}) async =>
      'id-token';
}

class _FakeHf implements RenderOrchestrationHfTokenProvider {
  @override
  Future<void> clearRenderOrchestrationTokenCache() async {}

  @override
  Future<String?> readHfTokenForUpstream() async => 'hf-token';
}

class _EmptyHf implements RenderOrchestrationHfTokenProvider {
  @override
  Future<void> clearRenderOrchestrationTokenCache() async {}

  @override
  Future<String?> readHfTokenForUpstream() async => null;
}

Dio _dioThatCapturesPayload(
  final void Function(Map<String, dynamic> payload) capture,
) {
  final Dio dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest:
          (
            final RequestOptions options,
            final RequestInterceptorHandler handler,
          ) {
            final Object? raw = options.data;
            expect(raw, isA<Map<String, dynamic>>());
            capture(Map<String, dynamic>.from(raw! as Map<dynamic, dynamic>));
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                headers: Headers.fromMap(<String, List<String>>{
                  'content-type': <String>['application/json'],
                }),
                data: <String, dynamic>{
                  'choices': <Map<String, dynamic>>[
                    <String, dynamic>{
                      'message': <String, dynamic>{'content': 'ok'},
                    },
                  ],
                },
              ),
            );
          },
    ),
  );
  return dio;
}

void main() {
  group('RenderFastApiChatRepository', () {
    test('defaults missing model to orchestration auto sentinel', () async {
      Map<String, dynamic>? seen;
      final RenderFastApiChatRepository repo = RenderFastApiChatRepository(
        dio: _dioThatCapturesPayload(
          (final Map<String, dynamic> p) => seen = p,
        ),
        payloadBuilder: const HuggingFacePayloadBuilder(),
        responseParser: const HuggingFaceResponseParser(fallbackMessage: ''),
        callerAuth: _FakeCaller(),
        hfTokenProvider: _FakeHf(),
        isRunnable: () => true,
      );

      await repo.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'hello',
        model: null,
      );

      expect(seen, isNotNull);
      expect(seen!['model'], kChatOrchestrationAutoModelId);
    });

    test('defaults blank model to orchestration auto sentinel', () async {
      Map<String, dynamic>? seen;
      final RenderFastApiChatRepository repo = RenderFastApiChatRepository(
        dio: _dioThatCapturesPayload(
          (final Map<String, dynamic> p) => seen = p,
        ),
        payloadBuilder: const HuggingFacePayloadBuilder(),
        responseParser: const HuggingFaceResponseParser(fallbackMessage: ''),
        callerAuth: _FakeCaller(),
        hfTokenProvider: _FakeHf(),
        isRunnable: () => true,
      );

      await repo.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'hello',
        model: '   ',
      );

      expect(seen, isNotNull);
      expect(seen!['model'], kChatOrchestrationAutoModelId);
    });

    test('passes explicit model unchanged', () async {
      Map<String, dynamic>? seen;
      final RenderFastApiChatRepository repo = RenderFastApiChatRepository(
        dio: _dioThatCapturesPayload(
          (final Map<String, dynamic> p) => seen = p,
        ),
        payloadBuilder: const HuggingFacePayloadBuilder(),
        responseParser: const HuggingFaceResponseParser(fallbackMessage: ''),
        callerAuth: _FakeCaller(),
        hfTokenProvider: _FakeHf(),
        isRunnable: () => true,
      );

      await repo.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'hello',
        model: 'openai/gpt-oss-120b',
      );

      expect(seen, isNotNull);
      expect(seen!['model'], 'openai/gpt-oss-120b');
    });

    test('throws token_missing when HF read token is absent', () async {
      final RenderFastApiChatRepository repo = RenderFastApiChatRepository(
        dio: Dio(),
        payloadBuilder: const HuggingFacePayloadBuilder(),
        responseParser: const HuggingFaceResponseParser(fallbackMessage: ''),
        callerAuth: _FakeCaller(),
        hfTokenProvider: _EmptyHf(),
        isRunnable: () => true,
      );

      expect(
        () => repo.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'hello',
        ),
        throwsA(
          isA<ChatRemoteFailureException>().having(
            (final ChatRemoteFailureException e) => e.code,
            'code',
            'token_missing',
          ),
        ),
      );
    });
  });
}
