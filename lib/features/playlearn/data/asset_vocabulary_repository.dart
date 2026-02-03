import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';

/// In-memory vocabulary repository with demo data (Animals topic).
class AssetVocabularyRepository implements VocabularyRepository {
  AssetVocabularyRepository();

  static const String _topicAnimalsId = 'animals';

  static final List<TopicItem> _topics = <TopicItem>[
    const TopicItem(
      id: _topicAnimalsId,
      nameL10nKey: 'playlearnTopicAnimals',
    ),
  ];

  static const String _assetPrefix = 'assets/playlearn/files';

  static final List<VocabularyItem> _words = <VocabularyItem>[
    const VocabularyItem(
      id: 'cat',
      wordEn: 'cat',
      topicId: _topicAnimalsId,
      imageAssetPath: '$_assetPrefix/cat.svg',
    ),
    const VocabularyItem(
      id: 'dog',
      wordEn: 'dog',
      topicId: _topicAnimalsId,
      imageAssetPath: '$_assetPrefix/dog.svg',
    ),
    const VocabularyItem(
      id: 'bird',
      wordEn: 'bird',
      topicId: _topicAnimalsId,
      imageAssetPath: '$_assetPrefix/bird-vector.svg',
    ),
    const VocabularyItem(
      id: 'fish',
      wordEn: 'fish',
      topicId: _topicAnimalsId,
      imageAssetPath: '$_assetPrefix/fish.svg',
    ),
    const VocabularyItem(
      id: 'rabbit',
      wordEn: 'rabbit',
      topicId: _topicAnimalsId,
      imageAssetPath: '$_assetPrefix/rabbit.svg',
    ),
  ];

  @override
  List<TopicItem> getTopics() => List<TopicItem>.unmodifiable(_topics);

  @override
  List<VocabularyItem> getWordsByTopic(final String topicId) => List<VocabularyItem>.unmodifiable(
    _words.where((final w) => w.topicId == topicId).toList(),
  );
}
