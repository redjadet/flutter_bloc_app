// check-ignore: nonbuilder_lists - small, fixed-size page content
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_local_repository.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_question.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_record.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_remote_repository.dart'
    show
        CaseStudyRemoteRepository,
        RemoteCaseStudyDetail,
        kCaseStudySignedPlaybackUrlTtl;
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_l10n_helpers.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/case_study_question_prompt.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_video_tile.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:intl/intl.dart';

class _HistoryDetailLoad {
  const _HistoryDetailLoad({
    required this.record,
    required this.usesExpiringCloudPlaybackUrls,
  });

  final CaseStudyRecord record;
  final bool usesExpiringCloudPlaybackUrls;
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
  Future<_HistoryDetailLoad?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDetail();
  }

  Future<_HistoryDetailLoad?> _loadDetail() async {
    final AuthRepository auth = getIt<AuthRepository>();
    final String? userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return null;

    final SupabaseAuthRepository supaAuth = getIt<SupabaseAuthRepository>();
    if (supaAuth.isConfigured && supaAuth.currentUser != null) {
      final CaseStudyRemoteRepository remote =
          getIt<CaseStudyRemoteRepository>();
      final RemoteCaseStudyDetail? detail = await remote.getSubmittedCase(
        caseId: widget.recordId,
      );
      if (detail == null) return null;

      final Map<String, String> signedUrls = <String, String>{};
      for (final MapEntry<String, String> e
          in detail.remoteObjectKeysByQuestion.entries) {
        final String url = await remote.createSignedPlaybackUrl(
          objectKey: e.value,
          ttl: kCaseStudySignedPlaybackUrlTtl,
        );
        signedUrls[e.key] = url;
      }

      return _HistoryDetailLoad(
        record: CaseStudyRecord(
          id: detail.caseId,
          submittedAt: detail.submittedAtUtc,
          doctorName: detail.doctorName,
          caseType: detail.caseType,
          notes: detail.notes,
          answers: signedUrls,
        ),
        usesExpiringCloudPlaybackUrls: true,
      );
    }

    final CaseStudyLocalRepository local = getIt<CaseStudyLocalRepository>();
    await local.ensureReady();
    final CaseStudyRecord? record = await local.getRecord(
      userId,
      widget.recordId,
    );
    if (record == null) return null;
    return _HistoryDetailLoad(
      record: record,
      usesExpiringCloudPlaybackUrls: false,
    );
  }

  /// Reloads detail without swapping to a pending [Future] first (avoids blanking the screen).
  Future<void> _reload() async {
    final _HistoryDetailLoad? next = await _loadDetail();
    if (!mounted) return;
    setState(() => _future = Future<_HistoryDetailLoad?>.value(next));
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.caseStudyHistoryDetailTitle,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: l10n.caseStudyRefreshDetailTooltip,
          onPressed: () async {
            await _reload();
          },
        ),
      ],
      body: FutureBuilder<_HistoryDetailLoad?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final _HistoryDetailLoad? load = snapshot.data;
          if (load == null) {
            return Center(child: Text(l10n.caseStudyErrorGeneric));
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
