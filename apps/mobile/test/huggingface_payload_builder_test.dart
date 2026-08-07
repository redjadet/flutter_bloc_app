import 'package:approval_tests/approval_tests.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/approval_test_options.dart';

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

      Approvals.verifyAsJson(payload, options: approvalTestOptions());
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

        Approvals.verifyAsJson(payload, options: approvalTestOptions());
      },
    );
  });
}
