import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
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
    super.key,
  });

  final String topicId;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (final _) => PlaylearnCubit(
        repository: getIt<VocabularyRepository>(),
        audioService: getIt<AudioPlaybackService>(),
        l10n: l10n,
      )..loadWordsForTopic(topicId),
      child: CommonPageLayout(
        title: l10n.playlearnTitle,
        body: TypeSafeBlocBuilder<PlaylearnCubit, PlaylearnState>(
          builder: (final context, final state) {
            if (state.words.isEmpty && !state.isLoading) {
              return const CommonEmptyState(message: 'No words');
            }
            return ListView.builder(
              itemCount: state.words.length,
              itemBuilder: (final context, final index) {
                final item = state.words[index];
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
