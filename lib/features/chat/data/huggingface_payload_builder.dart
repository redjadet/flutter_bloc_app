import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';

/// Builds request payloads for Hugging Face inference and chat completions APIs.
class HuggingFacePayloadBuilder {
  const HuggingFacePayloadBuilder();

  JsonMap buildInferencePayload({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    return <String, dynamic>{
      'inputs': <String, dynamic>{
        'past_user_inputs': pastUserInputs,
        'generated_responses': generatedResponses,
        'text': prompt,
      },
    };
  }

  JsonMap buildChatCompletionsPayload({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    required String model,
  }) {
    return <String, dynamic>{
      'model': model,
      'messages': _composeMessages(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
      ),
      'stream': false,
    };
  }

  List<Map<String, String>> _composeMessages({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    final List<Map<String, String>> messages = <Map<String, String>>[];

    for (int i = 0; i < pastUserInputs.length; i++) {
      messages.add(<String, String>{
        'role': 'user',
        'content': pastUserInputs[i],
      });

      if (i < generatedResponses.length) {
        messages.add(<String, String>{
          'role': 'assistant',
          'content': generatedResponses[i],
        });
      }
    }

    messages.add(<String, String>{'role': 'user', 'content': prompt});
    return messages;
  }
}
