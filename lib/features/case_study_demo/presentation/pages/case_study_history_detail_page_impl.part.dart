part of 'case_study_history_detail_page.dart';

class _HistoryDetailLoad {
  const _HistoryDetailLoad({
    required this.record,
    required this.usesExpiringCloudPlaybackUrls,
  });

  final CaseStudyRecord record;
  final bool usesExpiringCloudPlaybackUrls;
}

enum _HistoryDetailFailureKind { notFound, unavailable }

class _HistoryDetailSnapshot {
  const _HistoryDetailSnapshot.ok(final _HistoryDetailLoad value)
    : load = value,
      failure = null;

  const _HistoryDetailSnapshot.fail(this.failure) : load = null;

  final _HistoryDetailLoad? load;
  final _HistoryDetailFailureKind? failure;

  bool get isSuccess => load != null;
}

class CaseStudyHistoryDetailPage extends StatefulWidget {
  const CaseStudyHistoryDetailPage({required this.recordId, super.key});

  final String recordId;

  @override
  State<CaseStudyHistoryDetailPage> createState() =>
      _CaseStudyHistoryDetailPageState();
}

class _CaseStudyHistoryDetailPageState
    extends State<CaseStudyHistoryDetailPage> {
  Future<_HistoryDetailSnapshot>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDetail();
  }

  Future<_HistoryDetailSnapshot> _loadDetail() async {
    final AuthRepository auth = getIt<AuthRepository>();
    final String? userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return const _HistoryDetailSnapshot.fail(
        _HistoryDetailFailureKind.unavailable,
      );
    }

    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    if (supaAuth.isConfigured && supaAuth.currentUser != null) {
      final CaseStudyRemoteRepository remote =
          getIt<CaseStudyRemoteRepository>();
      try {
        final RemoteCaseStudyDetail? detail = await remote.getSubmittedCase(
          caseId: widget.recordId,
        );
        if (detail == null) {
          return const _HistoryDetailSnapshot.fail(
            _HistoryDetailFailureKind.notFound,
          );
        }

        final Map<String, String> signedUrls =
            await signCaseStudyPlaybackUrlsInBatches(
              remote: remote,
              keysByQuestion: detail.remoteObjectKeysByQuestion,
              ttl: kCaseStudySignedPlaybackUrlTtl,
            );

        return _HistoryDetailSnapshot.ok(
          _HistoryDetailLoad(
            record: CaseStudyRecord(
              id: detail.caseId,
              submittedAt: detail.submittedAtUtc,
              doctorName: detail.doctorName,
              caseType: detail.caseType,
              notes: detail.notes,
              answers: signedUrls,
            ),
            usesExpiringCloudPlaybackUrls: true,
          ),
        );
      } on Object {
        return const _HistoryDetailSnapshot.fail(
          _HistoryDetailFailureKind.unavailable,
        );
      }
    }

    try {
      final CaseStudyLocalRepository local = getIt<CaseStudyLocalRepository>();
      await local.ensureReady();
      final CaseStudyRecord? record = await local.getRecord(
        userId,
        widget.recordId,
      );
      if (record == null) {
        return const _HistoryDetailSnapshot.fail(
          _HistoryDetailFailureKind.notFound,
        );
      }
      return _HistoryDetailSnapshot.ok(
        _HistoryDetailLoad(
          record: record,
          usesExpiringCloudPlaybackUrls: false,
        ),
      );
    } on Object {
      return const _HistoryDetailSnapshot.fail(
        _HistoryDetailFailureKind.unavailable,
      );
    }
  }

  /// Reloads detail without swapping to a pending [Future] first (avoids blanking the screen).
  Future<void> _reload() async {
    final _HistoryDetailSnapshot next = await _loadDetail();
    if (!mounted) return;
    setState(() {
      _future = Future<_HistoryDetailSnapshot>.value(next);
    });
  }

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

  Future<void> _deleteCaseStudy() async {
    final AuthRepository auth = getIt<AuthRepository>();
    final String? userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    final bool isRemote = supaAuth.isConfigured && supaAuth.currentUser != null;

    try {
      if (isRemote) {
        final CaseStudyRemoteDeleteRepository remoteDelete =
            getIt<CaseStudyRemoteDeleteRepository>();
        await remoteDelete.deleteCaseStudyRemote(caseId: widget.recordId);
      } else {
        final CaseStudyLocalRepository local =
            getIt<CaseStudyLocalRepository>();
        await local.ensureReady();
        final List<CaseStudyRecord> records = await local.loadRecords(userId);
        final List<CaseStudyRecord> next = records
            .where((final r) => r.id != widget.recordId)
            .toList();
        await local.saveRecords(userId, next);
        await getIt<CaseStudyClipFileStore>().deleteCaseFolder(widget.recordId);
      }

      if (!mounted) return;
      await Navigator.of(context).maybePop();
    } on Object catch (error) {
      if (error is HttpRequestFailure && error.statusCode == 401) {
        try {
          await getIt<SupabaseAuthRepository>().signOut();
        } on Object {
          // Best-effort only; still show the error message.
        }
      }
      if (!mounted) return;
      ErrorHandling.handleCubitError(context, error);
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.caseStudyHistoryDetailTitle,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: l10n.deleteButtonLabel,
          onPressed: () async {
            final bool shouldDelete = await _confirmDelete(context);
            if (!shouldDelete || !context.mounted) return;
            await _deleteCaseStudy();
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: l10n.caseStudyRefreshDetailTooltip,
          onPressed: () async {
            await _reload();
          },
        ),
      ],
      body: FutureBuilder<_HistoryDetailSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final _HistoryDetailSnapshot? data = snapshot.data;
          final _HistoryDetailLoad? load = data?.load;
          if (data == null || load == null) {
            final _HistoryDetailFailureKind kind =
                data?.failure ?? _HistoryDetailFailureKind.unavailable;
            final String message = switch (kind) {
              _HistoryDetailFailureKind.notFound =>
                l10n.caseStudyHistoryDetailNotFound,
              _HistoryDetailFailureKind.unavailable =>
                l10n.caseStudyHistoryDetailUnavailable,
            };
            return Center(child: Text(message));
          }
          final CaseStudyRecord r = load.record;
          final DateFormat fmt = DateFormat.yMMMd().add_jm();
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (load.usesExpiringCloudPlaybackUrls)
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.caseStudySignedUrlsRefreshHint,
                                style: Theme.of(context).textTheme.bodyMedium,
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
                  subtitle: Text(caseStudyCaseTypeTitle(l10n, r.caseType)),
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
                    title: Text(caseStudyQuestionPrompt(l10n, qid)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: switch (r.answers[qid]) {
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
              ],
            ),
          );
        },
      ),
    );
  }
}
