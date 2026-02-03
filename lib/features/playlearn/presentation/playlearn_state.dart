import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlearn_state.freezed.dart';

@freezed
abstract class PlaylearnState with _$PlaylearnState {
  const factory PlaylearnState({
    @Default(<TopicItem>[]) final List<TopicItem> topics,
    final String? selectedTopicId,
    @Default(<VocabularyItem>[]) final List<VocabularyItem> words,
    @Default(false) final bool isLoading,
    final String? errorMessage,
  }) = _PlaylearnState;

  const PlaylearnState._();

  bool get hasError => errorMessage != null;
}
