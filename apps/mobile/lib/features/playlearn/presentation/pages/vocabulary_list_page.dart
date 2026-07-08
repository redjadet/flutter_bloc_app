import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_empty_state.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_item.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/cubit/playlearn_cubit.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/cubit/playlearn_state.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/word_card.dart';

/// Vocabulary list page (tap-to-hear words) for a topic.
class VocabularyListPage extends StatelessWidget {
  const VocabularyListPage({
    required this.topicId,
    required this.repository,
    required this.audioService,
    super.key,
  });

  final String topicId;
  final VocabularyRepository repository;
  final AudioPlaybackService audioService;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (final _) => PlaylearnCubit(
        repository: repository,
        audioService: audioService,
        l10n: l10n,
      )..loadWordsForTopic(topicId),
      child: CommonPageLayout(
        title: l10n.playlearnTitle,
        body: Builder(
          builder: (final context) {
            final viewState = context
                .selectState<
                  PlaylearnCubit,
                  PlaylearnState,
                  ({bool isLoading, List<VocabularyItem> words})
                >(
                  selector: (final state) => (
                    isLoading: state.isLoading,
                    words: state.words,
                  ),
                );
            if (viewState.words.isEmpty && !viewState.isLoading) {
              return CommonEmptyState(message: l10n.playlearnNoWords);
            }
            final words = List.of(viewState.words, growable: false);
            return ListView.builder(
              itemCount: words.length,
              itemBuilder: (final context, final index) {
                if (index >= words.length) {
                  return const SizedBox.shrink();
                }
                final item = words[index];
                return WordCard(
                  key: ValueKey<String>('word-$topicId-${item.id}'),
                  item: item,
                  onListen: () =>
                      context.cubit<PlaylearnCubit>().speakWord(item.wordEn),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
