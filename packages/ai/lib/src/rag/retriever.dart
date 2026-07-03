import 'document_chunk.dart';

/// Retrieves relevant chunks for a query.
abstract interface class Retriever {
  Future<List<DocumentChunk>> retrieve({required String query, int limit = 8});
}
