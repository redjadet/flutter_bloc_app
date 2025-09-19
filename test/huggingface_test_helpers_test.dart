import 'dart:convert';

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'test_helpers.dart';

void main() {
  group('Hugging Face test helpers', () {
    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    test(
      'runWithHuggingFaceHttpClientOverride sets and restores scope',
      () async {
        final baselineClient = MockClient((request) async {
          return http.Response(
            jsonEncode(<String, dynamic>{'status': 'baseline'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        getIt.pushNewScope(scopeName: 'baseline');
        getIt.registerSingleton<http.Client>(baselineClient);
        getIt.registerLazySingleton<HuggingFaceApiClient>(
          () => HuggingFaceApiClient(
            httpClient: getIt<http.Client>(),
            apiKey: 'baseline',
          ),
        );
        getIt.registerLazySingleton<ChatRepository>(
          () => HuggingfaceChatRepository(
            apiClient: getIt<HuggingFaceApiClient>(),
            payloadBuilder: const HuggingFacePayloadBuilder(),
            responseParser: const HuggingFaceResponseParser(
              fallbackMessage: HuggingfaceChatRepository.fallbackMessage,
            ),
            model: 'baseline-model',
            useChatCompletions: false,
          ),
        );

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'conversation': <String, dynamic>{
                'past_user_inputs': const <String>[],
                'generated_responses': const <String>[],
              },
              'generated_text': 'override',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final result = await runWithHuggingFaceHttpClientOverride(
          client: mockClient,
          apiKey: 'override',
          model: 'override-model',
          action: () async {
            final repository = getIt<ChatRepository>();
            return repository.sendMessage(
              pastUserInputs: const <String>[],
              generatedResponses: const <String>[],
              prompt: 'hi',
            );
          },
        );

        expect(result.reply.text, 'override');
        // After scope pop, baseline client should still be registered.
        expect(getIt<http.Client>(), same(baselineClient));

        await getIt.popScope();
      },
    );
  });
}
