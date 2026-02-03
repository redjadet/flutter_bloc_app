/// A single vocabulary word within a topic (pure Dart, Flutter-free).
class VocabularyItem {
  const VocabularyItem({
    required this.id,
    required this.wordEn,
    required this.topicId,
    this.imageAssetPath,
  });

  final String id;
  final String wordEn;
  final String topicId;
  final String? imageAssetPath;
}
