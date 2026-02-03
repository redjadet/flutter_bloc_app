import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';

/// Abstraction over vocabulary/topic data (pure Dart, Flutter-free).
abstract class VocabularyRepository {
  /// Returns all available topics (e.g. Animals).
  List<TopicItem> getTopics();

  /// Returns vocabulary items for the given topic ID.
  List<VocabularyItem> getWordsByTopic(final String topicId);
}
