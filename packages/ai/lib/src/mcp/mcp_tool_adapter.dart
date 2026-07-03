import '../tools/tool_call.dart';
import '../tools/tool_result.dart';

/// Adapts MCP tool invocations to package-neutral [ToolCall] / [ToolResult].
abstract interface class McpToolAdapter {
  Future<ToolResult> invoke(ToolCall call);
}
