/// Result of executing a [ToolCall].
class ToolResult {
  const ToolResult({
    required this.callId,
    required this.output,
    this.isError = false,
  });

  final String callId;
  final Object? output;
  final bool isError;
}
