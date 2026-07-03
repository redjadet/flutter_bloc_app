import 'tool_call.dart';
import 'tool_descriptor.dart';
import 'tool_result.dart';

typedef ToolHandler = Future<ToolResult> Function(ToolCall call);

/// Registry mapping tool names to handlers.
class ToolRegistry {
  final Map<String, ToolDescriptor> _descriptors = {};
  final Map<String, ToolHandler> _handlers = {};

  void register({
    required final ToolDescriptor descriptor,
    required final ToolHandler handler,
  }) {
    _descriptors[descriptor.name] = descriptor;
    _handlers[descriptor.name] = handler;
  }

  Iterable<ToolDescriptor> get descriptors => _descriptors.values;

  Future<ToolResult> invoke(final ToolCall call) => _handlers[call.name]!(call);
}
