/// Retrieved document chunk for RAG.
class DocumentChunk {
  const DocumentChunk({
    required this.id,
    required this.text,
    this.score,
    this.metadata = const {},
  });

  final String id;
  final String text;
  final double? score;
  final Map<String, String> metadata;
}
