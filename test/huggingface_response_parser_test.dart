import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

typedef JsonMap = Map<String, dynamic>;

void main() {
  group('HuggingFaceResponseParser', () {
    const fallback = 'fallback-response';
    const parser = HuggingFaceResponseParser(fallbackMessage: fallback);

    test('buildInferenceResult maps generated text and conversation lists', () {
      final JsonMap json = <String, dynamic>{
        'conversation': <String, dynamic>{
          'past_user_inputs': <String>['hi'],
          'generated_responses': <String>['hello'],
        },
        'generated_text': 'hello again',
      };

      final ChatResult result = parser.buildInferenceResult(json);

      expect(result.reply.author, ChatAuthor.assistant);
      expect(result.reply.text, 'hello again');
      expect(result.pastUserInputs, equals(<String>['hi']));
      expect(result.generatedResponses, equals(<String>['hello']));
    });

    test('buildInferenceResult falls back when generated text missing', () {
      final JsonMap json = <String, dynamic>{
        'conversation': <String, dynamic>{
          'past_user_inputs': <String>[],
          'generated_responses': <String>[],
        },
      };

      final ChatResult result = parser.buildInferenceResult(json);

      expect(result.reply.text, fallback);
      expect(result.pastUserInputs, isEmpty);
      expect(result.generatedResponses, isEmpty);
    });

    test(
      'buildChatCompletionsResult appends prompt/history and parses string',
      () {
        final JsonMap json = <String, dynamic>{
          'choices': <JsonMap>[
            <String, dynamic>{
              'message': <String, dynamic>{'content': 'assistant reply'},
            },
          ],
        };

        final ChatResult result = parser.buildChatCompletionsResult(
          json: json,
          pastUserInputs: const <String>['hi'],
          generatedResponses: const <String>['hello'],
          prompt: 'new prompt',
        );

        expect(result.reply.text, 'assistant reply');
        expect(result.pastUserInputs, equals(<String>['hi', 'new prompt']));
        expect(
          result.generatedResponses,
          equals(<String>['hello', 'assistant reply']),
        );
      },
    );

    test(
      'buildChatCompletionsResult concatenates chunked content fallback',
      () {
        final JsonMap json = <String, dynamic>{
          'choices': <JsonMap>[
            <String, dynamic>{
              'message': <String, dynamic>{
                'content': <JsonMap>[
                  <String, dynamic>{'text': 'part1 '},
                  <String, dynamic>{'content': 'part2'},
                ],
              },
            },
          ],
        };

        final ChatResult result = parser.buildChatCompletionsResult(
          json: json,
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'prompt',
        );

        expect(result.reply.text, 'part1 part2');
        expect(result.generatedResponses.last, 'part1 part2');
      },
    );

    test(
      'buildChatCompletionsResult falls back when first choice is malformed',
      () {
        final JsonMap json = <String, dynamic>{
          'choices': <dynamic>['unexpected-shape'],
        };

        final ChatResult result = parser.buildChatCompletionsResult(
          json: json,
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'prompt',
        );

        expect(result.reply.text, fallback);
        expect(result.generatedResponses.last, fallback);
      },
    );

    test('buildChatCompletionsResult falls back when choices is null', () {
      final JsonMap json = <String, dynamic>{'choices': null};

      final ChatResult result = parser.buildChatCompletionsResult(
        json: json,
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'p',
      );

      expect(result.reply.text, fallback);
      expect(result.generatedResponses.last, fallback);
    });

    test('buildChatCompletionsResult falls back when choices is empty', () {
      final JsonMap json = <String, dynamic>{'choices': <JsonMap>[]};

      final ChatResult result = parser.buildChatCompletionsResult(
        json: json,
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        prompt: 'p',
      );

      expect(result.reply.text, fallback);
      expect(result.generatedResponses.last, fallback);
    });

    test(
      'buildChatCompletionsResult falls back when first choice is non-map',
      () {
        final JsonMap json = <String, dynamic>{
          'choices': <dynamic>[
            42,
            <String, dynamic>{'message': null},
          ],
        };

        final ChatResult result = parser.buildChatCompletionsResult(
          json: json,
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'p',
        );

        expect(result.reply.text, fallback);
        expect(result.generatedResponses.last, fallback);
      },
    );
  });
}
