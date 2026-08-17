import 'package:flutter_bloc_app/features/playlearn/domain/topic_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlearn_state.freezed.dart';

@freezed
abstract class PlaylearnState with _$PlaylearnState {
  const factory PlaylearnState({
    @Default(<TopicItem>[]) List<TopicItem> topics,
    String? selectedTopicId,
    @Default(<VocabularyItem>[]) List<VocabularyItem> words,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PlaylearnState;

  const PlaylearnState._();

  bool get hasError => errorMessage != null;
}
