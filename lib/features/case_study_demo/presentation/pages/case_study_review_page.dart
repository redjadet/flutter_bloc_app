// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_draft.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_question_prompt.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_cubit.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/cubit/case_study_session_state.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_video_tile.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';

class CaseStudyReviewPage extends StatelessWidget {
  const CaseStudyReviewPage({super.key});

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.caseStudyReviewTitle,
      body: BlocConsumer<CaseStudySessionCubit, CaseStudySessionState>(
        listenWhen: (p, c) =>
            p.isSubmitting &&
            !c.isSubmitting &&
            !c.submitError &&
            !c.submitLocalHistoryFailed &&
            c.draft.phase == CaseStudyDraftPhase.metadata &&
            c.draft.answers.isEmpty,
        listener: (context, state) {
          context.goNamed(AppRoutes.caseStudyDemoHistory);
        },
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
          if (!draft.isComplete) {
            return const _CaseStudyStepRedirect(
              targetRouteName: AppRoutes.caseStudyDemoRecord,
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (draft.caseType case final CaseStudyCaseType type?)
                ListTile(
                  title: Text(l10n.caseStudyCaseTypeLabel),
                  subtitle: Text(caseStudyCaseTypeTitle(l10n, type)),
                ),
              ListTile(
                title: Text(l10n.caseStudyDoctorNameLabel),
                subtitle: Text(draft.doctorName),
              ),
              if (draft.notes.isNotEmpty)
                ListTile(
                  title: Text(l10n.caseStudyNotesLabel),
                  subtitle: Text(draft.notes),
                ),
              const Divider(),
              for (final CaseStudyQuestionId qid
                  in CaseStudyQuestions.orderedIds)
                ExpansionTile(
                  title: Text(caseStudyQuestionPrompt(l10n, qid)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: switch (draft.answers[qid]) {
                        final String path when path.isNotEmpty =>
                          CaseStudyVideoTile(
                            videoPath: path,
                            l10n: l10n,
                          ),
                        _ => Text(l10n.caseStudyVideoMissing),
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (state.submitError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    state.submitLocalHistoryFailed
                        ? l10n.caseStudySubmitLocalHistoryFailed
                        : l10n.caseStudyErrorGeneric,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (state.submitLocalHistoryFailed) ...[
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          await context
                              .cubit<CaseStudySessionCubit>()
                              .retryPersistLocalHistoryAfterRemote();
                        },
                  child: Text(l10n.caseStudyRetryLocalSave),
                ),
                const SizedBox(height: 8),
              ],
              if (state.isSubmitting)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.submitProgressDeterminate)
                        LinearProgressIndicator(
                          value: state.submitProgress.clamp(0, 1),
                        )
                      else
                        const LinearProgressIndicator(),
                      if (state.submitProgressDeterminate) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${(state.submitProgress.clamp(0, 1) * 100).round()}%',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              FilledButton(
                onPressed: state.isSubmitting || state.submitLocalHistoryFailed
                    ? null
                    : () async {
                        await context
                            .cubit<CaseStudySessionCubit>()
                            .submitMockUpload();
                      },
                child: state.isSubmitting
                    ? (state.submitProgressDeterminate
                          ? Text(l10n.caseStudyUploading)
                          : Text(l10n.caseStudySubmit))
                    : Text(l10n.caseStudySubmit),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: state.isSubmitting
                    ? null
                    : () async {
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
                          await context
                              .cubit<CaseStudySessionCubit>()
                              .abandonCase();
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
