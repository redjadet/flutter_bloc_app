import 'package:flutter_bloc_app/features/chat/data/demo_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoFirstChatRepository', () {
    test('skips render when not attempted first', () async {
      final _RecordingRepo render = _RecordingRepo(
        result: _dummyResult(ChatInferenceTransport.renderOrchestration),
      );
      final _RecordingRepo composite = _RecordingRepo(
        result: _dummyResult(ChatInferenceTransport.direct),
      );
      final DemoFirstChatRepository repo = DemoFirstChatRepository(
        renderRepository: render,
        compositeRepository: composite,
        isRenderAttemptedFirst: () => false,
        isRenderStrict: () => false,
      );

      await repo.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'hi',
        model: kChatOrchestrationAutoModelId,
      );

      expect(render.calls, 0);
      expect(composite.calls, 1);
      expect(composite.lastModel, 'openai/gpt-oss-20b');
    });

    test('falls through to composite on retryable Render failure', () async {
      final _RecordingRepo render = _RecordingRepo(
        throwRemote: const ChatRemoteFailureException(
          'saturation',
          code: 'upstream_unavailable',
          retryable: true,
          isEdge: false,
        ),
      );
      final _RecordingRepo composite = _RecordingRepo(
        result: _dummyResult(ChatInferenceTransport.supabase),
      );
      final DemoFirstChatRepository repo = DemoFirstChatRepository(
        renderRepository: render,
        compositeRepository: composite,
        isRenderAttemptedFirst: () => true,
        isRenderStrict: () => false,
      );

      final ChatResult out = await repo.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'hi',
      );

      expect(render.calls, 1);
      expect(composite.calls, 1);
      expect(out.transportUsed, ChatInferenceTransport.supabase);
    });

    test('passes same clientMessageId to composite on render fallthrough', () async {
      final _RecordingRepo render = _RecordingRepo(
        throwRemote: const ChatRemoteFailureException(
          'saturation',
          code: 'upstream_unavailable',
          retryable: true,
          isEdge: false,
        ),
      );
      final _RecordingRepo composite = _RecordingRepo(
        result: _dummyResult(ChatInferenceTransport.direct),
      );
      final DemoFirstChatRepository repo = DemoFirstChatRepository(
        renderRepository: render,
        compositeRepository: composite,
        isRenderAttemptedFirst: () => true,
        isRenderStrict: () => false,
      );

      await repo.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'hi',
        clientMessageId: 'idem-client-1',
      );

      expect(render.clientMessageIds, const <String?>['idem-client-1']);
      expect(composite.clientMessageIds, const <String?>['idem-client-1']);
    });

    test('strict mode does not fall through', () async {
      final _RecordingRepo render = _RecordingRepo(
        throwRemote: const ChatRemoteFailureException(
          'saturation',
          code: 'upstream_unavailable',
          retryable: true,
          isEdge: false,
        ),
      );
      final _RecordingRepo composite = _RecordingRepo(
        result: _dummyResult(ChatInferenceTransport.direct),
      );
      final DemoFirstChatRepository repo = DemoFirstChatRepository(
        renderRepository: render,
        compositeRepository: composite,
        isRenderAttemptedFirst: () => true,
        isRenderStrict: () => true,
      );

      expect(
        () => repo.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'hi',
        ),
        throwsA(isA<ChatRemoteFailureException>()),
      );
      expect(composite.calls, 0);
    });
  });
}

ChatResult _dummyResult(final ChatInferenceTransport transport) => ChatResult(
  reply: const ChatMessage(author: ChatAuthor.assistant, text: 'ok'),
  pastUserInputs: const <String>['hi'],
  generatedResponses: const <String>['ok'],
  transportUsed: transport,
);

class _RecordingRepo implements ChatRepository {
  _RecordingRepo({this.result, this.throwRemote});

  final ChatResult? result;
  final ChatRemoteFailureException? throwRemote;
  int calls = 0;
  String? lastModel;
  final List<String?> clientMessageIds = <String?>[];

  @override
  ChatInferenceTransport? get chatRemoteTransportHint => null;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    calls++;
    lastModel = model;
    clientMessageIds.add(clientMessageId);
    if (throwRemote != null) {
      throw throwRemote!;
    }
    return result!;
  }
}
