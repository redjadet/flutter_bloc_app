import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/audio_playback_service.dart';
import 'package:flutter_bloc_app/features/playlearn/domain/vocabulary_repository.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/playlearn_cubit.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/playlearn_state.dart';
import 'package:flutter_bloc_app/features/playlearn/presentation/widgets/topic_card.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';

/// Topic selection page for playlearn (kids vocabulary).
class PlaylearnPage extends StatelessWidget {
  const PlaylearnPage({super.key});

  static String _topicDisplayName(
    final String nameL10nKey,
    final AppLocalizations l10n,
  ) {
    if (nameL10nKey == 'playlearnTopicAnimals') {
      return l10n.playlearnTopicAnimals;
    }
    return nameL10nKey;
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => PlaylearnCubit(
        repository: getIt<VocabularyRepository>(),
        audioService: getIt<AudioPlaybackService>(),
      ),
      child: CommonPageLayout(
        title: l10n.playlearnTitle,
        body: BlocBuilder<PlaylearnCubit, PlaylearnState>(
          builder: (final context, final state) {
            if (state.isLoading) {
              return const CommonLoadingWidget();
            }
            if (state.hasError) {
              return CommonErrorView(
                message: state.errorMessage ?? '',
                onRetry: () => context.cubit<PlaylearnCubit>().loadTopics(),
              );
            }
            if (state.topics.isEmpty) {
              return const CommonEmptyState(message: 'No topics');
            }
            return ListView.separated(
              padding: context.pagePadding,
              itemCount: state.topics.length,
              separatorBuilder: (final context, final index) =>
                  SizedBox(height: context.responsiveGapM),
              itemBuilder: (final context, final index) {
                final topic = state.topics[index];
                return TopicCard(
                  topic: topic,
                  displayName: _topicDisplayName(topic.nameL10nKey, l10n),
                  onTap: () => context.pushNamed(
                    AppRoutes.playlearnVocabulary,
                    pathParameters: <String, String>{
                      'topicId': topic.id,
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
