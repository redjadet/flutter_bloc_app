import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';

typedef JsonMap = Map<String, dynamic>;

void main() {
  group('HuggingFacePayloadBuilder', () {
    const builder = HuggingFacePayloadBuilder();

    test('buildInferencePayload includes inputs with provided values', () {
      const pastUserInputs = <String>['hello'];
      const generatedResponses = <String>['hi'];
      const prompt = 'How are you?';

      final JsonMap payload = builder.buildInferencePayload(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
      );

      final JsonMap inputs = payload['inputs'] as JsonMap;
      expect(inputs['past_user_inputs'], equals(pastUserInputs));
      expect(inputs['generated_responses'], equals(generatedResponses));
      expect(inputs['text'], equals(prompt));
    });

    test(
      'buildChatCompletionsPayload composes alternating message history',
      () {
        const pastUserInputs = <String>['hi', 'what is up?'];
        const generatedResponses = <String>['hello!', 'not much'];
        const prompt = 'tell me a joke';
        const model = 'custom-model';

        final JsonMap payload = builder.buildChatCompletionsPayload(
          pastUserInputs: pastUserInputs,
          generatedResponses: generatedResponses,
          prompt: prompt,
          model: model,
        );

        expect(payload['model'], equals(model));
        final List<dynamic> messages = payload['messages'] as List<dynamic>;
        expect(messages, hasLength(5));

        expect(
          messages[0],
          equals(<String, String>{
            'role': 'user',
            'content': pastUserInputs[0],
          }),
        );
        expect(
          messages[1],
          equals(<String, String>{
            'role': 'assistant',
            'content': generatedResponses[0],
          }),
        );
        expect(
          messages[2],
          equals(<String, String>{
            'role': 'user',
            'content': pastUserInputs[1],
          }),
        );
        expect(
          messages[3],
          equals(<String, String>{
            'role': 'assistant',
            'content': generatedResponses[1],
          }),
        );
        expect(
          messages[4],
          equals(<String, String>{'role': 'user', 'content': prompt}),
        );
        expect(payload['stream'], isFalse);
      },
    );
  });
}
