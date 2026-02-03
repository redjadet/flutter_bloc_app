import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/playlearn_state.dart';

class PlaylearnCubit extends Cubit<PlaylearnState> {
  PlaylearnCubit({
    required final VocabularyRepository repository,
    required final AudioPlaybackService audioService,
  }) : _repository = repository,
       _audioService = audioService,
       super(const PlaylearnState()) {
    loadTopics();
  }

  final VocabularyRepository _repository;
  final AudioPlaybackService _audioService;

  void loadTopics() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final topics = _repository.getTopics();
    if (isClosed) return;
    emit(state.copyWith(topics: topics, isLoading: false));
  }

  void loadWordsForTopic(final String topicId) {
    emit(
      state.copyWith(
        selectedTopicId: topicId,
        words: _repository.getWordsByTopic(topicId),
      ),
    );
  }

  Future<void> speakWord(final String text) async {
    try {
      await _audioService.speak(text);
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(errorMessage: 'Could not play audio'));
    }
  }
}
