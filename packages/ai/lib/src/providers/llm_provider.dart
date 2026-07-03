/// Single-shot LLM completion contract (provider-neutral).
abstract interface class LlmProvider {
  Future<String> complete({
    required String model,
    required List<LlmMessage> messages,
    LlmCompletionOptions? options,
  });
}

class LlmMessage {
  const LlmMessage({required this.role, required this.content});

  final String role;
  final String content;
}

class LlmCompletionOptions {
  const LlmCompletionOptions({
    this.temperature,
    this.maxOutputTokens,
    this.stopSequences = const [],
  });

  final double? temperature;
  final int? maxOutputTokens;
  final List<String> stopSequences;
}
