/// Fixture: public repository contract exposing a domain Map bag (bad).
abstract interface class BadDomainMapContract {
  Future<Map<String, dynamic>?> loadMessage(String messageId);
}
