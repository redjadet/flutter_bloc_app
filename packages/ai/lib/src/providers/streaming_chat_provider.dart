import '../tools/tool_call.dart';

/// Streaming chat events exposed without provider SDK types.
sealed class ChatStreamEvent {
  const ChatStreamEvent();
}

final class ChatTextDelta extends ChatStreamEvent {
  const ChatTextDelta(this.text);

  final String text;
}

final class ChatToolCallEvent extends ChatStreamEvent {
  const ChatToolCallEvent(this.call);

  final ToolCall call;
}

final class ChatCompleted extends ChatStreamEvent {
  const ChatCompleted();
}

final class ChatFailed extends ChatStreamEvent {
  const ChatFailed(this.message, {this.retryable = false});

  final String message;
  final bool retryable;
}

/// Provider-neutral streaming chat contract.
abstract interface class StreamingChatProvider {
  Stream<ChatStreamEvent> streamChat({
    required String model,
    required List<({String role, String content})> messages,
  });
}
