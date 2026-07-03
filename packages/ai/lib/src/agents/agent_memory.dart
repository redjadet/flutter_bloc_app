/// Short-term agent memory entry.
class AgentMemoryEntry {
  const AgentMemoryEntry({required this.key, required this.value});

  final String key;
  final String value;
}

abstract interface class AgentMemory {
  Future<void> write(AgentMemoryEntry entry);
  Future<List<AgentMemoryEntry>> read({String? prefix});
}
