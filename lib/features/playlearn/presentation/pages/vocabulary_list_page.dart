import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/playlearn_cubit.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/playlearn_state.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/word_card.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

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
        body: TypeSafeBlocBuilder<PlaylearnCubit, PlaylearnState>(
          builder: (final context, final state) {
            if (state.words.isEmpty && !state.isLoading) {
              return CommonEmptyState(message: l10n.playlearnNoWords);
            }
            final words = List.of(state.words, growable: false);
            return ListView.builder(
              itemCount: words.length,
              itemBuilder: (final context, final index) {
                if (index >= words.length) {
                  return const SizedBox.shrink();
                }
                final item = words[index];
                return WordCard(
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
