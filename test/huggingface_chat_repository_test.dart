import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('HuggingfaceChatRepository', () {
    test('throws when API key missing', () async {
      final _StubApiClient apiClient = _StubApiClient(
        hasApiKey: false,
        responder: (_) async => <String, dynamic>{},
      );
      final HuggingfaceChatRepository repository = HuggingfaceChatRepository(
        apiClient: apiClient,
      );

      await expectLater(
        repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'hi',
        ),
        throwsA(isA<ChatException>()),
      );
    });

    test('sends inference requests when chat completions disabled', () async {
      final Map<String, dynamic> inferenceResponse = <String, dynamic>{
        'generated_text': 'hello!',
      };
      final _StubApiClient apiClient = _StubApiClient(
        hasApiKey: true,
        responder: (RequestSnapshot request) async {
          expect(
            request.uri.toString(),
            'https://api-inference.huggingface.co/models/custom-model',
          );
          expect(request.context, 'inference');
          return inferenceResponse;
        },
      );
      final _RecordingPayloadBuilder payloadBuilder =
          _RecordingPayloadBuilder();
      final _RecordingResponseParser responseParser = _RecordingResponseParser(
        result: _chatResult('hello!'),
      );

      final HuggingfaceChatRepository repository = HuggingfaceChatRepository(
        apiClient: apiClient,
        payloadBuilder: payloadBuilder,
        responseParser: responseParser,
        model: 'custom-model',
        useChatCompletions: false,
      );

      final ChatResult result = await repository.sendMessage(
        pastUserInputs: const <String>['prev'],
        generatedResponses: const <String>['resp'],
        prompt: 'hello',
      );

      expect(payloadBuilder.inferenceCalls, 1);
      expect(payloadBuilder.lastPrompt, 'hello');
      expect(responseParser.inferenceCalls, 1);
      expect(result.reply.text, 'hello!');
    });

    test('sends chat completions when enabled', () async {
      final Map<String, dynamic> completionsResponse = <String, dynamic>{
        'choices': <Map<String, Object>>[],
      };
      final _StubApiClient apiClient = _StubApiClient(
        hasApiKey: true,
        responder: (RequestSnapshot request) async {
          expect(
            request.uri.toString(),
            'https://router.huggingface.co/v1/chat/completions',
          );
          expect(request.context, 'chat-completions');
          return completionsResponse;
        },
      );
      final _RecordingPayloadBuilder payloadBuilder =
          _RecordingPayloadBuilder();
      final _RecordingResponseParser responseParser = _RecordingResponseParser(
        result: _chatResult('reply'),
      );

      final HuggingfaceChatRepository repository = HuggingfaceChatRepository(
        apiClient: apiClient,
        payloadBuilder: payloadBuilder,
        responseParser: responseParser,
        model: 'hf/chat',
        useChatCompletions: true,
      );

      final ChatResult result = await repository.sendMessage(
        pastUserInputs: const <String>['user'],
        generatedResponses: const <String>['assistant'],
        prompt: 'How are you?',
      );

      expect(payloadBuilder.chatCompletionsCalls, 1);
      expect(payloadBuilder.lastPrompt, 'How are you?');
      expect(responseParser.chatCompletionsCalls, 1);
      expect(result.reply.text, 'reply');
    });
  });
}

ChatResult _chatResult(String reply) {
  return ChatResult(
    reply: ChatMessage(author: ChatAuthor.assistant, text: reply),
    pastUserInputs: const <String>[],
    generatedResponses: const <String>[],
  );
}

class _StubApiClient extends HuggingFaceApiClient {
  _StubApiClient({
    required bool hasApiKey,
    required Future<Map<String, dynamic>> Function(RequestSnapshot request)
    responder,
  }) : _hasApiKey = hasApiKey,
       _responder = responder,
       super(httpClient: http.Client(), apiKey: 'token');

  final bool _hasApiKey;
  final Future<Map<String, dynamic>> Function(RequestSnapshot request)
  _responder;

  @override
  bool get hasApiKey => _hasApiKey;

  @override
  Future<Map<String, dynamic>> postJson({
    required Uri uri,
    required Map<String, dynamic> payload,
    required String context,
  }) {
    return _responder(
      RequestSnapshot(uri: uri, payload: payload, context: context),
    );
  }
}

class RequestSnapshot {
  RequestSnapshot({
    required this.uri,
    required this.payload,
    required this.context,
  });

  final Uri uri;
  final Map<String, dynamic> payload;
  final String context;
}

class _RecordingPayloadBuilder extends HuggingFacePayloadBuilder {
  int inferenceCalls = 0;
  int chatCompletionsCalls = 0;
  String? lastPrompt;

  @override
  Map<String, dynamic> buildInferencePayload({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    inferenceCalls++;
    lastPrompt = prompt;
    return <String, dynamic>{'prompt': prompt};
  }

  @override
  Map<String, dynamic> buildChatCompletionsPayload({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    required String model,
  }) {
    chatCompletionsCalls++;
    lastPrompt = prompt;
    return <String, dynamic>{'prompt': prompt, 'model': model};
  }
}

class _RecordingResponseParser extends HuggingFaceResponseParser {
  _RecordingResponseParser({required this.result})
    : super(fallbackMessage: HuggingfaceChatRepository.fallbackMessage);

  final ChatResult result;
  int inferenceCalls = 0;
  int chatCompletionsCalls = 0;

  @override
  ChatResult buildInferenceResult(Map<String, dynamic> json) {
    inferenceCalls++;
    return result;
  }

  @override
  ChatResult buildChatCompletionsResult({
    required Map<String, dynamic> json,
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    chatCompletionsCalls++;
    return result;
  }
}
