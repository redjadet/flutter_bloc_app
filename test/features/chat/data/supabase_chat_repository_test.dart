import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/supabase_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/supabase_test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const HuggingFacePayloadBuilder payloadBuilder = HuggingFacePayloadBuilder();

  setUp(() async {
    await initializeSupabaseForTest();
  });

  tearDown(resetSupabaseTestState);

  group('SupabaseChatRepository', () {
    test(
      'throws missing_configuration when Supabase is not initialized',
      () async {
        resetSupabaseTestState();
        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 't',
          readAnonKey: () => 'anon',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                throw StateError('invoke should not run');
              },
        );

        await expectLater(
          () => repository.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hi',
          ),
          throwsA(
            isA<ChatRemoteFailureException>().having(
              (final ChatRemoteFailureException e) => e.code,
              'code',
              'missing_configuration',
            ),
          ),
        );
      },
    );

    test('throws auth_required when session token is missing', () async {
      final SupabaseChatRepository repository = SupabaseChatRepository(
        payloadBuilder: payloadBuilder,
        readAccessToken: () => null,
        readAnonKey: () => 'anon',
        invoke:
            ({
              required final String accessToken,
              required final String anonKey,
              required final Map<String, dynamic> body,
            }) async {
              throw StateError('invoke should not run');
            },
      );

      await expectLater(
        () => repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hi',
        ),
        throwsA(
          isA<ChatRemoteFailureException>()
              .having(
                (final ChatRemoteFailureException e) => e.code,
                'code',
                'auth_required',
              )
              .having(
                (final ChatRemoteFailureException e) => e.retryable,
                'retryable',
                isFalse,
              ),
        ),
      );
    });

    test('throws missing_configuration when anon key is missing', () async {
      final SupabaseChatRepository repository = SupabaseChatRepository(
        payloadBuilder: payloadBuilder,
        readAccessToken: () => 'token',
        readAnonKey: () => '',
        invoke:
            ({
              required final String accessToken,
              required final String anonKey,
              required final Map<String, dynamic> body,
            }) async {
              throw StateError('invoke should not run');
            },
      );

      await expectLater(
        () => repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hi',
        ),
        throwsA(
          isA<ChatRemoteFailureException>().having(
            (final ChatRemoteFailureException e) => e.code,
            'code',
            'missing_configuration',
          ),
        ),
      );
    });

    test(
      'invokes Edge with bearer token, apikey header contract, and body fields',
      () async {
        String? seenToken;
        String? seenAnon;
        Map<String, dynamic>? seenBody;

        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 'jwt-abc',
          readAnonKey: () => 'anon-xyz',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                seenToken = accessToken;
                seenAnon = anonKey;
                seenBody = body;
                return FunctionResponse(
                  status: 200,
                  data: <String, dynamic>{
                    'assistantMessage': <String, dynamic>{
                      'content': 'Edge says hello',
                    },
                  },
                );
              },
        );

        final ChatResult result = await repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hi',
          model: 'custom/model',
          clientMessageId: 'cid-1',
        );

        expect(seenToken, 'jwt-abc');
        expect(seenAnon, 'anon-xyz');
        expect(seenBody, isNotNull);
        expect(seenBody!['schemaVersion'], 1);
        expect(seenBody!['model'], 'custom/model');
        expect(seenBody!['clientMessageId'], 'cid-1');
        expect(seenBody!['messages'], isA<List<dynamic>>());
        expect(result.reply.text, 'Edge says hello');
        expect(result.reply.author, ChatAuthor.assistant);
        expect(result.transportUsed, ChatInferenceTransport.supabase);
      },
    );

    test(
      'omits model from Edge body when caller does not request one',
      () async {
        Map<String, dynamic>? seenBody;

        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 'jwt-abc',
          readAnonKey: () => 'anon-xyz',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                seenBody = body;
                return FunctionResponse(
                  status: 200,
                  data: <String, dynamic>{
                    'assistantMessage': <String, dynamic>{
                      'content': 'Edge says hello',
                    },
                  },
                );
              },
        );

        await repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hi',
        );

        expect(seenBody, isNotNull);
        expect(seenBody!.containsKey('model'), isFalse);
      },
    );

    test(
      'non-200 FunctionResponse maps to upstream_unavailable with retryable from status',
      () async {
        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 't',
          readAnonKey: () => 'anon',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async => FunctionResponse(status: 503, data: null),
        );

        await expectLater(
          () => repository.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hi',
          ),
          throwsA(
            isA<ChatRemoteFailureException>()
                .having(
                  (final ChatRemoteFailureException e) => e.code,
                  'code',
                  'upstream_unavailable',
                )
                .having(
                  (final ChatRemoteFailureException e) => e.retryable,
                  'retryable',
                  isTrue,
                ),
          ),
        );
      },
    );

    test(
      'maps undeployed function (404 / reason phrase) to missing_configuration',
      () async {
        final SupabaseChatRepository repository404 = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 't',
          readAnonKey: () => 'anon',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                throw const FunctionException(
                  status: 404,
                  reasonPhrase: 'Requested function was not found',
                );
              },
        );

        await expectLater(
          () => repository404.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hi',
          ),
          throwsA(
            isA<ChatRemoteFailureException>()
                .having(
                  (final ChatRemoteFailureException e) => e.code,
                  'code',
                  'missing_configuration',
                )
                .having(
                  (final ChatRemoteFailureException e) => e.retryable,
                  'retryable',
                  isFalse,
                ),
          ),
        );

        final SupabaseChatRepository repositoryPhrase = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 't',
          readAnonKey: () => 'anon',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                throw const FunctionException(
                  status: 400,
                  reasonPhrase: 'Requested function was not found',
                );
              },
        );

        await expectLater(
          () => repositoryPhrase.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hi',
          ),
          throwsA(
            isA<ChatRemoteFailureException>().having(
              (final ChatRemoteFailureException e) => e.code,
              'code',
              'missing_configuration',
            ),
          ),
        );
      },
    );

    test(
      'maps FunctionException with JSON details code and retryable',
      () async {
        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 't',
          readAnonKey: () => 'anon',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                throw FunctionException(
                  status: 400,
                  details: <String, dynamic>{
                    'code': 'invalid_payload',
                    'retryable': false,
                    'message': 'Schema mismatch',
                  },
                );
              },
        );

        await expectLater(
          () => repository.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hi',
          ),
          throwsA(
            isA<ChatRemoteFailureException>()
                .having(
                  (final ChatRemoteFailureException e) => e.code,
                  'code',
                  'invalid_payload',
                )
                .having(
                  (final ChatRemoteFailureException e) => e.retryable,
                  'retryable',
                  isFalse,
                )
                .having(
                  (final ChatRemoteFailureException e) => e.message,
                  'message',
                  'Schema mismatch',
                ),
          ),
        );
      },
    );

    test(
      'after HTTP 401 refresh retry maps retry FunctionException not original 401',
      () async {
        int calls = 0;
        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 't',
          readAnonKey: () => 'anon',
          refreshSessionAfter401: () async {},
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                calls += 1;
                if (calls == 1) {
                  throw const FunctionException(status: 401);
                }
                throw const FunctionException(
                  status: 404,
                  reasonPhrase: 'Requested function was not found',
                );
              },
        );

        await expectLater(
          () => repository.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hi',
          ),
          throwsA(
            isA<ChatRemoteFailureException>()
                .having(
                  (final ChatRemoteFailureException e) => e.code,
                  'code',
                  'missing_configuration',
                )
                .having(
                  (final ChatRemoteFailureException e) => e.retryable,
                  'retryable',
                  isFalse,
                ),
          ),
        );
        expect(calls, 2);
      },
    );

    test('after HTTP 401 refresh retry can succeed on second invoke', () async {
      int calls = 0;
      final SupabaseChatRepository repository = SupabaseChatRepository(
        payloadBuilder: payloadBuilder,
        readAccessToken: () => 't',
        readAnonKey: () => 'anon',
        refreshSessionAfter401: () async {},
        invoke:
            ({
              required final String accessToken,
              required final String anonKey,
              required final Map<String, dynamic> body,
            }) async {
              calls += 1;
              if (calls == 1) {
                throw const FunctionException(status: 401);
              }
              return FunctionResponse(
                status: 200,
                data: <String, dynamic>{
                  'assistantMessage': <String, dynamic>{'content': 'Retry ok'},
                },
              );
            },
      );

      final ChatResult result = await repository.sendMessage(
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'Hi',
      );

      expect(calls, 2);
      expect(result.reply.text, 'Retry ok');
    });

    test(
      'maps FunctionException HTTP 403 to forbidden (non-retryable)',
      () async {
        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 't',
          readAnonKey: () => 'anon',
          invoke:
              ({
                required final String accessToken,
                required final String anonKey,
                required final Map<String, dynamic> body,
              }) async {
                throw const FunctionException(status: 403);
              },
        );

        await expectLater(
          () => repository.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hi',
          ),
          throwsA(
            isA<ChatRemoteFailureException>()
                .having(
                  (final ChatRemoteFailureException e) => e.code,
                  'code',
                  'forbidden',
                )
                .having(
                  (final ChatRemoteFailureException e) => e.retryable,
                  'retryable',
                  isFalse,
                ),
          ),
        );
      },
    );

    test('maps FunctionException HTTP 429 to rate_limited', () async {
      final SupabaseChatRepository repository = SupabaseChatRepository(
        payloadBuilder: payloadBuilder,
        readAccessToken: () => 't',
        readAnonKey: () => 'anon',
        invoke:
            ({
              required final String accessToken,
              required final String anonKey,
              required final Map<String, dynamic> body,
            }) async {
              throw const FunctionException(status: 429);
            },
      );

      await expectLater(
        () => repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hi',
        ),
        throwsA(
          isA<ChatRemoteFailureException>().having(
            (final ChatRemoteFailureException e) => e.code,
            'code',
            'rate_limited',
          ),
        ),
      );
    });

    test('maps FunctionException HTTP 504 to upstream_timeout', () async {
      final SupabaseChatRepository repository = SupabaseChatRepository(
        payloadBuilder: payloadBuilder,
        readAccessToken: () => 't',
        readAnonKey: () => 'anon',
        invoke:
            ({
              required final String accessToken,
              required final String anonKey,
              required final Map<String, dynamic> body,
            }) async {
              throw const FunctionException(status: 504);
            },
      );

      await expectLater(
        () => repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hi',
        ),
        throwsA(
          isA<ChatRemoteFailureException>()
              .having(
                (final ChatRemoteFailureException e) => e.code,
                'code',
                'upstream_timeout',
              )
              .having(
                (final ChatRemoteFailureException e) => e.retryable,
                'retryable',
                isTrue,
              ),
        ),
      );
    });

    test(
      'chatRemoteTransportHint is supabase when initialized and token present',
      () async {
        final SupabaseChatRepository repository = SupabaseChatRepository(
          payloadBuilder: payloadBuilder,
          readAccessToken: () => 'tok',
          readAnonKey: () => 'anon',
        );
        expect(
          repository.chatRemoteTransportHint,
          ChatInferenceTransport.supabase,
        );
      },
    );

    test('chatRemoteTransportHint is null when token missing', () async {
      final SupabaseChatRepository repository = SupabaseChatRepository(
        payloadBuilder: payloadBuilder,
        readAccessToken: () => null,
        readAnonKey: () => 'anon',
      );
      expect(repository.chatRemoteTransportHint, isNull);
    });
  });
}
