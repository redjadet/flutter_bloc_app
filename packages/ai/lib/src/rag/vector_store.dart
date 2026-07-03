import 'document_chunk.dart';

/// Vector store contract for embeddings-backed retrieval.
abstract interface class VectorStore {
  Future<void> upsert(DocumentChunk chunk, List<double> embedding);
  Future<List<DocumentChunk>> query(List<double> embedding, {int limit = 8});
}
