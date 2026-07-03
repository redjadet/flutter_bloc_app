/// MCP server metadata (no wire protocol types).
class McpServerDescriptor {
  const McpServerDescriptor({
    required this.name,
    required this.transport,
    this.endpoint,
  });

  final String name;
  final String transport;
  final String? endpoint;
}
