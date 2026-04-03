import 'package:flutter_bloc_app/features/chat/data/composite_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubEdgeRepo implements ChatRepository {
  _StubEdgeRepo({this.result, this.throwOnSend});

  final ChatResult? result;
  final ChatRemoteFailureException? throwOnSend;

  @override
  ChatInferenceTransport? get chatRemoteTransportHint =>
      ChatInferenceTransport.supabase;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    if (throwOnSend != null) {
      throw throwOnSend!;
    }
    final ChatResult? r = result;
    if (r == null) {
      throw StateError('StubEdgeRepo: no result');
    }
    return r;
  }
}

class _FakeHfDirect implements HuggingfaceChatRepository {
  _FakeHfDirect({required this.result});

  final ChatResult result;
  int sendCount = 0;

  @override
  bool get hasApiKey => true;

  @override
  bool get usesChatCompletions => true;

  @override
  ChatInferenceTransport? get chatRemoteTransportHint =>
      ChatInferenceTransport.direct;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    sendCount++;
    return result;
  }
}

class _FakeNetwork implements NetworkStatusService {
  _FakeNetwork(this._status);

  final NetworkStatus _status;

  @override
  Future<void> dispose() async {}

  @override
  Future<NetworkStatus> getCurrentStatus() async => _status;

  @override
  Stream<NetworkStatus> get statusStream => Stream<NetworkStatus>.empty();
}

void main() {
  group('CompositeChatRepository', () {
    final ChatResult supabaseOk = ChatResult(
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'edge'),
      pastUserInputs: const <String>['a'],
      generatedResponses: const <String>['edge'],
      transportUsed: ChatInferenceTransport.supabase,
    );
    final ChatResult directOk = ChatResult(
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'direct'),
      pastUserInputs: const <String>['a'],
      generatedResponses: const <String>['direct'],
      transportUsed: ChatInferenceTransport.direct,
    );

    test('online uses Edge when proxy runnable and Edge succeeds', () async {
      final _StubEdgeRepo edge = _StubEdgeRepo(result: supabaseOk);
      final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
      final CompositeChatRepository composite = CompositeChatRepository(
        supabaseRepository: edge,
        directRepository: direct,
        networkStatusService: _FakeNetwork(NetworkStatus.online),
        isSupabaseProxyRunnable: () => true,
        isDirectPolicyAllowed: () => true,
      );

      final ChatResult out = await composite.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'a',
      );
      expect(out.reply.text, 'edge');
      expect(direct.sendCount, 0);
    });

    test(
      'online falls back to direct on retryable upstream_timeout when allowed',
      () async {
        final _StubEdgeRepo edge = _StubEdgeRepo(
          result: supabaseOk,
          throwOnSend: const ChatRemoteFailureException(
            't',
            code: 'upstream_timeout',
            retryable: true,
            isEdge: true,
          ),
        );
        final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
        final CompositeChatRepository composite = CompositeChatRepository(
          supabaseRepository: edge,
          directRepository: direct,
          networkStatusService: _FakeNetwork(NetworkStatus.online),
          isSupabaseProxyRunnable: () => true,
          isDirectPolicyAllowed: () => true,
        );

        final ChatResult out = await composite.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'a',
        );
        expect(out.reply.text, 'direct');
        expect(direct.sendCount, 1);
      },
    );

    test('does not fall back to direct on invalid_request', () async {
      final _StubEdgeRepo edge = _StubEdgeRepo(
        result: supabaseOk,
        throwOnSend: const ChatRemoteFailureException(
          'model mismatch',
          code: 'invalid_request',
          retryable: false,
          isEdge: true,
        ),
      );
      final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
      final CompositeChatRepository composite = CompositeChatRepository(
        supabaseRepository: edge,
        directRepository: direct,
        networkStatusService: _FakeNetwork(NetworkStatus.online),
        isSupabaseProxyRunnable: () => true,
        isDirectPolicyAllowed: () => true,
      );

      await expectLater(
        () => composite.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'a',
        ),
        throwsA(
          isA<ChatRemoteFailureException>().having(
            (final ChatRemoteFailureException e) => e.code,
            'code',
            'invalid_request',
          ),
        ),
      );
      expect(direct.sendCount, 0);
    });

    test('does not fall back to direct on missing_configuration', () async {
      final _StubEdgeRepo edge = _StubEdgeRepo(
        result: supabaseOk,
        throwOnSend: const ChatRemoteFailureException(
          'HF not set on Edge',
          code: 'missing_configuration',
          retryable: false,
          isEdge: true,
        ),
      );
      final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
      final CompositeChatRepository composite = CompositeChatRepository(
        supabaseRepository: edge,
        directRepository: direct,
        networkStatusService: _FakeNetwork(NetworkStatus.online),
        isSupabaseProxyRunnable: () => true,
        isDirectPolicyAllowed: () => true,
      );

      await expectLater(
        () => composite.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'a',
        ),
        throwsA(
          isA<ChatRemoteFailureException>().having(
            (final ChatRemoteFailureException e) => e.code,
            'code',
            'missing_configuration',
          ),
        ),
      );
      expect(direct.sendCount, 0);
    });

    test(
      'does not fall back on invalid_request when direct disallowed',
      () async {
        final _StubEdgeRepo edge = _StubEdgeRepo(
          result: supabaseOk,
          throwOnSend: const ChatRemoteFailureException(
            'bad',
            code: 'invalid_request',
            retryable: false,
            isEdge: true,
          ),
        );
        final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
        final CompositeChatRepository composite = CompositeChatRepository(
          supabaseRepository: edge,
          directRepository: direct,
          networkStatusService: _FakeNetwork(NetworkStatus.online),
          isSupabaseProxyRunnable: () => true,
          isDirectPolicyAllowed: () => false,
        );

        await expectLater(
          () => composite.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'a',
          ),
          throwsA(isA<ChatRemoteFailureException>()),
        );
        expect(direct.sendCount, 0);
      },
    );

    test('does not fall back to direct on auth_required', () async {
      final _StubEdgeRepo edge = _StubEdgeRepo(
        result: supabaseOk,
        throwOnSend: const ChatRemoteFailureException(
          'auth',
          code: 'auth_required',
          retryable: false,
          isEdge: true,
        ),
      );
      final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
      final CompositeChatRepository composite = CompositeChatRepository(
        supabaseRepository: edge,
        directRepository: direct,
        networkStatusService: _FakeNetwork(NetworkStatus.online),
        isSupabaseProxyRunnable: () => true,
        isDirectPolicyAllowed: () => true,
      );

      await expectLater(
        () => composite.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'a',
        ),
        throwsA(isA<ChatRemoteFailureException>()),
      );
      expect(direct.sendCount, 0);
    });

    test(
      'offline does not attempt Edge or direct and returns retryable failure',
      () async {
        final _StubEdgeRepo edge = _StubEdgeRepo(result: supabaseOk);
        final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
        final CompositeChatRepository composite = CompositeChatRepository(
          supabaseRepository: edge,
          directRepository: direct,
          networkStatusService: _FakeNetwork(NetworkStatus.offline),
          isSupabaseProxyRunnable: () => true,
          isDirectPolicyAllowed: () => true,
        );

        await expectLater(
          () => composite.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'a',
          ),
          throwsA(
            isA<ChatRemoteFailureException>()
                .having(
                  (final ChatRemoteFailureException e) => e.retryable,
                  'retryable',
                  isTrue,
                )
                .having(
                  (final ChatRemoteFailureException e) => e.code,
                  'code',
                  'upstream_unavailable',
                ),
          ),
        );
        expect(direct.sendCount, 0);
      },
    );

    test('offline does not chain Edge then direct for one send', () async {
      final _StubEdgeRepo edge = _StubEdgeRepo(
        result: supabaseOk,
        throwOnSend: const ChatRemoteFailureException(
          't',
          code: 'upstream_timeout',
          retryable: true,
          isEdge: true,
        ),
      );
      final _FakeHfDirect direct = _FakeHfDirect(result: directOk);
      final CompositeChatRepository composite = CompositeChatRepository(
        supabaseRepository: edge,
        directRepository: direct,
        networkStatusService: _FakeNetwork(NetworkStatus.offline),
        isSupabaseProxyRunnable: () => true,
        isDirectPolicyAllowed: () => true,
      );

      await expectLater(
        () => composite.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'a',
        ),
        throwsA(isA<ChatRemoteFailureException>()),
      );
      expect(direct.sendCount, 0);
    });
  });
}
