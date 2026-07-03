import '../structured_outputs/schema.dart';

/// Describes a callable tool for LLM agents.
class ToolDescriptor {
  const ToolDescriptor({
    required this.name,
    required this.description,
    this.inputSchema = const OutputSchema(fields: []),
  });

  final String name;
  final String description;
  final OutputSchema inputSchema;
}
