part of 'case_study_history_detail_page.dart';

class CaseStudyHistoryDetailPage extends StatelessWidget {
  const CaseStudyHistoryDetailPage({super.key});

  Future<bool> _confirmDelete(final BuildContext context) async {
    final l10n = context.l10n;
    final bool? confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (final dialogContext) => AlertDialog.adaptive(
        title: Text(l10n.caseStudyDeleteDialogTitle),
        content: Text(l10n.caseStudyDeleteDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteButtonLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return TypeSafeBlocListener<
      CaseStudyHistoryDetailCubit,
      CaseStudyHistoryDetailState
    >(
      listenWhen: (final prev, final curr) =>
          prev.transientError != curr.transientError &&
          curr.transientError != null,
      listener: (final context, final state) {
        final Object? error = state.transientError;
        if (error == null) return;
        ErrorHandling.handleCubitError(context, error);
        context.cubit<CaseStudyHistoryDetailCubit>().clearTransientError();
      },
      child: CommonPageLayout(
        title: l10n.caseStudyHistoryDetailTitle,
        actions: <Widget>[
          TypeSafeBlocBuilder<
            CaseStudyHistoryDetailCubit,
            CaseStudyHistoryDetailState
          >(
            buildWhen: (final prev, final curr) =>
                prev.isDeleting != curr.isDeleting,
            builder: (final context, final deleteState) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteButtonLabel,
                onPressed: deleteState.isDeleting
                    ? null
                    : () async {
                        final bool shouldDelete = await _confirmDelete(context);
                        if (!shouldDelete || !context.mounted) return;
                        final bool deleted = await context
                            .cubit<CaseStudyHistoryDetailCubit>()
                            .delete();
                        if (deleted && context.mounted) {
                          await Navigator.of(context).maybePop();
                        }
                      },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.caseStudyRefreshDetailTooltip,
            onPressed: () =>
                context.cubit<CaseStudyHistoryDetailCubit>().refresh(),
          ),
        ],
        body:
            TypeSafeBlocBuilder<
              CaseStudyHistoryDetailCubit,
              CaseStudyHistoryDetailState
            >(
              builder: (final context, final state) {
                if (state.isLoading && state.record == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final CaseStudyRecord? record = state.record;
                if (record == null) {
                  final String message = switch (state.status) {
                    CaseStudyHistoryDetailStatus.notFound =>
                      l10n.caseStudyHistoryDetailNotFound,
                    CaseStudyHistoryDetailStatus.error =>
                      state.errorMessage ??
                          l10n.caseStudyHistoryDetailUnavailable,
                    CaseStudyHistoryDetailStatus.unavailable ||
                    CaseStudyHistoryDetailStatus.initial ||
                    CaseStudyHistoryDetailStatus.loading =>
                      l10n.caseStudyHistoryDetailUnavailable,
                    CaseStudyHistoryDetailStatus.loaded =>
                      l10n.caseStudyHistoryDetailUnavailable,
                  };
                  return Center(child: Text(message));
                }

                final CaseStudyRecord r = record;
                final DateFormat fmt = DateFormat.yMMMd().add_jm();
                return RefreshIndicator(
                  onRefresh: () =>
                      context.cubit<CaseStudyHistoryDetailCubit>().refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (state.errorMessage case final String refreshError)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            refreshError,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                      if (state.usesExpiringCloudPlaybackUrls)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 22,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.caseStudySignedUrlsRefreshHint,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ListTile(
                        title: Text(l10n.caseStudyDoctorNameLabel),
                        subtitle: Text(r.doctorName),
                      ),
                      ListTile(
                        title: Text(l10n.caseStudyCaseTypeLabel),
                        subtitle: Text(
                          caseStudyCaseTypeTitle(l10n, r.caseType),
                        ),
                      ),
                      ListTile(
                        title: Text(l10n.caseStudySubmittedAt),
                        subtitle: Text(fmt.format(r.submittedAt.toLocal())),
                      ),
                      if (r.notes.isNotEmpty)
                        ListTile(
                          title: Text(l10n.caseStudyNotesLabel),
                          subtitle: Text(r.notes),
                        ),
                      const Divider(),
                      for (final CaseStudyQuestionId qid
                          in CaseStudyQuestions.orderedIds)
                        ExpansionTile(
                          key: ValueKey<CaseStudyQuestionId>(qid),
                          title: Text(caseStudyQuestionPrompt(l10n, qid)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: switch (r.answers[qid]) {
                                final String path when path.isNotEmpty =>
                                  CaseStudyVideoTile(
                                    key: ValueKey<String>(
                                      'case-study-video-$qid-$path',
                                    ),
                                    videoPath: path,
                                    l10n: l10n,
                                  ),
                                _ => Text(l10n.caseStudyVideoMissing),
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
