/// Embedding generation contract.
abstract interface class EmbeddingProvider {
  Future<List<double>> embed({required String model, required String input});
}
