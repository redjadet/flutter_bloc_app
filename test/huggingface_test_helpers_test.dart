import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('Hugging Face test helpers', () {
    tearDown(() async {
      await getIt.reset(dispose: true);
    });

    test(
      'runWithHuggingFaceHttpClientOverride sets and restores scope',
      () async {
        final baselineDio = Dio();
        baselineDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<String>(
                  requestOptions: options,
                  data: jsonEncode(<String, dynamic>{'status': 'baseline'}),
                  statusCode: 200,
                  headers: Headers.fromMap({
                    'content-type': ['application/json'],
                  }),
                ),
              );
            },
          ),
        );

        getIt.pushNewScope(scopeName: 'baseline');
        getIt.registerSingleton<Dio>(baselineDio);
        getIt.registerLazySingleton<HuggingFaceApiClient>(
          () => HuggingFaceApiClient(dio: getIt<Dio>(), apiKey: 'baseline'),
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

        final mockDio = Dio();
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response<String>(
                  requestOptions: options,
                  data: jsonEncode(<String, dynamic>{
                    'conversation': <String, dynamic>{
                      'past_user_inputs': const <String>[],
                      'generated_responses': const <String>[],
                    },
                    'generated_text': 'override',
                  }),
                  statusCode: 200,
                  headers: Headers.fromMap({
                    'content-type': ['application/json'],
                  }),
                ),
              );
            },
          ),
        );

        final result = await runWithHuggingFaceHttpClientOverride(
          dio: mockDio,
          apiKey: 'override',
          model: 'override-model',
          useChatCompletions: false,
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
        expect(getIt<Dio>(), same(baselineDio));

        await getIt.popScope();
      },
    );
  });
}
