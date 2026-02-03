/// A topic/category for vocabulary (e.g. Animals) (pure Dart, Flutter-free).
class TopicItem {
  const TopicItem({
    required this.id,
    required this.nameL10nKey,
    this.iconAssetPath,
  });

  final String id;

  /// Localization key for display name (e.g. playlearnTopicAnimals).
  final String nameL10nKey;
  final String? iconAssetPath;
}
