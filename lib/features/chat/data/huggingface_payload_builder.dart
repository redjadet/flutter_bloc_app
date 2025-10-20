import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';

/// Builds request payloads for Hugging Face inference and chat completions APIs.
class HuggingFacePayloadBuilder {
  const HuggingFacePayloadBuilder();

  JsonMap buildInferencePayload({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
  }) => <String, dynamic>{
    'inputs': <String, dynamic>{
      'past_user_inputs': pastUserInputs,
      'generated_responses': generatedResponses,
      'text': prompt,
    },
  };

  JsonMap buildChatCompletionsPayload({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    required final String model,
  }) => <String, dynamic>{
    'model': model,
    'messages': _composeMessages(
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      prompt: prompt,
    ),
    'stream': false,
  };

  List<Map<String, String>> _composeMessages({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
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
