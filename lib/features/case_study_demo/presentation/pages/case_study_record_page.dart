// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_question_prompt.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_video_tile.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';

class CaseStudyRecordPage extends StatefulWidget {
  const CaseStudyRecordPage({super.key});

  @override
  State<CaseStudyRecordPage> createState() => _CaseStudyRecordPageState();
}

class _CaseStudyRecordPageState extends State<CaseStudyRecordPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(
          context.cubit<CaseStudySessionCubit>().tryRecoverLostVideo(),
        );
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.caseStudyRecordTitle,
      body: BlocBuilder<CaseStudySessionCubit, CaseStudySessionState>(
        builder: (context, state) {
          if (state.hydration != CaseStudyHydrationStatus.ready) {
            return const Center(child: CircularProgressIndicator());
          }
          final draft = state.draft;
          if (!draft.hasMetadata) {
            return const _CaseStudyStepRedirect(
              targetRouteName: AppRoutes.caseStudyDemoNew,
            );
          }
          if (draft.phase == CaseStudyDraftPhase.reviewing &&
              draft.isComplete) {
            return const _CaseStudyStepRedirect(
              targetRouteName: AppRoutes.caseStudyDemoReview,
            );
          }
          final CaseStudyQuestionId qid = draft.currentQuestionId;
          final int current = draft.currentQuestionIndex + 1;
          final int total = CaseStudyQuestions.orderedIds.length;
          final String? videoPath = draft.answers[qid];
          final String? errKey = state.pickErrorKey;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Text(
                l10n.caseStudyQuestionProgress(current, total),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                caseStudyQuestionPrompt(l10n, qid),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              if (videoPath != null && videoPath.isNotEmpty)
                CaseStudyVideoTile(videoPath: videoPath, l10n: l10n),
              if (errKey != null) ...[
                const SizedBox(height: 8),
                Text(
                  cameraGalleryErrorMessage(l10n, errKey),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context
                          .cubit<CaseStudySessionCubit>()
                          .tryPickFromCamera(),
                      child: Text(l10n.caseStudyPickVideoCamera),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => context
                          .cubit<CaseStudySessionCubit>()
                          .tryPickFromGallery(),
                      child: Text(l10n.caseStudyPickVideoGallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (draft.currentQuestionIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context
                            .cubit<CaseStudySessionCubit>()
                            .previousQuestion(),
                        child: Text(l10n.caseStudyBack),
                      ),
                    ),
                  if (draft.currentQuestionIndex > 0) const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: videoPath == null || videoPath.isEmpty
                          ? null
                          : () {
                              final bool last =
                                  draft.currentQuestionIndex >= total - 1;
                              if (last) {
                                context
                                    .cubit<CaseStudySessionCubit>()
                                    .goToReviewPhase();
                                context.goNamed(
                                  AppRoutes.caseStudyDemoReview,
                                );
                              } else {
                                context
                                    .cubit<CaseStudySessionCubit>()
                                    .nextQuestion();
                              }
                            },
                      child: Text(
                        draft.currentQuestionIndex >= total - 1
                            ? l10n.caseStudyGoToReview
                            : l10n.caseStudyNext,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  final bool? ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.caseStudyAbandon),
                      content: Text(l10n.caseStudyAbandonConfirmBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancelButtonLabel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.caseStudyAbandon),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await context.cubit<CaseStudySessionCubit>().abandonCase();
                    if (context.mounted) {
                      context.goNamed(AppRoutes.caseStudyDemo);
                    }
                  }
                },
                child: Text(l10n.caseStudyAbandon),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaseStudyStepRedirect extends StatefulWidget {
  const _CaseStudyStepRedirect({required this.targetRouteName});

  final String targetRouteName;

  @override
  State<_CaseStudyStepRedirect> createState() => _CaseStudyStepRedirectState();
}

class _CaseStudyStepRedirectState extends State<_CaseStudyStepRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.goNamed(widget.targetRouteName);
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
