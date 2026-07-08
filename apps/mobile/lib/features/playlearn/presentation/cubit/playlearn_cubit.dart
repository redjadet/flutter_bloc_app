import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/cubit/playlearn_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class PlaylearnCubit extends Cubit<PlaylearnState> {
  PlaylearnCubit({
    required this._repository,
    required this._audioService,
    this._l10n,
  }) : super(const PlaylearnState()) {
    loadTopics();
  }

  final VocabularyRepository _repository;
  final AudioPlaybackService _audioService;
  final AppLocalizations? _l10n;

  void loadTopics() {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final topics = _repository.getTopics();
      if (isClosed) return;
      emit(state.copyWith(topics: topics, isLoading: false));
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'PlaylearnCubit.loadTopics failed',
        error,
        stackTrace,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _l10n?.featureLoadError ?? error.toString(),
        ),
      );
    }
  }

  void loadWordsForTopic(final String topicId) {
    if (isClosed) return;
    try {
      final words = _repository.getWordsByTopic(topicId);
      if (isClosed) return;
      emit(
        state.copyWith(
          selectedTopicId: topicId,
          words: words,
        ),
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'PlaylearnCubit.loadWordsForTopic failed',
        error,
        stackTrace,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          selectedTopicId: topicId,
          words: const [],
          errorMessage: _l10n?.featureLoadError ?? error.toString(),
        ),
      );
    }
  }

  Future<void> speakWord(final String text) async {
    try {
      await _audioService.speak(text);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'PlaylearnCubit.speakWord failed',
        error,
        stackTrace,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          errorMessage: _l10n?.couldNotPlayAudio ?? 'Could not play audio',
        ),
      );
    }
  }
}
