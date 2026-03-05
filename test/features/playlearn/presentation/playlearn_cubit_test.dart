import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/playlearn_cubit.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/playlearn_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylearnCubit', () {
    blocTest<PlaylearnCubit, PlaylearnState>(
      'emits loading then success when getTopics returns',
      build: () => PlaylearnCubit(
        repository: _FakeVocabularyRepository(
          topics: const [
            TopicItem(id: 't1', nameL10nKey: 'playlearnTopicAnimals'),
          ],
        ),
        audioService: _FakeAudioPlaybackService(),
      ),
      act: (cubit) => cubit.loadTopics(),
      wait: Duration.zero,
      expect: () => <Matcher>[
        isA<PlaylearnState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        equals(
          const PlaylearnState(
            isLoading: false,
            topics: [TopicItem(id: 't1', nameL10nKey: 'playlearnTopicAnimals')],
          ),
        ),
      ],
    );

    blocTest<PlaylearnCubit, PlaylearnState>(
      'emits loading then error when getTopics throws',
      build: () => PlaylearnCubit(
        repository: _FakeVocabularyRepository(throwOnGetTopics: true),
        audioService: _FakeAudioPlaybackService(),
      ),
      act: (cubit) => cubit.loadTopics(),
      wait: Duration.zero,
      expect: () => <Matcher>[
        equals(const PlaylearnState(isLoading: true, errorMessage: null)),
        isA<PlaylearnState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              allOf(isNotNull, isNotEmpty),
            ),
      ],
    );

    blocTest<PlaylearnCubit, PlaylearnState>(
      'loadWordsForTopic emits words when getWordsByTopic returns',
      build: () => PlaylearnCubit(
        repository: _FakeVocabularyRepository(
          topics: const [
            TopicItem(id: 'animals', nameL10nKey: 'playlearnTopicAnimals'),
          ],
          wordsByTopic: const {
            'animals': [
              VocabularyItem(id: 'w1', wordEn: 'cat', topicId: 'animals'),
            ],
          },
        ),
        audioService: _FakeAudioPlaybackService(),
      ),
      act: (cubit) => cubit.loadWordsForTopic('animals'),
      wait: Duration.zero,
      expect: () => <PlaylearnState>[
        const PlaylearnState(
          selectedTopicId: 'animals',
          words: [VocabularyItem(id: 'w1', wordEn: 'cat', topicId: 'animals')],
          topics: [
            TopicItem(id: 'animals', nameL10nKey: 'playlearnTopicAnimals'),
          ],
        ),
      ],
    );

    blocTest<PlaylearnCubit, PlaylearnState>(
      'loadWordsForTopic emits error when getWordsByTopic throws',
      build: () => PlaylearnCubit(
        repository: _FakeVocabularyRepository(
          topics: const [
            TopicItem(id: 'animals', nameL10nKey: 'playlearnTopicAnimals'),
          ],
          throwOnGetWordsByTopic: true,
        ),
        audioService: _FakeAudioPlaybackService(),
      ),
      act: (cubit) => cubit.loadWordsForTopic('animals'),
      wait: Duration.zero,
      expect: () => <Matcher>[
        isA<PlaylearnState>()
            .having((s) => s.selectedTopicId, 'selectedTopicId', 'animals')
            .having((s) => s.words, 'words', <VocabularyItem>[])
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              allOf(isNotNull, isNotEmpty),
            ),
      ],
    );

    blocTest<PlaylearnCubit, PlaylearnState>(
      'speakWord emits error when speak throws',
      build: () => PlaylearnCubit(
        repository: _FakeVocabularyRepository(topics: const []),
        audioService: _FakeAudioPlaybackService(throwOnSpeak: true),
      ),
      act: (cubit) async {
        await cubit.speakWord('hello');
      },
      expect: () => <Matcher>[
        isA<PlaylearnState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          allOf(isNotNull, isNotEmpty),
        ),
      ],
    );

    blocTest<PlaylearnCubit, PlaylearnState>(
      'speakWord does not emit when speak succeeds',
      build: () => PlaylearnCubit(
        repository: _FakeVocabularyRepository(topics: const []),
        audioService: _FakeAudioPlaybackService(),
      ),
      act: (cubit) async {
        await cubit.speakWord('hello');
      },
      expect: () => <PlaylearnState>[],
    );

    test('loadWordsForTopic does not emit when cubit is already closed', () {
      final cubit = PlaylearnCubit(
        repository: _FakeVocabularyRepository(topics: const []),
        audioService: _FakeAudioPlaybackService(),
      );
      cubit.close();
      final states = <PlaylearnState>[];
      cubit.stream.listen(states.add);
      cubit.loadWordsForTopic('any');
      expect(states, isEmpty);
    });
  });
}

class _FakeVocabularyRepository implements VocabularyRepository {
  _FakeVocabularyRepository({
    this.topics = const [],
    this.wordsByTopic = const {},
    this.throwOnGetTopics = false,
    this.throwOnGetWordsByTopic = false,
  });

  final List<TopicItem> topics;
  final Map<String, List<VocabularyItem>> wordsByTopic;
  final bool throwOnGetTopics;
  final bool throwOnGetWordsByTopic;

  @override
  List<TopicItem> getTopics() {
    if (throwOnGetTopics) {
      throw StateError('getTopics failed');
    }
    return List<TopicItem>.unmodifiable(topics);
  }

  @override
  List<VocabularyItem> getWordsByTopic(final String topicId) {
    if (throwOnGetWordsByTopic) {
      throw StateError('getWordsByTopic failed');
    }
    final list = wordsByTopic[topicId] ?? const [];
    return List<VocabularyItem>.unmodifiable(list);
  }
}

class _FakeAudioPlaybackService implements AudioPlaybackService {
  _FakeAudioPlaybackService({this.throwOnSpeak = false});

  final bool throwOnSpeak;

  @override
  Future<void> speak(final String text) async {
    if (throwOnSpeak) {
      throw StateError('speak failed');
    }
  }

  @override
  Future<void> stop() async {}
}
